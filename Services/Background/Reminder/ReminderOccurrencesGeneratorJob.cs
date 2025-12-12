// Changes:
// 1. Extract DTSTART from RRULE if provided
// 2. Use BYHOUR/BYMINUTE to set DtStart time if provided
// 3. Full iCal.NET capability enabled
// ============================================================================

using Hangfire;
using HealthCare_.Models.V2;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Text.RegularExpressions;

namespace HealthCare_.Services.Background.Reminder
{
    public class ReminderOccurrencesGeneratorJob
    {
        private readonly System.IServiceProvider _serviceProvider;
        private readonly ILogger<ReminderOccurrencesGeneratorJob> _logger;

        public ReminderOccurrencesGeneratorJob(
            System.IServiceProvider serviceProvider,
            ILogger<ReminderOccurrencesGeneratorJob> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        public async Task GenerateForAllPatientsAsync()
        {
            await using var scope = _serviceProvider.CreateAsyncScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var patientIds = await context.ReminderV2s
                .Where(r => r.IsActive)
                .Select(r => r.PatientId)
                .Distinct()
                .ToListAsync();

            _logger.LogInformation("Starting cache generation for {Count} patients", patientIds.Count);

            foreach (var patientId in patientIds)
            {
                try
                {
                    await GenerateForPatientAsync(patientId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to generate cache for Patient {PatientId}", patientId);
                }
            }
        }

        public async Task GenerateForPatientAsync(int patientId)
        {
            await using var scope = _serviceProvider.CreateAsyncScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
            await GenerateForPatientAsync(context, patientId);
        }

        private async Task GenerateForPatientAsync(HealthCarePlusContext context, int patientId)
        {
            var nowUtc = DateTime.UtcNow;
            var todayUtc = nowUtc.Date;
            var fromUtc = todayUtc;
            var toUtc = todayUtc.AddDays(60);

            _logger.LogInformation(
                "Generating cache for Patient {PatientId}: From {From} to {To} UTC",
                patientId, fromUtc, toUtc);

            var reminders = await context.ReminderV2s
                .AsNoTracking()
                .Include(r => r.PrescriptionMed)
                .Where(r => r.PatientId == patientId && r.IsActive)
                .ToListAsync();

            var newEntries = new List<ReminderOccurrencesCache>();

            foreach (var reminder in reminders)
            {
                try
                {
                    ValidateReminderIntegrity(reminder);

                    _logger.LogInformation(
                        "Processing Reminder {ReminderId}: StartDateUtc={StartUtc}, IsSimple={IsSimple}, RRULE={RRULE}",
                        reminder.Id,
                        reminder.StartDateUtc,
                        reminder.IsSimpleEveryXHours,
                        reminder.RRULE ?? "NULL");

                    var occurrences = GenerateOccurrencesWithIcalNetFull(reminder, fromUtc, toUtc);

                    foreach (var dtUtc in occurrences)
                    {
                        var timeZoneId = reminder.TimeZoneId ?? "Africa/Cairo";
                        var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

                        var localTime = TimeZoneInfo.ConvertTimeFromUtc(
                            DateTime.SpecifyKind(dtUtc, DateTimeKind.Utc),
                            tz);

                        newEntries.Add(new ReminderOccurrencesCache
                        {
                            CreatedAt = DateTime.UtcNow,
                            PatientId = patientId,
                            ReminderId = reminder.Id,
                            DueDateTimeUtc = DateTime.SpecifyKind(dtUtc, DateTimeKind.Utc),
                            DueDateTime = localTime,
                            TimeZoneId = timeZoneId,
                            Title = reminder.Title,
                            Message = reminder.Message ?? "",
                            Type = reminder.Type,
                            Dosage = reminder.PrescriptionMed != null
                                ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                                : null,
                            Status = 0
                        });
                    }

                    _logger.LogInformation(
                        "Generated {Count} occurrences for Reminder {ReminderId}",
                        occurrences.Count(),
                        reminder.Id);
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "Failed generating occurrences for Reminder {ReminderId}",
                        reminder.Id);
                }
            }

            if (!newEntries.Any())
            {
                _logger.LogInformation("No new occurrences for Patient {PatientId}", patientId);
                return;
            }

            await context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                  WHERE PatientId = {0}
                    AND DueDateTimeUtc >= {1}
                    AND DueDateTimeUtc < {2}",
                patientId, fromUtc, toUtc);

            await BulkInsertOccurrences(context, newEntries);

            _logger.LogInformation(
                "Successfully generated {Count} occurrences for Patient {PatientId}",
                newEntries.Count,
                patientId);
        }

