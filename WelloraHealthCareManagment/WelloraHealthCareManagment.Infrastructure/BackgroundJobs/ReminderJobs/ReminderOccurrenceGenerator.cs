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
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;
using WelloraHealthCareManagment.Infrastructure.Helpers;

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
                        Status = ReminderEnums.OccurrenceStatus.Scheduled
                    });
                }
            }

            if (newEntries.Any())
            {
                await cacheRepo.DeleteByDoctorAndDateRangeAsync(doctorId, fromUtc, toUtc);
                await cacheRepo.BulkInsertAsync(newEntries);
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
                    expired.Status = ReminderEnums.ReminderStatus.Dismissed;
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
                            Status = ReminderEnums.OccurrenceStatus.Scheduled
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

                // MODE 1: SIMPLE EVERY X HOURS
                if (reminder.IsSimpleEveryXHours &&
                    reminder.FirstDoseTime.HasValue &&
                    reminder.IntervalHours.HasValue)
                {
                    var dtStart = reminder.StartDateUtc.Date.Add(reminder.FirstDoseTime.Value);
                    ev.DtStart = new CalDateTime(
                        DateTime.SpecifyKind(dtStart, DateTimeKind.Unspecified), timeZoneId);
                    ev.Summary = reminder.Title;

                    var rruleStr = $"FREQ=HOURLY;INTERVAL={reminder.IntervalHours.Value}";
                    if (reminder.EndDateUtc.HasValue)
                    {
                        var untilLocal = DateTime.SpecifyKind(
                            reminder.EndDateUtc.Value.Date.AddDays(1).AddTicks(-1),
                            DateTimeKind.Unspecified);
                        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                        rruleStr += $";UNTIL={untilUtc:yyyyMMddTHHmmssZ}";
                    }
                    ev.RecurrenceRules.Add(new RecurrencePattern(rruleStr));
                }
                // MODE 2: RRULE
                else if (!string.IsNullOrWhiteSpace(reminder.RRULE))
                {
                    var cleanRRule = RruleHelper.RemoveDtStartFromRRule(reminder.RRULE);
                    var startLocal = TimeZoneInfo.ConvertTimeFromUtc(reminder.StartDateUtc, tz);
                    var (hour, minute) = RruleHelper.ExtractFirstTimeFromRRule(cleanRRule);

                    var dtStartLocal = startLocal.Date
                        .AddHours(hour ?? 9)
                        .AddMinutes(minute ?? 0);

                    // FIX 2A: Advance to first day that actually matches the recurrence pattern
                    dtStartLocal = RruleHelper.AdvanceDtStartToFirstValidOccurrence(
                        dtStartLocal, cleanRRule);

                    ev.DtStart = new CalDateTime(
                        DateTime.SpecifyKind(dtStartLocal, DateTimeKind.Unspecified), timeZoneId);
                    ev.Summary = reminder.Title;

                    try
                    {
                        ev.RecurrenceRules.Add(new RecurrencePattern(cleanRRule));
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex,
                            "Failed to parse RRULE for Reminder {ReminderId}: {RRULE}",
                            reminder.Id, cleanRRule);
                        throw new InvalidOperationException(
                            $"Invalid RRULE for reminder {reminder.Id}: {cleanRRule}", ex);
                    }

                    if (reminder.EndDateUtc.HasValue &&
                        !cleanRRule.Contains("UNTIL", StringComparison.OrdinalIgnoreCase))
                    {
                        var untilLocal = DateTime.SpecifyKind(
                            reminder.EndDateUtc.Value.Date.AddDays(1).AddTicks(-1),
                            DateTimeKind.Unspecified);
                        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                        if (ev.RecurrenceRules.Any())
                            ev.RecurrenceRules[0].Until = untilUtc;
                    }
                }
                else
                {
                    throw new InvalidOperationException(
                        $"Reminder {reminder.Id} is in invalid state after validation");
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
                            DateTime.SpecifyKind(localTime, DateTimeKind.Unspecified), tz);
                    }
                    catch (ArgumentException ex)
                    {
                        _logger.LogWarning(ex,
                            "Skipping invalid local time due to DST: {LocalTime}", localTime);
                        continue;
                    }

                    if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
                        results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
                }

                _logger.LogInformation(
                    "Reminder {Id}: Generated {Count} occurrences", reminder.Id, results.Count);
                return results.OrderBy(dt => dt);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Critical error generating occurrences for reminder {ReminderId}", reminder.Id);
                throw;
            }
        }

    }
}