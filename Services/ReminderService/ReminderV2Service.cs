using Hangfire;
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using HealthCare_.Services.Background.Reminder;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Microsoft.EntityFrameworkCore;
using System.Text.RegularExpressions;
using HealthCare_.Models.EnumForModels;
using IntakeStatus = HealthCare_.Models.EnumForModels.Enums.IntakeStatus;
using OccurrenceStatus = HealthCare_.Models.EnumForModels.Enums.OccurrenceStatus;
using ReminderStatus = HealthCare_.Models.EnumForModels.Enums.ReminderStatus;
using ReminderType = HealthCare_.Models.EnumForModels.Enums.ReminderType;

namespace HealthCare_.Services
{
    public class ReminderV2Service : IReminderV2Service
    {
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<ReminderV2Service> _logger;

        public ReminderV2Service(HealthCarePlusContext context, ILogger<ReminderV2Service> logger)
        {
            _context = context;
            _logger = logger;
        }

        private static DateTime EnsureUtc(DateTime dt) =>
            dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);

        private DateTime ConvertUtcToUserTimezone(DateTime utcDateTime, string timeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId ?? "Africa/Cairo");
            return TimeZoneInfo.ConvertTimeFromUtc(EnsureUtc(utcDateTime), tz);
        }
        private DateTime ConvertUserTimezoneToUtc(DateTime userDateTime, string timeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId ?? "Africa/Cairo");
            var unspecified = DateTime.SpecifyKind(userDateTime, DateTimeKind.Unspecified);
            return TimeZoneInfo.ConvertTimeToUtc(unspecified, tz);
        }

        #region ==================== CREATE & UPDATE ====================

        public async Task<ReminderV2> CreateAsync(int patientId, CreateReminderV2Dto dto)
        {
            var userTimeZone = dto.TimeZoneId ?? "Africa/Cairo";

            // ✅ CRITICAL FIX: Don't strip time with .Date!
            // Store the FULL UTC datetime, not just date component
            var startDateUtc = ConvertUserTimezoneToUtc(dto.StartDate, userTimeZone);
            var endDateUtc = dto.EndDate.HasValue
                ? ConvertUserTimezoneToUtc(dto.EndDate.Value, userTimeZone)
                : (DateTime?)null;

            _logger.LogInformation(
                "Creating reminder: StartDate (User)={UserStart}, StartDateUtc={UtcStart}, TimeZone={TZ}",
                dto.StartDate, startDateUtc, userTimeZone);

            var reminder = new ReminderV2
            {
                PatientId = patientId,
                Type = dto.Type,
                Title = dto.Title.Trim(),
                Message = dto.Message?.Trim(),
                StartDateUtc = startDateUtc,  //  Full UTC datetime
                EndDateUtc = endDateUtc,      //  Full UTC datetime
                TimeZoneId = userTimeZone,
                PrescriptionMedId = dto.PrescriptionMedId,
                AppointmentId = dto.AppointmentId,
                IsActive = true,
                IsSimpleEveryXHours = false,
                FirstDoseTime = null,
                IntervalHours = null,
                RRULE = null
            };

            // ═══════════════════════════════════════════════════════════
            // MODE 1: SIMPLE MODE (EveryXHours)
            // ═══════════════════════════════════════════════════════════
            if (dto.Simple?.Frequency == "EveryXHours" && dto.Simple.Times?.Any() == true)
            {
                reminder.IsSimpleEveryXHours = true;
                reminder.FirstDoseTime = TimeSpan.Parse(dto.Simple.Times.First());
                reminder.IntervalHours = dto.Simple.IntervalHours ?? 8;
                reminder.RRULE = null;

                _logger.LogInformation(
                    "Reminder {Id} created in SIMPLE MODE: FirstDose={FirstDose}, Interval={Interval}h",
                    reminder.Id, reminder.FirstDoseTime, reminder.IntervalHours);

                if (reminder.IntervalHours <= 0 || reminder.IntervalHours > 24)
                {
                    throw new ArgumentException("IntervalHours must be between 1 and 24");
                }
            }
            // ═══════════════════════════════════════════════════════════
            // MODE 2: RRULE MODE (Full RFC 5545)
            // ═══════════════════════════════════════════════════════════
            else if (!string.IsNullOrWhiteSpace(dto.RRULE))
            {
                reminder.IsSimpleEveryXHours = false;
                reminder.RRULE = dto.RRULE.Trim().ToUpperInvariant();
                reminder.FirstDoseTime = null;
                reminder.IntervalHours = null;

                try
                {
                    var testPattern = new RecurrencePattern(reminder.RRULE);
                    _logger.LogInformation(
                        "Reminder {Id} created in RRULE MODE: {RRULE}",
                        reminder.Id, reminder.RRULE);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Invalid RRULE syntax: {RRULE}", reminder.RRULE);
                    throw new ArgumentException($"Invalid RRULE: {ex.Message}", nameof(dto.RRULE));
                }
            }
            else
            {
                throw new ArgumentException(
                    "Reminder must specify either Simple (EveryXHours with Times) or RRULE");
            }

            _context.ReminderV2s.Add(reminder);
            await _context.SaveChangesAsync();

            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(
                j => j.GenerateForPatientAsync(patientId));

            return reminder;
        }

        public async Task UpdateAsync(int reminderId, int patientId, UpdateReminderV2Dto dto)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            var userTimeZone = reminder.TimeZoneId;

            if (!string.IsNullOrWhiteSpace(dto.Title))
                reminder.Title = dto.Title.Trim();
            if (dto.Message != null)
                reminder.Message = dto.Message.Trim();

            // ✅ CRITICAL FIX: Store full UTC datetime, not just date
            if (dto.StartDate.HasValue)
                reminder.StartDateUtc = ConvertUserTimezoneToUtc(dto.StartDate.Value, userTimeZone);
            if (dto.EndDate.HasValue)
                reminder.EndDateUtc = ConvertUserTimezoneToUtc(dto.EndDate.Value, userTimeZone);

            if (dto.TimeZoneId != null)
            {
                userTimeZone = dto.TimeZoneId;
                reminder.TimeZoneId = dto.TimeZoneId;
            }
            if (dto.IsActive.HasValue)
                reminder.IsActive = dto.IsActive.Value;

            // Handle mode updates
            if (dto.Simple != null && dto.Simple.Frequency == "EveryXHours" && dto.Simple.Times?.Any() == true)
            {
                reminder.IsSimpleEveryXHours = true;
                reminder.FirstDoseTime = TimeSpan.Parse(dto.Simple.Times.First());
                reminder.IntervalHours = dto.Simple.IntervalHours ?? 8;
                reminder.RRULE = null;

                _logger.LogInformation(
                    "Reminder {Id} updated to SIMPLE MODE: FirstDose={FirstDose}, Interval={Interval}h",
                    reminder.Id, reminder.FirstDoseTime, reminder.IntervalHours);
            }
            else if (!string.IsNullOrWhiteSpace(dto.RRULE))
            {
                reminder.IsSimpleEveryXHours = false;
                reminder.RRULE = dto.RRULE.Trim().ToUpperInvariant();
                reminder.FirstDoseTime = null;
                reminder.IntervalHours = null;

                try
                {
                    var testPattern = new RecurrencePattern(reminder.RRULE);
                    _logger.LogInformation(
                        "Reminder {Id} updated to RRULE MODE: {RRULE}",
                        reminder.Id, reminder.RRULE);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Invalid RRULE syntax: {RRULE}", reminder.RRULE);
                    throw new ArgumentException($"Invalid RRULE: {ex.Message}", nameof(dto.RRULE));
                }
            }

            reminder.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(
                j => j.GenerateForPatientAsync(patientId));
        }

        #endregion

        #region ==================== GET TODAY & UPCOMING ====================

        public async Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId)
        {
            var todayUtc = DateTime.UtcNow.Date;
            var tomorrowUtc = todayUtc.AddDays(1);
            return await GetFromCacheWithTimezonConversion(patientId, todayUtc, tomorrowUtc);
        }

        public async Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30)
        {
            var fromUtc = DateTime.UtcNow.Date;
            var toUtc = fromUtc.AddDays(daysAhead);
            return await GetFromCacheWithTimezonConversion(patientId, fromUtc, toUtc);
        }

        private async Task<List<UpcomingOccurrenceDto>> GetFromCacheWithTimezonConversion(
            int patientId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            var fromUtc = EnsureUtc(fromUtcInclusive);
            var toUtc = EnsureUtc(toUtcExclusive);
            var nowUtc = DateTime.UtcNow;

            var cached = await _context.ReminderOccurrencesCache
                .AsNoTracking()
                .Where(x => x.PatientId == patientId
                         && x.DueDateTimeUtc >= fromUtc
                         && x.DueDateTimeUtc < toUtc)
                .OrderBy(x => x.DueDateTimeUtc)
                .ToListAsync();

            if (!cached.Any())
            {
                _logger.LogWarning("Cache miss for patient {PatientId}", patientId);
                try
                {
                    var result = await GenerateUpcomingOnTheFly(patientId, fromUtc, toUtc);
                    BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(
                        j => j.GenerateForPatientAsync(patientId));
                    return result;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error generating upcoming reminders for patient {PatientId}", patientId);
                    return new List<UpcomingOccurrenceDto>();
                }
            }

            return cached.Select(x =>
            {
                var displayStatus = DeriveDisplayStatus(x.Status, EnsureUtc(x.DueDateTimeUtc), nowUtc);
                var (canConfirm, canSnooze, canSkip, reason) = EvaluateActionAvailability(
                    displayStatus,
                    EnsureUtc(x.DueDateTimeUtc),
                    nowUtc
                );

                return new UpcomingOccurrenceDto
                {
                    ReminderId = x.ReminderId,
                    Title = x.Title,
                    Message = x.Message ?? string.Empty,
                    DueDateTime = x.DueDateTime,
                    TimeZoneId = x.TimeZoneId,
                    Type = x.Type,
                    IsMedication = x.Type == Enums.ReminderType.Medication,
                    Dosage = x.Dosage,
                    Status = displayStatus,
                    CanConfirm = canConfirm,
                    CanSnooze = canSnooze,
                    CanSkip = canSkip,
                    ActionUnavailableReason = reason
                };
            }).ToList();
        }

        //private static Enums.ReminderStatus GetStatus(byte status, DateTime dueDateTimeUtc, DateTime nowUtc)
        //{
        //    return status switch
        //    {
        //        1 => Enums.ReminderStatus.Completed,
        //        2 => Enums.ReminderStatus.Skipped,
        //        _ => dueDateTimeUtc < nowUtc.AddMinutes(-30)
        //            ? ReminderStatus.Dismissed
        //            : ReminderStatus.Pending    
        //    };
        //}

        #endregion

        #region ==================== OCCURRENCE GENERATOR ====================

        //private async Task<List<UpcomingOccurrenceDto>> GenerateUpcomingOnTheFly(
        //    int patientId,
        //    DateTime fromUtcInclusive,
        //    DateTime toUtcExclusive)
        //{
        //    var reminders = await _context.ReminderV2s
        //        .AsNoTracking()
        //        .Where(r => r.PatientId == patientId && r.IsActive)
        //        .ToListAsync();

        //    var result = new List<UpcomingOccurrenceDto>();
        //    var nowUtc = DateTime.UtcNow;

        //    foreach (var reminder in reminders)
        //    {
        //        try
        //        {
        //            var occurrences = GenerateOccurrencesWithIcalNetFull(reminder, fromUtcInclusive, toUtcExclusive);

        //            foreach (var dtUtc in occurrences)
        //            {
        //                result.Add(new UpcomingOccurrenceDto
        //                {
        //                    ReminderId = reminder.Id,
        //                    Title = reminder.Title,
        //                    Message = reminder.Message ?? string.Empty,
        //                    DueDateTime = ConvertUtcToUserTimezone(EnsureUtc(dtUtc), reminder.TimeZoneId),
        //                    Type = reminder.Type,
        //                    IsMedication = reminder.Type == ReminderType.Medication,
        //                    Dosage = reminder.PrescriptionMed != null
        //                        ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
        //                        : null,
        //                    Status = dtUtc < nowUtc.AddMinutes(-30) ? ReminderStatus.Overdue : ReminderStatus.Pending,
        //                    CanSnooze = true
        //                });
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            _logger.LogError(ex, "Error generating occurrences for reminder {ReminderId}", reminder.Id);
        //        }
        //    }

        //    return result.OrderBy(x => x.DueDateTime).ToList();
        //}
        private async Task<List<UpcomingOccurrenceDto>> GenerateUpcomingOnTheFly(
    int patientId,
    DateTime fromUtcInclusive,
    DateTime toUtcExclusive)
        {
            var reminders = await _context.ReminderV2s
                .AsNoTracking()
                .Where(r => r.PatientId == patientId && r.IsActive)
                .ToListAsync();

            var result = new List<UpcomingOccurrenceDto>();
            var nowUtc = DateTime.UtcNow;

            foreach (var reminder in reminders)
            {
                try
                {
                    var occurrences = GenerateOccurrencesWithIcalNetFull(reminder, fromUtcInclusive, toUtcExclusive);

                    foreach (var dtUtc in occurrences)
                    {
                        var displayStatus = dtUtc < nowUtc.AddMinutes(-30)
                            ? OccurrenceStatus.Missed    //  FIXED
                            : OccurrenceStatus.Pending;  //  FIXED

                        var (canConfirm, canSnooze, canSkip, reason) = EvaluateActionAvailability(
                            displayStatus,
                            dtUtc,
                            nowUtc
                        );

                        result.Add(new UpcomingOccurrenceDto
                        {
                            ReminderId = reminder.Id,
                            Title = reminder.Title,
                            Message = reminder.Message ?? string.Empty,
                            DueDateTime = ConvertUtcToUserTimezone(EnsureUtc(dtUtc), reminder.TimeZoneId),
                            TimeZoneId = reminder.TimeZoneId,
                            Type = reminder.Type,
                            IsMedication = reminder.Type == ReminderType.Medication,
                            Dosage = reminder.PrescriptionMed != null
                                ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                                : null,
                            Status = displayStatus,       // FIXED
                            CanConfirm = canConfirm,
                            CanSnooze = canSnooze,
                            CanSkip = canSkip,
                            ActionUnavailableReason = reason
                        });
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error generating occurrences for reminder {ReminderId}", reminder.Id);
                }
            }

            return result.OrderBy(x => x.DueDateTime).ToList();
        }


        /// ✅ CORRECT IMPLEMENTATION:
        /// - SIMPLE MODE (IsSimpleEveryXHours=true, RRULE=NULL): Use FirstDoseTime + IntervalHours directly
        /// - RRULE MODE (IsSimpleEveryXHours=false, RRULE!=NULL): Parse RRULE string with full iCalendar power
        /// NO CONVERSION between modes - keep them completely separate
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

                // ✅ MODE 1: SIMPLE EVERY X HOURS (RRULE = NULL)
                if (reminder.IsSimpleEveryXHours && reminder.FirstDoseTime.HasValue && reminder.IntervalHours.HasValue)
                {
                    _logger.LogDebug(
                        "Reminder {Id} SIMPLE MODE: FirstDose={FirstDose}, Interval={Interval}h (RRULE=NULL)",
                        reminder.Id, reminder.FirstDoseTime, reminder.IntervalHours);

                    var dtStart = DateTime.SpecifyKind(reminder.StartDateUtc.Date, DateTimeKind.Unspecified);
                    dtStart = dtStart.Add(reminder.FirstDoseTime.Value);

                    var dtStartUtc = TimeZoneInfo.ConvertTimeToUtc(
                        DateTime.SpecifyKind(dtStart, DateTimeKind.Unspecified), tz);

                    ev.DtStart = new CalDateTime(dtStart, timeZoneId);
                    ev.Summary = reminder.Title;

                    var rruleStr = $"FREQ=HOURLY;INTERVAL={reminder.IntervalHours.Value}";
                    if (reminder.EndDateUtc.HasValue)
                    {
                        var untilLocal = DateTime.SpecifyKind(
                            reminder.EndDateUtc.Value.Date.AddDays(1).AddTicks(-1),
                            DateTimeKind.Unspecified);
                        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                        rruleStr += $";UNTIL={untilUtc:yyyyMMddTHHmmss}Z";
                    }

                    ev.RecurrenceRules.Add(new RecurrencePattern(rruleStr));
                    _logger.LogDebug("Generated RRULE for simple mode: {RRULE}", rruleStr);
                }
                // ✅ MODE 2: RRULE (Full iCalendar recurrence power)
                else if (!string.IsNullOrWhiteSpace(reminder.RRULE))
                {
                    _logger.LogDebug(
                        "Reminder {Id} RRULE MODE: {RRULE}",
                        reminder.Id, reminder.RRULE);

                    // ************** MODIFIED BLOCK START **************

                    // Convert original UTC StartDate to LOCAL TIME
                    var startLocal = TimeZoneInfo.ConvertTimeFromUtc(reminder.StartDateUtc, tz);

                    // Default dtStart = full local datetime (date + time)
                    var dtStart = DateTime.SpecifyKind(startLocal, DateTimeKind.Unspecified);

                    var rrule = reminder.RRULE.ToUpperInvariant();

                    // If RRULE contains BYHOUR: override dtStart time
                    if (rrule.Contains("BYHOUR"))
                    {
                        var match = Regex.Match(rrule, @"BYHOUR=(\d+)");
                        if (match.Success)
                        {
                            var hour = int.Parse(match.Groups[1].Value);
                            dtStart = new DateTime(dtStart.Year, dtStart.Month, dtStart.Day, hour, 0, 0);
                            dtStart = DateTime.SpecifyKind(dtStart, DateTimeKind.Unspecified);
                        }
                    }
                    else
                    {
                        // Default to 9 AM
                        dtStart = new DateTime(dtStart.Year, dtStart.Month, dtStart.Day, 9, 0, 0);
                        dtStart = DateTime.SpecifyKind(dtStart, DateTimeKind.Unspecified);
                    }

                    // ************** MODIFIED BLOCK END **************

                    ev.DtStart = new CalDateTime(dtStart, timeZoneId);
                    ev.Summary = reminder.Title;

                    try
                    {
                        ev.RecurrenceRules.Add(new RecurrencePattern(rrule));
                        _logger.LogDebug("RRULE parsed successfully: {RRULE}", rrule);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex,
                            "Failed to parse RRULE for Reminder {ReminderId}: {RRULE}. Error: {Error}",
                            reminder.Id, reminder.RRULE, ex.Message);
                        throw;
                    }
                }
                else
                {
                    throw new InvalidOperationException(
                        $"Reminder {reminder.Id} is in invalid state: " +
                        $"IsSimpleEveryXHours={reminder.IsSimpleEveryXHours}, " +
                        $"FirstDoseTime={reminder.FirstDoseTime}, " +
                        $"IntervalHours={reminder.IntervalHours}, " +
                        $"RRULE={reminder.RRULE}");
                }

                //  Add end date limit if not already in RRULE
                if (reminder.EndDateUtc.HasValue && !reminder.RRULE?.ToUpperInvariant().Contains("UNTIL") == true)
                {
                    if (ev.RecurrenceRules.Any())
                    {
                        var untilLocal = DateTime.SpecifyKind(
                            reminder.EndDateUtc.Value.Date.AddDays(1).AddTicks(-1),
                            DateTimeKind.Unspecified);
                        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                        ev.RecurrenceRules[0].Until = untilUtc;
                    }
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
                    var utcTime = TimeZoneInfo.ConvertTimeToUtc(
                        DateTime.SpecifyKind(localTime, DateTimeKind.Unspecified),
                        tz);

                    if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
                    {
                        results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
                    }
                }

                _logger.LogInformation("Reminder {Id}: Generated {Count} occurrences", reminder.Id, results.Count);
                return results.OrderBy(dt => dt);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Critical error generating occurrences for reminder {ReminderId}", reminder.Id);
                throw;
            }
        }


        #endregion

        #region ==================== CONFIRM / SNOOZE / SKIP ====================

        public async Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, Enums.IntakeStatus intake = IntakeStatus.Taken)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                //  Get reminder to access timezone
                var reminder = await ValidateReminderAccess(reminderId, patientId);

                //  CORRECT: Convert user's local time to UTC
                var dueDateTimeUtc = ConvertUserTimezoneToUtc(dueDateTime, reminder.TimeZoneId);
                var nowUtc = DateTime.UtcNow;

                _logger.LogInformation(
                    "Confirming: Reminder={ReminderId}, DueLocal={DueLocal}, DueUtc={DueUtc}, Patient={PatientId}",
                    reminderId, dueDateTime, dueDateTimeUtc, patientId);

                // Validate timing
                ValidateActionTiming(dueDateTimeUtc, "confirm");

                // Check for duplicate
                var existingLog = await _context.ReminderOccurrenceLogs
                    .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTimeUtc == dueDateTimeUtc);

                if (existingLog?.Status == OccurrenceStatus.Taken)
                {
                    _logger.LogInformation("Idempotent confirm - already taken: {ReminderId} at {Due}", reminderId, dueDateTimeUtc);
                    await transaction.CommitAsync();
                    return;
                }

                var log = existingLog ?? new ReminderOccurrenceLog
                {
                    ReminderId = reminderId,
                    DueDateTimeUtc = dueDateTimeUtc,
                    DueDateTime = dueDateTime,
                    PatientId = patientId
                };

                log.Status = OccurrenceStatus.Taken;
                log.IntakeStatus = intake;
                log.ConfirmedAt = nowUtc;
                log.ActionedAt = nowUtc;
                log.ActionedWithinWindow = true;

                if (log.Id == 0)
                    _context.ReminderOccurrenceLogs.Add(log);

                await _context.SaveChangesAsync();

                // Update cache with validation
                var rowsAffected = await _context.Database.ExecuteSqlInterpolatedAsync($@"
            UPDATE ReminderOccurrencesCache 
            SET Status = {(byte)OccurrenceStatus.Taken}, 
                UpdatedAt = GETUTCDATE()
            WHERE ReminderId = {reminderId} 
              AND DueDateTimeUtc = {dueDateTimeUtc}");

                if (rowsAffected == 0)
                {
                    _logger.LogWarning(
                        "Cache miss on confirm: Reminder={ReminderId}, Due={Due}. Queuing regeneration.",
                        reminderId, dueDateTimeUtc);
                }

                await transaction.CommitAsync();

                _logger.LogInformation(
                    "Confirmed occurrence: Reminder={ReminderId}, DueUtc={Due}, CacheHit={Hit}",
                    reminderId, dueDateTimeUtc, rowsAffected > 0);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to confirm: Reminder={ReminderId}, DueLocal={Due}, Patient={PatientId}",
                    reminderId, dueDateTime, patientId);
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task SnoozeOccurrenceAsync(int reminderId, DateTime originalDue, int patientId, int minutes = 15)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // FIX: Get reminder FIRST to access timezone
                var reminder = await ValidateReminderAccess(reminderId, patientId);

                // FIX: Convert user's local time to UTC properly
                var originalDueUtc = ConvertUserTimezoneToUtc(originalDue, reminder.TimeZoneId);
                var newDueUtc = originalDueUtc.AddMinutes(minutes);

                _logger.LogInformation(
                    "Snoozing occurrence: Reminder={ReminderId}, OriginalDueLocal={OriginalLocal}, OriginalDueUtc={OriginalUtc}, Minutes={Minutes}",
                    reminderId, originalDue, originalDueUtc, minutes);

                // Validate timing
                ValidateActionTiming(originalDueUtc, "snooze");

                // Mark original as snoozed
                var log = await _context.ReminderOccurrenceLogs
                    .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTimeUtc == originalDueUtc)
                    ?? new ReminderOccurrenceLog
                    {
                        ReminderId = reminderId,
                        DueDateTimeUtc = originalDueUtc,
                        DueDateTime = originalDue,
                        PatientId = patientId
                    };

                log.Status = OccurrenceStatus.Snoozed;
                log.ActionedAt = DateTime.UtcNow;

                if (log.Id == 0)
                    _context.ReminderOccurrenceLogs.Add(log);

                // Create new occurrence
                var newDueLocal = ConvertUtcToUserTimezone(newDueUtc, reminder.TimeZoneId);

                var newLog = new ReminderOccurrenceLog
                {
                    ReminderId = reminderId,
                    PatientId = patientId,
                    DueDateTimeUtc = newDueUtc,
                    DueDateTime = newDueLocal,
                    Status = OccurrenceStatus.Pending,
                    IsSnoozeFromOriginal = true,
                    OriginalDueDateTime = originalDueUtc,
                    CreatedAt = DateTime.UtcNow
                };
                _context.ReminderOccurrenceLogs.Add(newLog);

                await _context.SaveChangesAsync();

                // Update cache
                await _context.Database.ExecuteSqlInterpolatedAsync($@"
                    UPDATE ReminderOccurrencesCache 
                    SET Status = {(byte)OccurrenceStatus.Snoozed}
                    WHERE ReminderId = {reminderId} AND DueDateTimeUtc = {originalDueUtc};
                    
                    INSERT INTO ReminderOccurrencesCache 
                        (PatientId, ReminderId, DueDateTimeUtc, DueDateTime, Title, Message, Type, Status, TimeZoneId, CreatedAt)
                    SELECT PatientId, ReminderId, {newDueUtc}, {newDueLocal}, Title, Message, Type, {(byte)OccurrenceStatus.Pending}, TimeZoneId, GETUTCDATE()
                    FROM ReminderOccurrencesCache
                    WHERE ReminderId = {reminderId} AND DueDateTimeUtc = {originalDueUtc};
                ");

                await transaction.CommitAsync();

                _logger.LogInformation(
                    "Successfully snoozed occurrence: Reminder={ReminderId}, OriginalDue={Original}, NewDue={New}",
                    reminderId, originalDueUtc, newDueUtc);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to snooze occurrence: Reminder={ReminderId}, DueLocal={Due}, Patient={PatientId}",
                    reminderId, originalDue, patientId);
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId)
        {
            var dueDateTimeUtc = EnsureUtc(dueDateTime);

            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                await ValidateReminderAccess(reminderId, patientId);

                // Skip is ALWAYS allowed (for record-keeping)

                var log = await _context.ReminderOccurrenceLogs
                    .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTimeUtc == dueDateTimeUtc)
                    ?? new ReminderOccurrenceLog
                    {
                        ReminderId = reminderId,
                        DueDateTimeUtc = dueDateTimeUtc,
                        DueDateTime = dueDateTime,
                        PatientId = patientId
                    };

                log.Status = OccurrenceStatus.Skipped;
                log.IntakeStatus = IntakeStatus.Skipped;
                log.ActionedAt = DateTime.UtcNow;

                if (log.Id == 0)
                    _context.ReminderOccurrenceLogs.Add(log);

                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlInterpolatedAsync($@"
            UPDATE ReminderOccurrencesCache 
            SET Status = {(byte)OccurrenceStatus.Skipped}, 
                UpdatedAt = GETUTCDATE()
            WHERE ReminderId = {reminderId} 
              AND DueDateTimeUtc = {dueDateTimeUtc}");

                await transaction.CommitAsync();
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        #endregion

        #region ==================== CRUD & HELPERS ====================

        public async Task<ReminderV2Dto> GetByIdAsync(int reminderId, int patientId)
        {
            var reminder = await _context.ReminderV2s
                .AsNoTracking()
                .Include(r => r.PrescriptionMed)
                .FirstOrDefaultAsync(r => r.Id == reminderId && r.PatientId == patientId)
                ?? throw new KeyNotFoundException("Reminder not found");

            return await MapToDtoAsync(reminder);
        }

        public async Task<List<ReminderV2Dto>> GetAllAsync(int patientId)
        {
            var reminders = await _context.ReminderV2s
                .AsNoTracking()
                .Where(r => r.PatientId == patientId)
                .ToListAsync();

            var result = new List<ReminderV2Dto>();
            foreach (var r in reminders)
            {
                result.Add(await MapToDtoAsync(r));
            }
            return result;
        }

        public async Task SoftDeleteAsync(int reminderId, int patientId)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            reminder.IsActive = false;
            reminder.Status = Enums.ReminderStatus.Dismissed;
            reminder.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(j => j.GenerateForPatientAsync(patientId));
        }

        private async Task<ReminderV2> ValidateReminderAccess(int reminderId, int patientId)
        {
            var reminder = await _context.ReminderV2s
                .FirstOrDefaultAsync(r => r.Id == reminderId && r.PatientId == patientId);
            return reminder ?? throw new UnauthorizedAccessException("Access denied or reminder not found");
        }

        private async Task<ReminderV2Dto> MapToDtoAsync(ReminderV2 r)
        {
            var todayUtc = DateTime.UtcNow.Date;
            var next = await _context.ReminderOccurrencesCache
                .Where(c => c.ReminderId == r.Id && c.DueDateTimeUtc >= todayUtc)
                .OrderBy(c => c.DueDateTimeUtc)
                .Select(c => (DateTime?)c.DueDateTimeUtc)
                .FirstOrDefaultAsync();

            // FIX: Use OccurrenceStatus.Taken instead of ReminderStatus.Completed
            var taken = await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == r.Id && l.Status == OccurrenceStatus.Taken);

            var total = await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == r.Id);

            var nextOccurrence = next.HasValue
                ? ConvertUtcToUserTimezone(EnsureUtc(next.Value), r.TimeZoneId)
                : (DateTime?)null;

            return new ReminderV2Dto
            {
                Id = r.Id,
                Title = r.Title,
                Type = r.Type,
                Message = r.Message,
                StartDate = r.StartDateUtc,
                EndDate = r.EndDateUtc,
                TimeZoneId = r.TimeZoneId,
                RRULE = r.RRULE ?? "",
                EXDATE = r.EXDATE,
                IsSimpleEveryXHours = r.IsSimpleEveryXHours,
                FirstDoseTime = r.FirstDoseTime,
                IntervalHours = r.IntervalHours,
                NextOccurrence = nextOccurrence,
                TakenCount = taken,
                TotalLogged = total,
                IsActive = r.IsActive
            };
        }

        #endregion

        // Add this at the top of ReminderV2Service.cs, inside the class

        #region ==================== TEMPORAL VALIDATION HELPERS ====================

        private const int WINDOW_OPENS_MINUTES = 30;
        private const int GRACE_PERIOD_HOURS = 2;
        private const int OVERDUE_THRESHOLD_MINUTES = 30;

        //private void ValidateActionTiming(DateTime dueTimeUtc, string actionName)
        //{
        //    var nowUtc = DateTime.UtcNow;
        //    var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

        //    if (minutesFromDue < -WINDOW_OPENS_MINUTES)
        //    {
        //        var minutesUntilAvailable = Math.Abs(minutesFromDue + WINDOW_OPENS_MINUTES);
        //        throw new InvalidOperationException(
        //            $"Cannot {actionName} medication {Math.Abs(minutesFromDue):F0} minutes before scheduled time. " +
        //            $"Available in {minutesUntilAvailable:F0} minutes.");
        //    }

        //    if (actionName != "skip" && minutesFromDue > (GRACE_PERIOD_HOURS * 60))
        //    {
        //        throw new InvalidOperationException(
        //            $"Action window expired {(minutesFromDue - (GRACE_PERIOD_HOURS * 60)):F0} minutes ago. " +
        //            $"Please skip if medication was not taken.");
        //    }
        //}
        private void ValidateActionTiming(DateTime dueTimeUtc, string actionName)
        {
            var nowUtc = DateTime.UtcNow;
            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            const int ALLOWED_BEFORE_MINUTES = 30;
            const int ALLOWED_AFTER_HOURS = 24;

            // Too early: earlier than due - 30 minutes
            if (minutesFromDue < -ALLOWED_BEFORE_MINUTES)
            {
                var minutesUntilAllowed = Math.Abs(minutesFromDue + ALLOWED_BEFORE_MINUTES);

                throw new InvalidOperationException(
                    $"Cannot {actionName} medication yet. " +
                    $"Available in {minutesUntilAllowed:F0} minutes."
                );
            }

            // Too late: later than due + 24 hours
            if (minutesFromDue > ALLOWED_AFTER_HOURS * 60)
            {
                throw new InvalidOperationException(
                    $"Action window expired {(minutesFromDue - ALLOWED_AFTER_HOURS * 60):F0} minutes ago."
                );
            }
        }


        private static Enums.OccurrenceStatus DeriveDisplayStatus(Enums.OccurrenceStatus storedStatus, DateTime dueTimeUtc, DateTime nowUtc)
        {
            // If already in final state, return as-is
            if (storedStatus is OccurrenceStatus.Taken or OccurrenceStatus.Skipped or OccurrenceStatus.Snoozed)
                return storedStatus;

            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            // Scheduled → Pending transition
            if (storedStatus == OccurrenceStatus.Scheduled && minutesFromDue >= -WINDOW_OPENS_MINUTES)
                return OccurrenceStatus.Pending;

            // Pending → Missed transition
            if (storedStatus == OccurrenceStatus.Pending && minutesFromDue > OVERDUE_THRESHOLD_MINUTES)
                return OccurrenceStatus.Missed;

            // Missed → Expired transition
            if (storedStatus == OccurrenceStatus.Missed && minutesFromDue > (GRACE_PERIOD_HOURS * 60))
                return OccurrenceStatus.Expired;

            return storedStatus;
        }

        private static (bool canConfirm, bool canSnooze, bool canSkip, string? reason) EvaluateActionAvailability(
            OccurrenceStatus status,
            DateTime dueTimeUtc,
            DateTime nowUtc)
        {
            // Final states - no actions allowed except skip for record-keeping
            if (status is OccurrenceStatus.Taken or OccurrenceStatus.Skipped)
                return (false, false, false, "Already completed");

            if (status == OccurrenceStatus.Snoozed)
                return (false, false, false, "Already snoozed");

            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            // Too early
            if (minutesFromDue < -WINDOW_OPENS_MINUTES)
            {
                var minutesUntil = Math.Abs(minutesFromDue + WINDOW_OPENS_MINUTES);
                return (false, false, false, $"Available in {minutesUntil:F0} minutes");
            }

            // Expired
            if (minutesFromDue > (GRACE_PERIOD_HOURS * 60))
                return (false, false, true, "Window expired");

            // Within action window
            return (true, true, true, null);
        }

        #endregion
    }
}