        private void ValidateReminderIntegrity(ReminderV2 reminder)
        {
            if (reminder.IsSimpleEveryXHours)
            {
                if (!string.IsNullOrWhiteSpace(reminder.RRULE))
                    throw new InvalidOperationException($"Reminder {reminder.Id}: Simple mode requires RRULE = NULL");
                if (!reminder.FirstDoseTime.HasValue)
                    throw new InvalidOperationException($"Reminder {reminder.Id}: Simple mode requires FirstDoseTime");
                if (!reminder.IntervalHours.HasValue)
                    throw new InvalidOperationException($"Reminder {reminder.Id}: Simple mode requires IntervalHours");
            }
            else
            {
                if (string.IsNullOrWhiteSpace(reminder.RRULE))
                    throw new InvalidOperationException($"Reminder {reminder.Id}: RRule mode requires RRULE string");
                if (reminder.FirstDoseTime.HasValue || reminder.IntervalHours.HasValue)
                    throw new InvalidOperationException($"Reminder {reminder.Id}: RRule mode requires FirstDoseTime/IntervalHours = NULL");
            }
        }

        /// <summary>
        /// ✅ COMPLETE FIX: Full iCal.NET support with DTSTART extraction and BYHOUR/BYMINUTE handling
        /// </summary>
        private IEnumerable<DateTime> GenerateOccurrencesWithIcalNetFull(
            ReminderV2 reminder,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            try
            {
                var timeZoneId = reminder.TimeZoneId ?? "Africa/Cairo";
                var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

                var calendar = new Calendar();
                calendar.AddTimeZone(VTimeZone.FromSystemTimeZone(tz));

                var ev = new CalendarEvent { Uid = $"reminder-{reminder.Id}" };

                // ═══════════════════════════════════════════════════════════
                // MODE 1: SIMPLE MODE (No changes - already working perfectly)
                // ═══════════════════════════════════════════════════════════
                if (reminder.IsSimpleEveryXHours &&
                    reminder.FirstDoseTime.HasValue &&
                    reminder.IntervalHours.HasValue)
                {
                    _logger.LogDebug(
                        "Reminder {Id} SIMPLE MODE: StartDateUtc={Start}, FirstDose={FirstDose}, Interval={Interval}h",
                        reminder.Id, reminder.StartDateUtc, reminder.FirstDoseTime, reminder.IntervalHours);

                    var startLocal = TimeZoneInfo.ConvertTimeFromUtc(
                        DateTime.SpecifyKind(reminder.StartDateUtc, DateTimeKind.Utc),
                        tz);

                    var dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);
                    dtStartLocal = dtStartLocal.Add(reminder.FirstDoseTime.Value);

                    ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
                    ev.Summary = reminder.Title;

                    var rruleStr = $"FREQ=HOURLY;INTERVAL={reminder.IntervalHours.Value}";

                    if (reminder.EndDateUtc.HasValue)
                    {
                        var endLocal = TimeZoneInfo.ConvertTimeFromUtc(
                            DateTime.SpecifyKind(reminder.EndDateUtc.Value, DateTimeKind.Utc),
                            tz);

                        var untilLocal = DateTime.SpecifyKind(
                            endLocal.Date.AddDays(1).AddTicks(-1),
                            DateTimeKind.Unspecified);
                        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                        rruleStr += $";UNTIL={untilUtc:yyyyMMddTHHmmss}Z";
                    }

                    ev.RecurrenceRules.Add(new RecurrencePattern(rruleStr));
                }
                // ═══════════════════════════════════════════════════════════
                // MODE 2: RRULE MODE (COMPLETE FIX)
                // ═══════════════════════════════════════════════════════════
                else if (!string.IsNullOrWhiteSpace(reminder.RRULE))
                {
                    _logger.LogDebug(
                        "Reminder {Id} RRULE MODE: StartDateUtc={Start}, RRULE={RRULE}",
                        reminder.Id, reminder.StartDateUtc, reminder.RRULE);

                    var rrule = reminder.RRULE.ToUpperInvariant();

                    // ✅ FIX #1: Extract DTSTART from RRULE if provided
                    DateTime? dtStartFromRRule = ExtractDtStartFromRRule(reminder.RRULE, timeZoneId);

                    DateTime dtStartLocal;

                    if (dtStartFromRRule.HasValue)
                    {
                        // ✅ Use DTSTART from RRULE
                        dtStartLocal = DateTime.SpecifyKind(dtStartFromRRule.Value, DateTimeKind.Unspecified);

                        _logger.LogInformation(
                            "Reminder {Id}: Using DTSTART from RRULE: {DtStart}",
                            reminder.Id, dtStartLocal);
                    }
                    else
                    {
                        // ✅ FIX #2: Extract time from BYHOUR/BYMINUTE if provided
                        var (hour, minute) = ExtractTimeFromRRule(rrule);

                        // Convert StartDateUtc to local timezone
                        var startLocal = TimeZoneInfo.ConvertTimeFromUtc(
                            DateTime.SpecifyKind(reminder.StartDateUtc, DateTimeKind.Utc),
                            tz);

                        // Use DATE component from StartDateUtc
                        dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);

                        // ✅ FIX #3: Apply BYHOUR/BYMINUTE to DtStart
                        if (hour.HasValue)
                        {
                            dtStartLocal = dtStartLocal.AddHours(hour.Value);
                            _logger.LogInformation(
                                "Reminder {Id}: Extracted BYHOUR={Hour} from RRULE",
                                reminder.Id, hour.Value);
                        }
                        else
                        {
                            // Default to 9 AM if no BYHOUR specified
                            dtStartLocal = dtStartLocal.AddHours(9);
                        }

                        if (minute.HasValue)
                        {
                            dtStartLocal = dtStartLocal.AddMinutes(minute.Value);
                            _logger.LogInformation(
                                "Reminder {Id}: Extracted BYMINUTE={Minute} from RRULE",
                                reminder.Id, minute.Value);
                        }

                        _logger.LogInformation(
                            "Reminder {Id}: Calculated DtStart={DtStart} (Date from StartDateUtc + Time from RRULE)",
                            reminder.Id, dtStartLocal);
                    }

                    ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
                    ev.Summary = reminder.Title;

                    // ✅ FIX #4: Parse RRULE with full iCal.NET capability
                    try
                    {
                        // Remove DTSTART if it exists in the RRULE string (we already extracted it)
                        var cleanRRule = RemoveDtStartFromRRule(rrule);

                        var recurrencePattern = new RecurrencePattern(cleanRRule);
                        ev.RecurrenceRules.Add(recurrencePattern);

                        _logger.LogInformation(
                            "Reminder {Id}: RRULE parsed successfully - FREQ={Freq}, INTERVAL={Interval}, BYDAY={ByDay}, BYHOUR={ByHour}, BYMINUTE={ByMinute}",
                            reminder.Id,
                            recurrencePattern.Frequency,
                            recurrencePattern.Interval,
                            recurrencePattern.ByDay.Any() ? string.Join(",", recurrencePattern.ByDay) : "none",
                            recurrencePattern.ByHour.Any() ? string.Join(",", recurrencePattern.ByHour) : "none",
                            recurrencePattern.ByMinute.Any() ? string.Join(",", recurrencePattern.ByMinute) : "none");
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Invalid RRULE for Reminder {ReminderId}: {RRULE}",
                            reminder.Id, reminder.RRULE);
                        throw new ArgumentException($"Invalid RRULE syntax: {ex.Message}", nameof(reminder.RRULE));
                    }
                }
                else
                {
                    throw new InvalidOperationException($"Reminder {reminder.Id} is in invalid state after validation");
                }

