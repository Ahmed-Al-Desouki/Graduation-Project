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

        public async Task GenerateForAllDoctorsAsync()  
        {
            await using var scope = _serviceProvider.CreateAsyncScope();
            var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
            var DoctorIds = await reminderRepo.GetAllActiveDoctorIdsAsync();
            _logger.LogInformation("Starting cache generation for {Count} Doctors", DoctorIds.Count);
            foreach (var DoctorID in DoctorIds)
            {
                try
                {
                    await GenerateForDoctorAsync(DoctorID); 
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to generate cache for Doctor {DoctorId}", DoctorID); 
                }
            }
        }
        public async Task GenerateForDoctorAsync(int doctorId)
        {
            await using var scope = _serviceProvider.CreateAsyncScope();
            var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
            var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

            var nowUtc = DateTime.UtcNow;
            var todayUtc = nowUtc.Date;
            var fromUtc = todayUtc;
            var toUtc = todayUtc.AddDays(60);

            // جيب التذكيرات اللي DoctorId بتاعها هو الدكتور ده
            var reminders = await reminderRepo.GetActiveByDoctorIdAsync(doctorId);

            var newEntries = new List<ReminderOccurrencesCache>();

            foreach (var reminder in reminders)
            {
                var occurrences = GenerateOccurrencesWithIcalNetFull(reminder, fromUtc, toUtc);
                foreach (var dtUtc in occurrences)
                {
                    var timeZoneId = reminder.TimeZoneId ?? "Africa/Cairo";
                    var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
                    var localTime = TimeZoneInfo.ConvertTimeFromUtc(dtUtc, tz);

                    newEntries.Add(new ReminderOccurrencesCache
                    {
                        CreatedAt = DateTime.UtcNow,
                        PatientId = null,  
                        DoctorId = doctorId,  
                        ReminderId = reminder.Id,
                        DueDateTimeUtc = dtUtc,
                        DueDateTime = localTime,
                        TimeZoneId = timeZoneId,
                        Title = reminder.Title,
                        Message = reminder.Message ?? "",
                        Type = reminder.Type,
                        Status = Enums.OccurrenceStatus.Scheduled
                    });
                }
            }

            if (newEntries.Any())
            {
                await cacheRepo.DeleteByDoctorAndDateRangeAsync(doctorId, fromUtc, toUtc);
                await cacheRepo.BulkInsertAsync(newEntries);
            }
        }


        //public async Task GenerateForPatientAsync(int patientId)
        //{
        //    await using var scope = _serviceProvider.CreateAsyncScope();
        //    var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
        //    var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

        //    var nowUtc = DateTime.UtcNow;
        //    var todayUtc = nowUtc.Date;
        //    var fromUtc = todayUtc;
        //    var toUtc = todayUtc.AddDays(60);

        //    _logger.LogInformation(
        //        "Generating cache for Patient {PatientId}: From {From} to {To} UTC",
        //        patientId, fromUtc, toUtc);

        //    //  SOFT DELETE: Mark expired reminders as inactive instead of deleting
        //    var reminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);

        //    var expiredReminders = reminders
        //        .Where(r => r.EndDateUtc.HasValue && r.EndDateUtc.Value < nowUtc)
        //        .ToList();

        //    if (expiredReminders.Any())
        //    {
        //        _logger.LogInformation(
        //            "🗑️ Soft deleting {Count} expired reminders for Patient {PatientId}",
        //            expiredReminders.Count,
        //            patientId);

        //        foreach (var expired in expiredReminders)
        //        {
        //            expired.IsActive = false;
        //            expired.Status = Enums.ReminderStatus.Dismissed;
        //            expired.UpdatedAt = nowUtc;
        //            await reminderRepo.UpdateAsync(expired);
        //        }

        //        _logger.LogInformation(
        //            " Soft deleted expired reminders for Patient {PatientId}",
        //            patientId);
        //    }

        //    // Delete past cache
        //    await cacheRepo.DeletePastOccurrencesAsync(patientId, todayUtc);

        //    _logger.LogInformation(
        //        "Deleted past occurrences for Patient {PatientId} before {Today}",
        //        patientId, todayUtc);

        //    // Reload active reminders (excluding the ones we just soft-deleted)
        //    reminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);

        //    var newEntries = new List<ReminderOccurrencesCache>();

        //    foreach (var reminder in reminders)
        //    {

        //        try
        //        {
        //            ValidateReminderIntegrity(reminder);

        //            _logger.LogInformation(
        //                "Processing Reminder {ReminderId}: StartDateUtc={StartUtc}, IsSimple={IsSimple}, RRULE={RRULE}",
        //                reminder.Id,
        //                reminder.StartDateUtc,
        //                reminder.IsSimpleEveryXHours,
        //                reminder.RRULE ?? "NULL");

        //            var occurrences = GenerateOccurrencesWithIcalNetFull(
        //                reminder, fromUtc, toUtc);

        //            foreach (var dtUtc in occurrences)
        //            {
        //                var timeZoneId = reminder.TimeZoneId ?? "Africa/Cairo";
        //                var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

        //                var localTime = TimeZoneInfo.ConvertTimeFromUtc(
        //                    DateTime.SpecifyKind(dtUtc, DateTimeKind.Utc),
        //                    tz);

        //                newEntries.Add(new ReminderOccurrencesCache
        //                {
        //                    CreatedAt = DateTime.UtcNow,
        //                    PatientId = patientId,
        //                    DoctorId = null,
        //                    ReminderId = reminder.Id,
        //                    DueDateTimeUtc = DateTime.SpecifyKind(dtUtc, DateTimeKind.Utc),
        //                    DueDateTime = localTime,
        //                    TimeZoneId = timeZoneId,
        //                    Title = reminder.Title,
        //                    Message = reminder.Message ?? "",
        //                    Type = reminder.Type,
        //                    //Dosage = reminder.PrescriptionMed != null
        //                    //    ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
        //                    //    : null,
        //                    Status = Enums.OccurrenceStatus.Scheduled
        //                });
        //            }

        //            _logger.LogInformation(
        //                "Generated {Count} occurrences for Reminder {ReminderId}",
        //                occurrences.Count(),
        //                reminder.Id);
        //        }
        //        catch (Exception ex)
        //        {
        //            _logger.LogError(
        //                ex,
        //                "Failed generating occurrences for Reminder {ReminderId}",
        //                reminder.Id);
        //        }
        //    }

        //    if (!newEntries.Any())
        //    {
        //        _logger.LogInformation(
        //            "No new occurrences for Patient {PatientId}",
        //            patientId);
        //        return;
        //    }

        //    // Delete existing cache for range
        //    await cacheRepo.DeleteByPatientAndDateRangeAsync(patientId, fromUtc, toUtc);

        //    // Bulk insert new cache
        //    await cacheRepo.BulkInsertAsync(newEntries);

        //    _logger.LogInformation(
        //        "Successfully generated {Count} occurrences for Patient {PatientId}",
        //        newEntries.Count,
        //        patientId);
        //}

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

            // SOFT DELETE: Mark expired reminders as inactive
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
            await cacheRepo.DeletePastOccurrencesExcludingPrescriptionsAsync(patientId, todayUtc);

            _logger.LogInformation(
                "Deleted past occurrences for Patient {PatientId} before {Today}",
                patientId, todayUtc);

            // Reload active reminders (excluding the ones we just soft-deleted)
            reminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);

            var newEntries = new List<ReminderOccurrencesCache>();

            foreach (var reminder in reminders)
            {
                // ⚠️ CRITICAL: Skip prescription reminders (handled by PrescriptionReminderOccurrenceGenerator)
                if (reminder.PrescriptionItemId.HasValue)
                {
                    _logger.LogDebug(
                        "⏭️ Skipping Prescription Reminder {ReminderId} - handled by PrescriptionReminderOccurrenceGenerator",
                        reminder.Id);
                    continue;
                }

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
                            DoctorId = null,
                            ReminderId = reminder.Id,
                            DueDateTimeUtc = DateTime.SpecifyKind(dtUtc, DateTimeKind.Utc),
                            DueDateTime = localTime,
                            TimeZoneId = timeZoneId,
                            Title = reminder.Title,
                            Message = reminder.Message ?? "",
                            Type = reminder.Type,
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

        //private IEnumerable<DateTime> GenerateOccurrencesWithIcalNetFull(
        //    ReminderV2 reminder,
        //    DateTime fromUtcInclusive,
        //    DateTime toUtcExclusive)
        //{
        //    try
        //    {
        //        var timeZoneId = reminder.TimeZoneId ?? "Africa/Cairo";
        //        var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

        //        var calendar = new Calendar();
        //        calendar.AddTimeZone(VTimeZone.FromSystemTimeZone(tz));

        //        var ev = new CalendarEvent { Uid = $"reminder-{reminder.Id}" };

        //        // MODE 1: SIMPLE MODE
        //        if (reminder.IsSimpleEveryXHours &&
        //            reminder.FirstDoseTime.HasValue &&
        //            reminder.IntervalHours.HasValue)
        //        {
        //            _logger.LogDebug(
        //                "Reminder {Id} SIMPLE MODE: StartDateUtc={Start}, FirstDose={FirstDose}, Interval={Interval}h",
        //                reminder.Id, reminder.StartDateUtc, reminder.FirstDoseTime, reminder.IntervalHours);

        //            var startLocal = TimeZoneInfo.ConvertTimeFromUtc(
        //                DateTime.SpecifyKind(reminder.StartDateUtc, DateTimeKind.Utc),
        //                tz);

        //            var dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);
        //            dtStartLocal = dtStartLocal.Add(reminder.FirstDoseTime.Value);

        //            ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
        //            ev.Summary = reminder.Title;

        //            var rruleStr = $"FREQ=HOURLY;INTERVAL={reminder.IntervalHours.Value}";

        //            if (reminder.EndDateUtc.HasValue)
        //            {
        //                var endLocal = TimeZoneInfo.ConvertTimeFromUtc(
        //                    DateTime.SpecifyKind(reminder.EndDateUtc.Value, DateTimeKind.Utc),
        //                    tz);

        //                var untilLocal = DateTime.SpecifyKind(
        //                    endLocal.Date.AddDays(1).AddTicks(-1),
        //                    DateTimeKind.Unspecified);
        //                var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
        //                rruleStr += $";UNTIL={untilUtc:yyyyMMddTHHmmss}Z";
        //            }

        //            ev.RecurrenceRules.Add(new RecurrencePattern(rruleStr));
        //        }
        //        // MODE 2: RRULE MODE
        //        else if (!string.IsNullOrWhiteSpace(reminder.RRULE))
        //        {
        //            _logger.LogDebug(
        //                "Reminder {Id} RRULE MODE: StartDateUtc={Start}, RRULE={RRULE}",
        //                reminder.Id, reminder.StartDateUtc, reminder.RRULE);

        //            var rrule = reminder.RRULE.ToUpperInvariant();

        //            // Extract DTSTART from RRULE if provided
        //            DateTime? dtStartFromRRule = ExtractDtStartFromRRule(reminder.RRULE, timeZoneId);

        //            DateTime dtStartLocal;

        //            if (dtStartFromRRule.HasValue)
        //            {
        //                dtStartLocal = DateTime.SpecifyKind(dtStartFromRRule.Value, DateTimeKind.Unspecified);

        //                _logger.LogInformation(
        //                    "Reminder {Id}: Using DTSTART from RRULE: {DtStart}",
        //                    reminder.Id, dtStartLocal);
        //            }
        //            else
        //            {
        //                var (hour, minute) = ExtractTimeFromRRule(rrule);

        //                var startLocal = TimeZoneInfo.ConvertTimeFromUtc(
        //                    DateTime.SpecifyKind(reminder.StartDateUtc, DateTimeKind.Utc),
        //                    tz);

        //                dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);

        //                if (hour.HasValue)
        //                {
        //                    dtStartLocal = dtStartLocal.AddHours(hour.Value);
        //                    _logger.LogInformation(
        //                        "Reminder {Id}: Extracted BYHOUR={Hour} from RRULE",
        //                        reminder.Id, hour.Value);
        //                }
        //                else
        //                {
        //                    dtStartLocal = dtStartLocal.AddHours(9);
        //                }

        //                if (minute.HasValue)
        //                {
        //                    dtStartLocal = dtStartLocal.AddMinutes(minute.Value);
        //                    _logger.LogInformation(
        //                        "Reminder {Id}: Extracted BYMINUTE={Minute} from RRULE",
        //                        reminder.Id, minute.Value);
        //                }

        //                _logger.LogInformation(
        //                    "Reminder {Id}: Calculated DtStart={DtStart}",
        //                    reminder.Id, dtStartLocal);
        //            }

        //            ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
        //            ev.Summary = reminder.Title;

        //            try
        //            {
        //                var cleanRRule = RemoveDtStartFromRRule(rrule);
        //                var recurrencePattern = new RecurrencePattern(cleanRRule);
        //                ev.RecurrenceRules.Add(recurrencePattern);

        //                _logger.LogInformation(
        //                    "Reminder {Id}: RRULE parsed successfully",
        //                    reminder.Id);
        //            }
        //            catch (Exception ex)
        //            {
        //                _logger.LogError(ex, "Invalid RRULE for Reminder {ReminderId}: {RRULE}",
        //                    reminder.Id, reminder.RRULE);
        //                throw new ArgumentException($"Invalid RRULE syntax: {ex.Message}", nameof(reminder.RRULE));
        //            }
        //        }
        //        else
        //        {
        //            throw new InvalidOperationException($"Reminder {reminder.Id} is in invalid state after validation");
        //        }

        //        calendar.Events.Add(ev);

        //        var fromUtcSafe = DateTime.SpecifyKind(fromUtcInclusive, DateTimeKind.Utc);
        //        var toUtcSafe = DateTime.SpecifyKind(toUtcExclusive, DateTimeKind.Utc);

        //        var fromLocal = TimeZoneInfo.ConvertTimeFromUtc(fromUtcSafe, tz);
        //        var toLocal = TimeZoneInfo.ConvertTimeFromUtc(toUtcSafe, tz);

        //        var occurrencesLocal = calendar.GetOccurrences(fromLocal, toLocal);

        //        var results = new List<DateTime>();

        //        foreach (var occ in occurrencesLocal)
        //        {
        //            var localTime = occ.Period.StartTime.AsDateTimeOffset.DateTime;

        //            DateTime utcTime;
        //            try
        //            {
        //                utcTime = TimeZoneInfo.ConvertTimeToUtc(
        //                    DateTime.SpecifyKind(localTime, DateTimeKind.Unspecified),
        //                    tz);
        //            }
        //            catch (ArgumentException ex)
        //            {
        //                _logger.LogWarning(ex,
        //                    "Skipping invalid local time due to DST: {LocalTime}",
        //                    localTime);
        //                continue;
        //            }

        //            if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
        //            {
        //                results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
        //            }
        //        }

        //        _logger.LogInformation(
        //            "Reminder {Id}: Generated {Count} occurrences",
        //            reminder.Id, results.Count);

        //        return results.OrderBy(dt => dt);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Critical error generating occurrences for reminder {ReminderId}", reminder.Id);
        //        throw;
        //    }
        //}

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

        // 1. ننظف الـ RRULE من أي DTSTART داخلي عشان نتحكم فيه يدويًا
        string cleanRRule = reminder.RRULE ?? string.Empty;
        cleanRRule = RemoveDtStartFromRRule(cleanRRule).Trim();

        // 2. نحسب DtStart الصحيح بناءً على StartDateUtc + أول وقت من الـ RRULE
        var startLocal = TimeZoneInfo.ConvertTimeFromUtc(reminder.StartDateUtc, tz);
        var dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);

        // استخراج الساعة والدقيقة من الـ RRULE النظيفة
        var (hour, minute) = ExtractTimeFromRRule(cleanRRule);

        if (hour.HasValue)
        {
            dtStartLocal = dtStartLocal.AddHours(hour.Value);
        }
        else
        {
            // fallback لو مفيش BYHOUR
            dtStartLocal = dtStartLocal.AddHours(9);
            _logger.LogWarning("No BYHOUR in RRULE for Reminder {Id} - using fallback 09:00", reminder.Id);
        }

        if (minute.HasValue)
        {
            dtStartLocal = dtStartLocal.AddMinutes(minute.Value);
        }

        // 3. نحدد DtStart للـ event
        ev.DtStart = new CalDateTime(dtStartLocal, timeZoneId);
        ev.Summary = reminder.Title;

        // 4. نضيف الـ RRULE النظيفة (بدون DTSTART)
        if (!string.IsNullOrWhiteSpace(cleanRRule))
        {
            try
            {
                var recurrencePattern = new RecurrencePattern(cleanRRule);
                ev.RecurrenceRules.Add(recurrencePattern);
                _logger.LogDebug("Using clean RRULE without DTSTART: {RRULE}", cleanRRule);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to parse clean RRULE for Reminder {Id}: {RRULE}", reminder.Id, cleanRRule);
                throw new InvalidOperationException($"Invalid RRULE after cleaning: {cleanRRule}", ex);
            }
        }
        else
        {
            _logger.LogWarning("No valid RRULE after cleaning for Reminder {Id}", reminder.Id);
        }

        // 5. لو مفيش UNTIL في الـ RRULE، نضيفه يدويًا لو موجود EndDateUtc
        if (reminder.EndDateUtc.HasValue && !cleanRRule.Contains("UNTIL", StringComparison.OrdinalIgnoreCase))
        {
            var endLocal = TimeZoneInfo.ConvertTimeFromUtc(reminder.EndDateUtc.Value, tz);
            var untilLocal = DateTime.SpecifyKind(endLocal.Date.AddDays(1).AddTicks(-1), DateTimeKind.Unspecified);
            var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);

            if (ev.RecurrenceRules.Any())
            {
                ev.RecurrenceRules[0].Until = untilUtc;
                _logger.LogDebug("Added UNTIL manually: {UntilUtc}", untilUtc);
            }
        }

        calendar.Events.Add(ev);

        // 6. توليد الـ occurrences
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
                _logger.LogWarning(ex, "Skipping invalid local time due to DST or timezone issue: {LocalTime}", localTime);
                continue;
            }

            if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
            {
                results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
            }
        }

        _logger.LogInformation("Reminder {Id}: Generated {Count} valid occurrences after fix", reminder.Id, results.Count);
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

        //private (int? hour, int? minute) ExtractTimeFromRRule(string rrule)
        //{
        //    int? hour = null;
        //    int? minute = null;

        //    if (string.IsNullOrWhiteSpace(rrule))
        //        return (hour, minute);

        //    var hourMatch = Regex.Match(rrule, @"BYHOUR=(\d+)", RegexOptions.IgnoreCase);
        //    if (hourMatch.Success && int.TryParse(hourMatch.Groups[1].Value, out var h))
        //    {
        //        hour = h;
        //    }

        //    var minuteMatch = Regex.Match(rrule, @"BYMINUTE=(\d+)", RegexOptions.IgnoreCase);
        //    if (minuteMatch.Success && int.TryParse(minuteMatch.Groups[1].Value, out var m))
        //    {
        //        minute = m;
        //    }

        //    return (hour, minute);
        //}
        private (int? hour, int? minute) ExtractTimeFromRRule(string rrule)
        {
            int? hour = null;
            int? minute = null;

            if (string.IsNullOrWhiteSpace(rrule))
                return (hour, minute);

            // ❌ المشكلة: بياخد أول hour بس من القائمة!
            var hourMatch = Regex.Match(rrule, @"BYHOUR=([\d,]+)", RegexOptions.IgnoreCase);
            if (hourMatch.Success)
            {
                var firstHour = hourMatch.Groups[1].Value.Split(',')[0];  // ← ياخد "0" بس!
                if (int.TryParse(firstHour, out var h))
                {
                    hour = h;  // ← hour = 0 (بس!)
                }
            }

            // نفس المشكلة في BYMINUTE
            var minuteMatch = Regex.Match(rrule, @"BYMINUTE=([\d,]+)", RegexOptions.IgnoreCase);
            if (minuteMatch.Success)
            {
                var firstMinute = minuteMatch.Groups[1].Value.Split(',')[0];  // ← ياخد "0" بس!
                if (int.TryParse(firstMinute, out var m))
                {
                    minute = m;  // ← minute = 0 (بس!)
                }
            }

            return (hour, minute);  // ← بيرجع (0, 0) بس!
        }
        private string RemoveDtStartFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return rrule;

            return Regex.Replace(rrule, @"DTSTART:\d{8}T\d{6};?", "", RegexOptions.IgnoreCase).Trim();
        }
    }
}