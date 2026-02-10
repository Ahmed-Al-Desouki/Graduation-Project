// Infrastructure/BackgroundJobs/ReminderOccurrenceGenerator.cs
using HealthCare_.Models.V2;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.Text.RegularExpressions;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs
{
    public class ReminderOccurrenceGenerator : IReminderOccurrenceGenerator
    {
        private readonly System.IServiceProvider _serviceProvider;
        private readonly ILogger<ReminderOccurrenceGenerator> _logger;

        public ReminderOccurrenceGenerator(
            System.IServiceProvider serviceProvider,
            ILogger<ReminderOccurrenceGenerator> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        public async Task GenerateForAllPatientsAsync()
        {
            await using var scope = _serviceProvider.CreateAsyncScope();
            var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();

            var patientIds = await reminderRepo.GetAllActivePatientIdsAsync();

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
            var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
            var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

            var nowUtc = DateTime.UtcNow;
            var todayUtc = nowUtc.Date;
            var fromUtc = todayUtc;
            var toUtc = todayUtc.AddDays(60);

            _logger.LogInformation(
                "Generating cache for Patient {PatientId}: From {From} to {To} UTC",
                patientId, fromUtc, toUtc);

            // ✅ SOFT DELETE: Mark expired reminders as inactive instead of deleting
            var reminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);

            var expiredReminders = reminders
                .Where(r => r.EndDateUtc.HasValue && r.EndDateUtc.Value < nowUtc)
                .ToList();

            if (expiredReminders.Any())
            {
                _logger.LogInformation(
                    "🗑️ Soft deleting {Count} expired reminders for Patient {PatientId}",
                    expiredReminders.Count,
                    patientId);

                foreach (var expired in expiredReminders)
                {
                    expired.IsActive = false;
                    expired.Status = Enums.ReminderStatus.Dismissed;
                    expired.UpdatedAt = nowUtc;
                    await reminderRepo.UpdateAsync(expired);
                }

                _logger.LogInformation(
                    "✅ Soft deleted expired reminders for Patient {PatientId}",
                    patientId);
            }

            // Delete past cache
            await cacheRepo.DeletePastOccurrencesAsync(patientId, todayUtc);

            _logger.LogInformation(
                "Deleted past occurrences for Patient {PatientId} before {Today}",
                patientId, todayUtc);

            // Reload active reminders (excluding the ones we just soft-deleted)
            reminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);

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

                    var occurrences = GenerateOccurrencesWithIcalNetFull(
                        reminder, fromUtc, toUtc);

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
                            //Dosage = reminder.PrescriptionMed != null
                            //    ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                            //    : null,
                            Status = Enums.OccurrenceStatus.Scheduled
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
                _logger.LogInformation(
                    "No new occurrences for Patient {PatientId}",
                    patientId);
                return;
            }

            // Delete existing cache for range
            await cacheRepo.DeleteByPatientAndDateRangeAsync(patientId, fromUtc, toUtc);

            // Bulk insert new cache
            await cacheRepo.BulkInsertAsync(newEntries);

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

                // MODE 1: SIMPLE MODE
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
                // MODE 2: RRULE MODE
                else if (!string.IsNullOrWhiteSpace(reminder.RRULE))
                {
                    _logger.LogDebug(
                        "Reminder {Id} RRULE MODE: StartDateUtc={Start}, RRULE={RRULE}",
                        reminder.Id, reminder.StartDateUtc, reminder.RRULE);

                    var rrule = reminder.RRULE.ToUpperInvariant();

                    // Extract DTSTART from RRULE if provided
                    DateTime? dtStartFromRRule = ExtractDtStartFromRRule(reminder.RRULE, timeZoneId);

                    DateTime dtStartLocal;

                    if (dtStartFromRRule.HasValue)
                    {
                        dtStartLocal = DateTime.SpecifyKind(dtStartFromRRule.Value, DateTimeKind.Unspecified);

                        _logger.LogInformation(
                            "Reminder {Id}: Using DTSTART from RRULE: {DtStart}",
                            reminder.Id, dtStartLocal);
                    }
                    else
                    {
                        var (hour, minute) = ExtractTimeFromRRule(rrule);

                        var startLocal = TimeZoneInfo.ConvertTimeFromUtc(
                            DateTime.SpecifyKind(reminder.StartDateUtc, DateTimeKind.Utc),
                            tz);

                        dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);

                        if (hour.HasValue)
                        {
                            dtStartLocal = dtStartLocal.AddHours(hour.Value);
                            _logger.LogInformation(
                                "Reminder {Id}: Extracted BYHOUR={Hour} from RRULE",
                                reminder.Id, hour.Value);
                        }
                        else
                        {
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
                            "Reminder {Id}: Calculated DtStart={DtStart}",
                            reminder.Id, dtStartLocal);
                    }

                    ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
                    ev.Summary = reminder.Title;

                    try
                    {
                        var cleanRRule = RemoveDtStartFromRRule(rrule);
                        var recurrencePattern = new RecurrencePattern(cleanRRule);
                        ev.RecurrenceRules.Add(recurrencePattern);

                        _logger.LogInformation(
                            "Reminder {Id}: RRULE parsed successfully",
                            reminder.Id);
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

        private DateTime? ExtractDtStartFromRRule(string rrule, string timeZoneId)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return null;

            var dtStartMatch = Regex.Match(rrule, @"DTSTART:(\d{8}T\d{6})", RegexOptions.IgnoreCase);
            if (!dtStartMatch.Success)
                return null;

            var dtStartStr = dtStartMatch.Groups[1].Value;

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

        private (int? hour, int? minute) ExtractTimeFromRRule(string rrule)
        {
            int? hour = null;
            int? minute = null;

            if (string.IsNullOrWhiteSpace(rrule))
                return (hour, minute);

            var hourMatch = Regex.Match(rrule, @"BYHOUR=(\d+)", RegexOptions.IgnoreCase);
            if (hourMatch.Success && int.TryParse(hourMatch.Groups[1].Value, out var h))
            {
                hour = h;
            }

            var minuteMatch = Regex.Match(rrule, @"BYMINUTE=(\d+)", RegexOptions.IgnoreCase);
            if (minuteMatch.Success && int.TryParse(minuteMatch.Groups[1].Value, out var m))
            {
                minute = m;
            }

            return (hour, minute);
        }

        private string RemoveDtStartFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return rrule;

            return Regex.Replace(rrule, @"DTSTART:\d{8}T\d{6};?", "", RegexOptions.IgnoreCase).Trim();
        }
    }
}