                calendar.Events.Add(ev);

                var fromUtcSafe = DateTime.SpecifyKind(fromUtcInclusive, DateTimeKind.Utc);
                var toUtcSafe = DateTime.SpecifyKind(toUtcExclusive, DateTimeKind.Utc);

                var fromLocal = TimeZoneInfo.ConvertTimeFromUtc(fromUtcSafe, tz);
                var toLocal = TimeZoneInfo.ConvertTimeFromUtc(toUtcSafe, tz);

                var occurrencesLocal = calendar.GetOccurrences(fromLocal, toLocal);

                var results = new List<DateTime>();

                foreach (var occ in occurrencesLocal)
                {
                    var localTime = occ.Period.StartTime.AsDateTimeOffset.DateTime;

                    DateTime utcTime;
                    try
                    {
                        utcTime = TimeZoneInfo.ConvertTimeToUtc(
                            DateTime.SpecifyKind(localTime, DateTimeKind.Unspecified),
                            tz);
                    }
                    catch (ArgumentException ex)
                    {
                        _logger.LogWarning(ex,
                            "Skipping invalid local time due to DST: {LocalTime}",
                            localTime);
                        continue;
                    }

                    if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
                    {
                        results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
                    }
                }

                _logger.LogInformation(
                    "Reminder {Id}: Generated {Count} occurrences",
                    reminder.Id, results.Count);

