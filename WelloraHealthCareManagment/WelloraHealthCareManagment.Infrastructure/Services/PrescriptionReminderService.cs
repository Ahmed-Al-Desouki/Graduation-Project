using HealthCare_.Models.DTOs.V2;
using Ical.Net.DataTypes;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class PrescriptionReminderService : IPrescriptionReminderService
    {
        private readonly IReminderV2Service _reminderService;
        private readonly IServiceProvider _serviceProvider;
        private readonly IPrescriptionRepository _prescriptionRepository;
        private readonly ILogger<PrescriptionReminderService> _logger;

        public ITimezoneHelper _timezoneHelper { get; }

        public PrescriptionReminderService(
            IReminderV2Service reminderService,
            ITimezoneHelper timezoneHelper,
            IServiceProvider serviceProvider,
            IPrescriptionRepository prescriptionRepository,
            ILogger<PrescriptionReminderService> logger)
        {
            _reminderService = reminderService;
            _timezoneHelper = timezoneHelper;
            _serviceProvider = serviceProvider;
            _prescriptionRepository = prescriptionRepository;
            _logger = logger;
        }

        public async Task CreatePrescriptionRemindersAsync(
            Prescription prescription,
            CancellationToken ct = default)
        {
            var timeZoneId = "Africa/Cairo";
            _logger.LogInformation(
                "📝 Creating reminders for Prescription {PrescriptionId} with {ItemCount} items",
                prescription.Id, prescription.Items.Count);

            var remindersCreated = 0;
            foreach (var item in prescription.Items)
            {
                if (!item.ReminderFrequencyType.HasValue)
                {
                    _logger.LogDebug(
                        "⏭️ Skipping PrescriptionItem {ItemId} - No reminder frequency set",
                        item.Id);
                    continue;
                }

                try
                {
                    var startDate = item.ReminderStartDate ?? prescription.IssuedAt;
                    var endDate = item.ReminderEndDate ?? CalculateDefaultEndDate(startDate, item.Duration);
                    var firstDose = item.ReminderFirstDoseTime ?? new TimeSpan(8, 0, 0);
                    var startDateTime = startDate.Date + firstDose;

                    var dto = new CreateReminderV2Dto
                    {
                        Type = ReminderEnums.ReminderType.Medication,
                        Title = $"💊 {item.MedicationName}",
                        Message = BuildReminderMessage(item, prescription.PrescriptionNumber),
                        StartDate = startDateTime,
                        EndDate = endDate,
                        TimeZoneId = timeZoneId,
                        PrescriptionId = prescription.Id,
                        PrescriptionItemId = item.Id,
                        AppointmentId = prescription.AppointmentId
                    };

                    if (item.ReminderFrequencyType == RepeatFrequency.EveryXHours)
                    {
                        var times = item.ReminderDailyDoseTimes?.Select(t => t.ToString(@"hh\:mm\:ss")).ToList()
                            ?? new List<string> { firstDose.ToString(@"hh\:mm\:ss") };
                        dto.Simple = new SimpleFrequency
                        {
                            Frequency = "EveryXHours",
                            IntervalHours = item.ReminderIntervalHours ?? 8,
                            Times = times
                        };
                        dto.RRULE = null;
                        _logger.LogInformation(
                            " [SIMPLE] Reminder DTO for {Med} - Every {Int}h",
                            item.MedicationName, dto.Simple.IntervalHours);
                    }
                    else
                    {
                        dto.RRULE = BuildRRuleForPrescription(item, startDateTime, endDate, timeZoneId);
                        dto.Simple = null;
                    }

                    var reminder = await _reminderService.CreateAsync(prescription.PatientId, dto);
                    var generator = _serviceProvider.GetRequiredService<PrescriptionReminderOccurrenceGenerator>();

                    var cacheFrom = item.ReminderStartDate?.ToUniversalTime() ?? DateTime.UtcNow;
                    var cacheTo = (item.ReminderEndDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(90)).AddDays(1);
                    await generator.GenerateCacheForPrescriptionItemAsync(item, prescription.PatientId, reminder.Id, cacheFrom, cacheTo);

                    _logger.LogInformation(
                        " Reminder {Id} created for {Med}",
                        reminder.Id, item.MedicationName);
                    remindersCreated++;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex,
                        "❌ Failed to create reminder for PrescriptionItem {ItemId} ({MedicationName})",
                        item.Id, item.MedicationName);
                    throw;
                }
            }

            _logger.LogInformation(
                " Successfully created {Count} reminders for Prescription {PrescriptionId}",
                remindersCreated, prescription.Id);
        }

        public async Task CreateReminderForItemAsync(
            PrescriptionItem item,
            Guid prescriptionId,
            int patientId,
            CancellationToken ct = default)
        {
            var timeZoneId = "Africa/Cairo";

            if (!item.ReminderFrequencyType.HasValue)
            {
                _logger.LogDebug("Skipping item {ItemId} - No reminder frequency", item.Id);
                return;
            }

            try
            {
                var prescription = await _prescriptionRepository.GetByIdAsync(prescriptionId, ct);
                if (prescription == null)
                    throw new NotFoundException("Prescription", prescriptionId);

                var startDate = item.ReminderStartDate ?? prescription.IssuedAt;
                var endDate = item.ReminderEndDate ?? CalculateDefaultEndDate(startDate, item.Duration);
                var inclusiveEndDate = endDate.Date.AddDays(1).AddTicks(-1);
                var firstDose = item.ReminderFirstDoseTime ?? new TimeSpan(8, 0, 0);
                var startDateTime = startDate.Date + firstDose;

                var dto = new CreateReminderV2Dto
                {
                    Type = ReminderEnums.ReminderType.Medication,
                    Title = $"💊 {item.MedicationName}",
                    Message = BuildReminderMessage(item, prescription.PrescriptionNumber),
                    StartDate = startDateTime,
                    EndDate = inclusiveEndDate,
                    TimeZoneId = timeZoneId,
                    PrescriptionId = prescriptionId,
                    PrescriptionItemId = item.Id,
                    AppointmentId = prescription.AppointmentId
                };

                if (item.ReminderFrequencyType == RepeatFrequency.EveryXHours)
                {
                    var times = item.ReminderDailyDoseTimes?.Select(t => t.ToString(@"hh\:mm\:ss")).ToList()
                        ?? new List<string> { firstDose.ToString(@"hh\:mm\:ss") };
                    dto.Simple = new SimpleFrequency
                    {
                        Frequency = "EveryXHours",
                        IntervalHours = item.ReminderIntervalHours ?? 8,
                        Times = times
                    };
                }
                else
                {
                    dto.RRULE = BuildRRuleForPrescription(item, startDateTime, inclusiveEndDate, timeZoneId);
                }

                var reminder = await _reminderService.CreateAsync(patientId, dto);
                var generator = _serviceProvider.GetRequiredService<PrescriptionReminderOccurrenceGenerator>();

                var cacheFrom = item.ReminderStartDate?.ToUniversalTime() ?? DateTime.UtcNow;
                var cacheTo = (item.ReminderEndDate?.ToUniversalTime() ?? DateTime.UtcNow.AddDays(90)).AddDays(1);
                await generator.GenerateCacheForPrescriptionItemAsync(item, patientId, reminder.Id, cacheFrom, cacheTo);

                _logger.LogInformation("Reminder created for single item {ItemId} - {Med}", item.Id, item.MedicationName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create reminder for item {ItemId}", item.Id);
                throw;
            }
        }

        ///  Build RRULE for prescription with proper frequency handling
        //private string BuildRRuleForPrescription(
        //    PrescriptionItem item,
        //    DateTime startDateTime,
        //    DateTime? endDate,
        //    string timeZoneId)
        //{
        //    var parts = new List<string>();

        //    //  Add frequency
        //    switch (item.ReminderFrequencyType)
        //    {
        //        case RepeatFrequency.Once:
        //            parts.Add("FREQ=DAILY");
        //            parts.Add("COUNT=1");
        //            break;

        //        case RepeatFrequency.Daily:
        //            parts.Add("FREQ=DAILY");
        //            break;

        //        case RepeatFrequency.Weekly:
        //            parts.Add("FREQ=WEEKLY");
        //            if (item.ReminderWeeklyDays?.Count > 0)
        //            {
        //                var days = string.Join(",", item.ReminderWeeklyDays
        //                    .Select(d => ConvertDayOfWeekToRFC5545(d))
        //                    .Distinct());
        //                parts.Add($"BYDAY={days}");
        //            }
        //            break;

        //        case RepeatFrequency.Monthly:
        //            parts.Add("FREQ=MONTHLY");
        //            parts.Add("BYMONTHDAY=1");
        //            break;

        //        default:
        //            throw new ArgumentException($"Unsupported frequency: {item.ReminderFrequencyType}");
        //    }

        //    //  Add time components
        //    if (item.ReminderDailyDoseTimes?.Count > 0)
        //    {
        //        var sortedTimes = item.ReminderDailyDoseTimes.OrderBy(t => t).ToList();
        //        var uniqueMinutes = sortedTimes.Select(t => t.Minutes).Distinct().ToList();

        //        if (uniqueMinutes.Count == 1)
        //        {
        //            //  Same minute for all times (e.g., 08:00, 12:00, 16:00)
        //            var uniqueHours = sortedTimes.Select(t => t.Hours).Distinct().OrderBy(h => h).ToList();

        //            if (uniqueHours.Any())
        //                parts.Add($"BYHOUR={string.Join(",", uniqueHours)}");

        //            parts.Add($"BYMINUTE={uniqueMinutes[0]}");
        //            parts.Add("BYSECOND=0");
        //        }
        //        else
        //        {
        //            // ⚠️ Mixed minutes (e.g., 07:30, 14:00, 21:45)
        //            _logger.LogWarning(
        //                "⚠️ Mixed minutes detected in ReminderDailyDoseTimes. " +
        //                "This may cause incorrect occurrences. Times: {Times}",
        //                string.Join(", ", sortedTimes.Select(t => t.ToString(@"hh\:mm"))));

        //            // Fallback: use first time only
        //            parts.Add($"BYHOUR={sortedTimes[0].Hours}");
        //            parts.Add($"BYMINUTE={sortedTimes[0].Minutes}");
        //            parts.Add("BYSECOND=0");
        //        }
        //    }

        //    //  Add UNTIL
        //    if (endDate.HasValue)
        //    {
        //        var inclusiveEnd = endDate.Value.Date.AddDays(1).AddTicks(-1);
        //        var endUtc = inclusiveEnd.ToUniversalTime();
        //        parts.Add($"UNTIL={endUtc:yyyyMMddTHHmmssZ}");
        //    }

        //    var rrule = string.Join(";", parts);

        //    _logger.LogDebug("Built RRULE: {RRULE}", rrule);

        //    // Test parse
        //    try
        //    {
        //        var test = new RecurrencePattern(rrule);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Failed to parse generated RRULE: {RRULE}", rrule);
        //        throw new ArgumentException($"Generated invalid RRULE: {rrule}", ex);
        //    }

        //    return rrule;
        //}
        private string BuildRRuleForPrescription(
            PrescriptionItem item,
            DateTime startDateTime,
            DateTime? endDate,
            string timeZoneId)
        {
            var parts = new List<string>();

            // أولًا: Frequency
            switch (item.ReminderFrequencyType)
            {
                case RepeatFrequency.Once:
                    parts.Add("FREQ=DAILY");
                    parts.Add("COUNT=1");
                    break;

                case RepeatFrequency.Daily:
                    parts.Add("FREQ=DAILY");
                    break;

                case RepeatFrequency.Weekly:
                    parts.Add("FREQ=WEEKLY");
                    if (item.ReminderWeeklyDays?.Count > 0)
                    {
                        var days = string.Join(",", item.ReminderWeeklyDays
                            .Select(d => ConvertDayOfWeekToRFC5545(d))
                            .Distinct());
                        parts.Add($"BYDAY={days}");
                    }
                    break;

                case RepeatFrequency.Monthly:
                    parts.Add("FREQ=MONTHLY");
                    parts.Add("BYMONTHDAY=1");
                    break;

                default:
                    throw new ArgumentException($"Unsupported frequency: {item.ReminderFrequencyType}");
            }

            // ثانيًا: أوقات الجرعة
            if (item.ReminderDailyDoseTimes?.Count > 0)
            {
                var sortedTimes = item.ReminderDailyDoseTimes.OrderBy(t => t).ToList();
                var uniqueHours = sortedTimes.Select(t => t.Hours).Distinct().OrderBy(h => h).ToList();
                var uniqueMinutes = sortedTimes.Select(t => t.Minutes).Distinct().ToList();

                if (uniqueHours.Any())
                    parts.Add($"BYHOUR={string.Join(",", uniqueHours)}");

                if (uniqueMinutes.Count == 1)
                    parts.Add($"BYMINUTE={uniqueMinutes[0]}");
                else if (uniqueMinutes.Count > 1)
                {
                    _logger.LogWarning("Mixed minutes detected - using first minute only");
                    parts.Add($"BYMINUTE={uniqueMinutes[0]}");
                }

                parts.Add("BYSECOND=0");
            }

            // الجزء المهم: ما نضيفش UNTIL لو Once
            bool addUntil = endDate.HasValue && item.ReminderFrequencyType != RepeatFrequency.Once;

            if (addUntil)
            {
                var inclusiveEnd = endDate.Value.Date.AddDays(1).AddTicks(-1);
                var endUtc = inclusiveEnd.ToUniversalTime();
                parts.Add($"UNTIL={endUtc:yyyyMMddTHHmmssZ}");
            }

            var rrule = string.Join(";", parts);
            _logger.LogDebug("Built RRULE: {RRULE}", rrule);

            // Test parse
            try
            {
                var test = new RecurrencePattern(rrule);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to parse generated RRULE: {RRULE}", rrule);
                throw new ArgumentException($"Generated invalid RRULE: {rrule}", ex);
            }

            return rrule;
        }

        private string ConvertDayOfWeekToRFC5545(DayOfWeek day)
        {
            return day switch
            {
                DayOfWeek.Sunday => "SU",
                DayOfWeek.Monday => "MO",
                DayOfWeek.Tuesday => "TU",
                DayOfWeek.Wednesday => "WE",
                DayOfWeek.Thursday => "TH",
                DayOfWeek.Friday => "FR",
                DayOfWeek.Saturday => "SA",
                _ => throw new ArgumentException($"Invalid day: {day}")
            };
        }

        private DateTime CalculateDefaultEndDate(DateTime start, string duration)
        {
            var match = Regex.Match(duration ?? "", @"(\d+)\s*(day|days|week|weeks|month|months)",
                RegexOptions.IgnoreCase);

            if (!match.Success)
                return start.AddDays(7);

            var value = int.Parse(match.Groups[1].Value);
            var unit = match.Groups[2].Value.ToLower();

            return unit switch
            {
                "day" or "days" => start.AddDays(value),
                "week" or "weeks" => start.AddDays(value * 7),
                "month" or "months" => start.AddMonths(value),
                _ => start.AddDays(7)
            };
        }

        private string BuildReminderMessage(PrescriptionItem item, string prescriptionNumber)
        {
            var parts = new List<string>
            {
                $"💊 الجرعة: {item.Dosage}",
                $"⏰ التكرار: {item.Frequency}",
                $"📅 المدة: {item.Duration}"
            };

            if (!string.IsNullOrWhiteSpace(item.Instructions))
                parts.Add($"📝 {item.Instructions}");

            parts.Add($"🧾 روشتة: {prescriptionNumber}");

            return string.Join("\n", parts);
        }

        public async Task CancelPrescriptionRemindersAsync(
            Guid prescriptionId,
            int patientId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "🗑️ Cancelling reminders for PrescriptionId={PrescriptionId}",
                    prescriptionId);

                var reminders = await _reminderService.GetAllAsync(patientId);

                var prescriptionReminders = reminders
                    .Where(r => r.Message?.Contains(prescriptionId.ToString()) == true && r.IsActive)
                    .ToList();

                foreach (var reminder in prescriptionReminders)
                {
                    await _reminderService.SoftDeleteAsync(reminder.Id, patientId);
                }

                _logger.LogInformation(
                    " Cancelled {Count} reminders",
                    prescriptionReminders.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "❌ Error cancelling reminders for PrescriptionId={PrescriptionId}",
                    prescriptionId);
            }
        }
    }
}