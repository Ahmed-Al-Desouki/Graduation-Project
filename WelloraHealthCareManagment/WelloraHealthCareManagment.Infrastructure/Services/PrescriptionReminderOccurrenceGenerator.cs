using HealthCare_.Models.V2;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class PrescriptionReminderOccurrenceGenerator
    {
        private readonly IReminderOccurrencesCacheRepository _cacheRepository;
        private readonly ILogger<PrescriptionReminderOccurrenceGenerator> _logger;

        public PrescriptionReminderOccurrenceGenerator(
            IReminderOccurrencesCacheRepository cacheRepository,
            ILogger<PrescriptionReminderOccurrenceGenerator> logger)
        {
            _cacheRepository = cacheRepository;
            _logger = logger;
        }

        public async Task GenerateCacheForPrescriptionItemAsync(
            PrescriptionItem item,
            int patientId,
            int reminderId,
            DateTime fromUtc,
            DateTime toUtc)
        {
            if (!item.ReminderFrequencyType.HasValue)
                return;

            _logger.LogInformation(
                "🔄 Generating cache for PrescriptionItem {ItemId} ({Med}), PatientId={PatientId}, From={From}, To={To}",
                item.Id, item.MedicationName, patientId, fromUtc, toUtc);

            var occurrences = GenerateOccurrences(item, fromUtc, toUtc);

            _logger.LogInformation(
                "📊 Generated {Count} raw occurrences for item {ItemId}",
                occurrences.Count(), item.Id);

            var entries = new List<ReminderOccurrencesCache>();

            foreach (var dueUtc in occurrences)
            {
                var localTime = TimeZoneInfo.ConvertTimeFromUtc(
                    dueUtc,
                    TimeZoneInfo.FindSystemTimeZoneById("Africa/Cairo"));

                entries.Add(new ReminderOccurrencesCache
                {
                    CreatedAt = DateTime.UtcNow,
                    PatientId = patientId,
                    DoctorId = null,
                    ReminderId = reminderId,
                    DueDateTimeUtc = dueUtc,
                    DueDateTime = localTime,
                    TimeZoneId = "Africa/Cairo",
                    Title = $"Take {item.MedicationName}",
                    Message = $"Dosage: {item.Dosage} - {item.Instructions}",
                    Type = Enums.ReminderType.Medication,
                    Status = Enums.OccurrenceStatus.Scheduled
                });
            }

            if (entries.Any())
            {
                // احذف بس اللي في الـ range الجديد للـ reminder ده (أكثر أمانًا)
                await _cacheRepository.DeleteByReminderAndDateRangeAsync(reminderId, fromUtc, toUtc);

                _logger.LogInformation(
                    "🗑️ Deleted old cache for patient {PatientId} range {From} to {To}",
                    patientId, fromUtc, toUtc);

                await _cacheRepository.BulkInsertAsync(entries);

                _logger.LogInformation(
                    "✅ Cache INSERT completed for item {ItemId} - {Count} rows inserted",
                    item.Id, entries.Count);

                var uniqueTimes = entries.Select(e => e.DueDateTime.TimeOfDay).Distinct().OrderBy(t => t).ToList();

                _logger.LogInformation(
                    "⏰ Unique times in cache: {Times}",
                    string.Join(", ", uniqueTimes));
            }
            else
            {
                _logger.LogWarning("⚠️ No cache entries to insert for item {ItemId}", item.Id);
            }
        }

        private IEnumerable<DateTime> GenerateOccurrences(
            PrescriptionItem item,
            DateTime fromUtc,
            DateTime toUtc)
        {
            var results = new List<DateTime>();
            var tz = TimeZoneInfo.FindSystemTimeZoneById("Africa/Cairo");
            var fromLocal = TimeZoneInfo.ConvertTimeFromUtc(fromUtc, tz);
            var toLocal = TimeZoneInfo.ConvertTimeFromUtc(toUtc, tz);
            var startLocal = item.ReminderStartDate ?? fromLocal.Date;
            var endLocal = item.ReminderEndDate ?? toLocal.Date;
            endLocal = endLocal.Date.AddDays(1).AddTicks(-1);

            _logger.LogDebug(
                "📅 Generating occurrences: Start={Start}, End={End}, Freq={Freq}",
                startLocal, endLocal, item.ReminderFrequencyType);

            if (item.ReminderFrequencyType == RepeatFrequency.EveryXHours &&
                item.ReminderIntervalHours.HasValue)
            {
                // EveryXHours mode
                var interval = TimeSpan.FromHours(item.ReminderIntervalHours.Value);
                var next = startLocal.Date + (item.ReminderFirstDoseTime ?? TimeSpan.FromHours(8));

                _logger.LogDebug(
                    "⏱️ EveryXHours: First dose={FirstDose}, Interval={Interval}h",
                    next.TimeOfDay, item.ReminderIntervalHours);

                while (next <= endLocal && next <= toLocal)
                {
                    if (next >= fromLocal)
                    {
                        var utc = TimeZoneInfo.ConvertTimeToUtc(
                            DateTime.SpecifyKind(next, DateTimeKind.Unspecified), tz);
                        results.Add(utc);
                    }
                    next = next + interval;
                }
            }
            else
            {
                // RRULE mode using ical.net
                results = GenerateOccurrencesUsingIcalNet(item, startLocal, endLocal, tz, fromLocal, toLocal);
            }

            var sortedResults = results.OrderBy(d => d).ToList();

            _logger.LogInformation(
                "📊 Generated {Count} occurrences for item {ItemId}",
                sortedResults.Count, item.Id);

            return sortedResults;
        }

        /// <summary>
        /// Generate occurrences using ical.net (supports mixed times properly)
        /// </summary>
        private List<DateTime> GenerateOccurrencesUsingIcalNet(
            PrescriptionItem item,
            DateTime startLocal,
            DateTime endLocal,
            TimeZoneInfo tz,
            DateTime fromLocal,
            DateTime toLocal)
        {
            var allResults = new List<DateTime>();

            // Get dose times
            var doseTimes = item.ReminderDailyDoseTimes ?? new List<TimeSpan> { TimeSpan.FromHours(9) };

            _logger.LogDebug(
                "🗓️ Processing {DoseCount} dose times: {Times}",
                doseTimes.Count,
                string.Join(", ", doseTimes.Select(t => t.ToString(@"hh\:mm"))));

            // Adjust for 00:00 if likely next day
            if (item.ReminderFirstDoseTime.HasValue)
            {
                var firstDose = item.ReminderFirstDoseTime.Value;
                doseTimes = doseTimes.Select(t =>
                {
                    if (t < firstDose && t.TotalHours < 24)
                    {
                        var adjusted = t + TimeSpan.FromHours(24);
                        _logger.LogDebug(
                            "📅 Adjusted dose time {Original} to {Adjusted} (next day) since < first dose {First}",
                            t.ToString(@"hh\:mm"), adjusted.ToString(@"hh\:mm"), firstDose.ToString(@"hh\:mm"));
                        return adjusted;
                    }
                    return t;
                }).ToList();
            }

            // Generate for EACH dose time separately
            foreach (var doseTime in doseTimes)
            {
                var occurrences = GenerateOccurrencesForSingleDoseTime(
                    item, startLocal, endLocal, tz, fromLocal, toLocal, doseTime);

                _logger.LogDebug(
                    "➕ Generated {Count} occurrences for dose time {Time}",
                    occurrences.Count, doseTime.ToString(@"hh\:mm"));

                allResults.AddRange(occurrences);
            }

            return allResults;
        }

        /// <summary>
        /// Generate occurrences for a single dose time using ical.net
        /// </summary>
        private List<DateTime> GenerateOccurrencesForSingleDoseTime(
            PrescriptionItem item,
            DateTime startLocal,
            DateTime endLocal,
            TimeZoneInfo tz,
            DateTime fromLocal,
            DateTime toLocal,
            TimeSpan doseTime)
        {
            try
            {
                var calendar = new Calendar();
                calendar.AddTimeZone(VTimeZone.FromSystemTimeZone(tz));

                var ev = new CalendarEvent
                {
                    Uid = $"prescription-item-{item.Id}-{doseTime.Hours}-{doseTime.Minutes}"
                };

                // Set DtStart with the dose time
                var dtStartLocal = DateTime.SpecifyKind(startLocal.Date, DateTimeKind.Unspecified);
                dtStartLocal = dtStartLocal.Add(doseTime);
                ev.DtStart = new CalDateTime(dtStartLocal, tz.Id);
                ev.Summary = $"Take {item.MedicationName}";

                // Build RRULE
                var rrule = BuildRRuleForSingleDoseTime(item, doseTime, endLocal, tz);

                _logger.LogDebug(
                    "📋 RRULE for dose time {Time}: {RRULE}",
                    doseTime.ToString(@"hh\:mm"), rrule);

                ev.RecurrenceRules.Add(new RecurrencePattern(rrule));
                calendar.Events.Add(ev);

                // Get occurrences
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
                        _logger.LogWarning(ex, "Skipping invalid local time: {LocalTime}", localTime);
                        continue;
                    }

                    var fromUtcSafe = TimeZoneInfo.ConvertTimeToUtc(
                        DateTime.SpecifyKind(fromLocal, DateTimeKind.Unspecified), tz);

                    var toUtcSafe = TimeZoneInfo.ConvertTimeToUtc(
                        DateTime.SpecifyKind(toLocal, DateTimeKind.Unspecified), tz);

                    if (utcTime >= fromUtcSafe && utcTime < toUtcSafe)
                    {
                        results.Add(DateTime.SpecifyKind(utcTime, DateTimeKind.Utc));
                    }
                }

                return results;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "❌ Error generating occurrences for dose time {Time}",
                    doseTime.ToString(@"hh\:mm"));

                return new List<DateTime>();
            }
        }

        /// <summary>
        /// Build RRULE for a single dose time - التعديل الرئيسي هنا
        /// </summary>
        private string BuildRRuleForSingleDoseTime(
            PrescriptionItem item,
            TimeSpan doseTime,
            DateTime endLocal,
            TimeZoneInfo tz)
        {
            var parts = new List<string>();

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

            // Add time components for THIS dose time only
            parts.Add($"BYHOUR={doseTime.Hours}");
            parts.Add($"BYMINUTE={doseTime.Minutes}");
            parts.Add("BYSECOND=0");

            // التعديل المهم: لا نضيف UNTIL إذا كان Once
            if (item.ReminderFrequencyType != RepeatFrequency.Once && item.ReminderEndDate.HasValue)
            {
                var inclusiveEnd = endLocal.Date.AddDays(1).AddTicks(-1);
                var endUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(inclusiveEnd, DateTimeKind.Unspecified), tz);
                parts.Add($"UNTIL={endUtc:yyyyMMddTHHmmssZ}");
            }

            var rrule = string.Join(";", parts);

            // Log the final RRULE for debugging
            _logger.LogDebug("Final RRULE built: {RRULE}", rrule);

            // Test parse to catch issues early
            try
            {
                var test = new RecurrencePattern(rrule);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to parse RRULE in generator: {RRULE}", rrule);
                throw;
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
    }
}