                return results.OrderBy(dt => dt);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Critical error generating occurrences for reminder {ReminderId}", reminder.Id);
                throw;
            }
        }

        /// <summary>
        /// ✅ NEW: Extract DTSTART from RRULE string if provided
        /// Example: "DTSTART:20251213T080000;RRULE:FREQ=WEEKLY;BYDAY=MO"
        /// </summary>
        private DateTime? ExtractDtStartFromRRule(string rrule, string timeZoneId)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return null;

            var dtStartMatch = Regex.Match(rrule, @"DTSTART:(\d{8}T\d{6})", RegexOptions.IgnoreCase);
            if (!dtStartMatch.Success)
                return null;

            var dtStartStr = dtStartMatch.Groups[1].Value;

            // Parse format: 20251213T080000
            if (DateTime.TryParseExact(
                dtStartStr,
                "yyyyMMddTHHmmss",
                null,
                System.Globalization.DateTimeStyles.None,
                out var dtStart))
            {
                return dtStart;
            }

            return null;
        }

        /// <summary>
        /// ✅ NEW: Extract BYHOUR and BYMINUTE from RRULE
        /// </summary>
        private (int? hour, int? minute) ExtractTimeFromRRule(string rrule)
        {
            int? hour = null;
            int? minute = null;

            if (string.IsNullOrWhiteSpace(rrule))
                return (hour, minute);

            // Extract BYHOUR
            var hourMatch = Regex.Match(rrule, @"BYHOUR=(\d+)", RegexOptions.IgnoreCase);
            if (hourMatch.Success && int.TryParse(hourMatch.Groups[1].Value, out var h))
            {
                hour = h;
            }

            // Extract BYMINUTE
            var minuteMatch = Regex.Match(rrule, @"BYMINUTE=(\d+)", RegexOptions.IgnoreCase);
            if (minuteMatch.Success && int.TryParse(minuteMatch.Groups[1].Value, out var m))
            {
                minute = m;
            }

            return (hour, minute);
        }

        /// <summary>
        /// ✅ NEW: Remove DTSTART from RRULE string before parsing
        /// </summary>
        private string RemoveDtStartFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return rrule;

            // Remove DTSTART:YYYYMMDDTHHMMSS; prefix
            return Regex.Replace(rrule, @"DTSTART:\d{8}T\d{6};?", "", RegexOptions.IgnoreCase).Trim();
        }

        private async Task BulkInsertOccurrences(
            HealthCarePlusContext context,
            List<ReminderOccurrencesCache> entries)
        {
            var dataTable = new DataTable();
            dataTable.Columns.Add("CreatedAt", typeof(DateTime));
            dataTable.Columns.Add("PatientId", typeof(int));
            dataTable.Columns.Add("ReminderId", typeof(int));
            dataTable.Columns.Add("DueDateTimeUtc", typeof(DateTime));
            dataTable.Columns.Add("DueDateTime", typeof(DateTime));
            dataTable.Columns.Add("TimeZoneId", typeof(string));
            dataTable.Columns.Add("Title", typeof(string));
            dataTable.Columns.Add("Message", typeof(string));
            dataTable.Columns.Add("Type", typeof(int));
            dataTable.Columns.Add("Dosage", typeof(string));
            dataTable.Columns.Add("Status", typeof(byte));

            foreach (var e in entries)
            {
                dataTable.Rows.Add(
                    e.CreatedAt,
                    e.PatientId,
                    e.ReminderId,
                    e.DueDateTimeUtc,
                    e.DueDateTime,
                    e.TimeZoneId ?? "Africa/Cairo",
                    e.Title,
                    e.Message,
                    (int)e.Type,
                    e.Dosage,
                    e.Status);
            }

            await using var connection = context.Database.GetDbConnection();
            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync();

            using var bulkCopy = new SqlBulkCopy((SqlConnection)connection)
            {
                DestinationTableName = "ReminderOccurrencesCache",
                EnableStreaming = true,
                BatchSize = 1000
            };

            bulkCopy.ColumnMappings.Add("CreatedAt", "CreatedAt");
            bulkCopy.ColumnMappings.Add("PatientId", "PatientId");
            bulkCopy.ColumnMappings.Add("ReminderId", "ReminderId");
            bulkCopy.ColumnMappings.Add("DueDateTimeUtc", "DueDateTimeUtc");
            bulkCopy.ColumnMappings.Add("DueDateTime", "DueDateTime");
            bulkCopy.ColumnMappings.Add("TimeZoneId", "TimeZoneId");
            bulkCopy.ColumnMappings.Add("Title", "Title");
            bulkCopy.ColumnMappings.Add("Message", "Message");
            bulkCopy.ColumnMappings.Add("Type", "Type");
            bulkCopy.ColumnMappings.Add("Dosage", "Dosage");
            bulkCopy.ColumnMappings.Add("Status", "Status");

            await bulkCopy.WriteToServerAsync(dataTable);
        }
    }
}