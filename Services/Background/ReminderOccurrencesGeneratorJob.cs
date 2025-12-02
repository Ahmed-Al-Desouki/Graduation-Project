// File: Services/Background/ReminderOccurrencesGeneratorJob.cs
using HealthCare_.Models.V2;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;

namespace HealthCare_.Services.Background
{
    public class ReminderOccurrencesGeneratorJob
    {
        // ← الحل هنا: نكتب System.IServiceProvider صراحة
        private readonly System.IServiceProvider _serviceProvider;
        private readonly ILogger<ReminderOccurrencesGeneratorJob> _logger;

        // ← وهنا كمان
        public ReminderOccurrencesGeneratorJob(System.IServiceProvider serviceProvider, ILogger<ReminderOccurrencesGeneratorJob> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        // باقي الكود زي ما هو (مش محتاج تغيير)
        public async Task GenerateForAllPatientsAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var patientIds = await context.ReminderV2s
                .Where(r => r.IsActive)
                .Select(r => r.PatientId)
                .Distinct()
                .ToListAsync();

            _logger.LogInformation("Start generating cash for {Count} patients", patientIds.Count);

            foreach (var pid in patientIds)
            {
                try
                {
                    await GenerateCacheForPatientAsync(context, pid);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to generate cash for patient {PatientId}", pid);
                }
            }
        }

        public async Task GenerateForPatientAsync(int patientId)
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
            await GenerateCacheForPatientAsync(context, patientId);
        }

        private async Task GenerateCacheForPatientAsync(HealthCarePlusContext context, int patientId)
        {
            var now = DateTime.UtcNow;
            var fromUtc = now.AddDays(-2);
            var toUtc = now.AddDays(90);

            var reminders = await context.ReminderV2s
                .AsNoTracking()
                .Where(r => r.PatientId == patientId && r.IsActive)
                .Select(r => new
                {
                    r.Id,
                    r.Title,
                    r.Message,
                    r.Type,
                    r.StartDate,
                    r.BaseTime,
                    r.RRULE,
                    r.EXDATE,
                    r.EndDate,
                    r.TimeZoneId,
                    Dosage = r.PrescriptionMed != null
                        ? $"{r.PrescriptionMed.Dosage} {r.PrescriptionMed.MedicationName}"
                        : null
                })
                .ToListAsync();

            var newEntries = new List<ReminderOccurrencesCache>();

            foreach (var r in reminders)
            {
                var occurrences = GenerateOccurrencesWithIcalNet(
                    r.Id, r.StartDate, r.BaseTime, r.RRULE, r.EXDATE, r.EndDate, r.TimeZoneId, fromUtc, toUtc);

                newEntries.AddRange(occurrences.Select(dt => new ReminderOccurrencesCache
                {
                    PatientId = patientId,
                    ReminderId = r.Id,
                    DueDateTime = dt,
                    Title = r.Title,
                    Message = r.Message,
                    Type = r.Type,
                    Dosage = r.Dosage,
                    Status = 0
                }));
            }

            await using var tx = await context.Database.BeginTransactionAsync();

            await context.Database.ExecuteSqlRawAsync(
                "DELETE FROM ReminderOccurrencesCache WHERE PatientId = {0}", patientId);

            if (newEntries.Any())
            {
                const int batch = 5000;
                for (int i = 0; i < newEntries.Count; i += batch)
                {
                    context.ReminderOccurrencesCache.AddRange(newEntries.Skip(i).Take(batch));
                    await context.SaveChangesAsync();
                    context.ChangeTracker.Clear();
                }
            }

            await tx.CommitAsync();
            _logger.LogInformation("{Count} doses have been generated for patient {PatientId}.", newEntries.Count, patientId);
        }

        //private IEnumerable<DateTime> GenerateOccurrencesWithIcalNet(
        //    int reminderId,
        //    DateTime startDate,
        //    TimeSpan? baseTime,
        //    string? rrule,
        //    string? exdate,
        //    DateTime? endDate,
        //    string timeZoneId,
        //    DateTime fromUtc,
        //    DateTime toUtc)
        //{
        //    var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        //    var actualBaseTime = baseTime ?? TimeSpan.FromHours(9);
        //    var dtStartLocal = startDate.Date + actualBaseTime;
        //    var calStart = new CalDateTime(dtStartLocal, timeZoneId);

        //    RecurrencePattern pattern;
        //    try
        //    {
        //        pattern = string.IsNullOrWhiteSpace(rrule)
        //            ? new RecurrencePattern("FREQ=DAILY")
        //            : new RecurrencePattern(rrule.Trim().ToUpperInvariant());
        //    }
        //    catch
        //    {
        //        pattern = new RecurrencePattern("FREQ=DAILY");
        //    }

        //    if (endDate.HasValue)
        //    {
        //        var untilLocal = endDate.Value.Date.AddDays(1).AddTicks(-1);
        //        var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
        //        pattern.Until = untilUtc;
        //    }

        //    //var ics = $@"
        //    //BEGIN:VCALENDAR
        //    //BEGIN:VEVENT
        //    //UID:reminder-{reminderId}
        //    //DTSTART;TZID={timeZoneId}:{calStart:yyyyMMdd'T'HHmmss}
        //    //RRULE:{pattern}
        //    //END:VEVENT
        //    //END:VCALENDAR";
        //    var ics = string.Join("\r\n",
        //        "BEGIN:VCALENDAR",
        //        "VERSION:2.0",
        //        "PRODID:-//HealthCare+//Reminder System//EN",
        //        "BEGIN:VEVENT",
        //        $"UID:reminder-{reminderId}",
        //        $"DTSTART;TZID={timeZoneId}:{calStart:yyyyMMdd'T'HHmmss}",
        //        $"RRULE:{pattern}",
        //        "END:VEVENT",
        //        "END:VCALENDAR"
        //    ) + "\r\n";

        //    var calendar = Calendar.Load(new StringReader(ics));

        //    if (!string.IsNullOrWhiteSpace(exdate))
        //    {
        //        var ev = calendar.Events.First();
        //        var exceptions = new PeriodList();
        //        foreach (var ex in exdate.Split(',', StringSplitOptions.RemoveEmptyEntries))
        //        {
        //            if (DateTime.TryParse(ex.Trim(), out var dt))
        //            {
        //                var localEx = TimeZoneInfo.ConvertTimeFromUtc(dt, tz).Date;
        //                exceptions.Add(new Period(new CalDateTime(localEx, timeZoneId)));
        //            }
        //        }
        //        if (exceptions.Any()) ev.ExceptionDates.Add(exceptions);
        //    }

        //    return calendar.GetOccurrences(fromUtc, toUtc)
        //                  .Select(o => o.Period.StartTime.AsSystemLocal)
        //                  .Where(dt => dt >= dtStartLocal)
        //                  .OrderBy(dt => dt);
        //}
        private IEnumerable<DateTime> GenerateOccurrencesWithIcalNet(
     int reminderId,
     DateTime startDate,
     TimeSpan? baseTime,
     string? rrule,
     string? exdate,
     DateTime? endDate,
     string timeZoneId,
     DateTime fromUtc,
     DateTime toUtc)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);

            bool hasExplicitTimeInRrule = RruleHasExplicitTime(rrule);

            DateTime dtStartLocal;

            if (hasExplicitTimeInRrule)
            {
                var firstHour = ExtractFirstByHour(rrule);
                dtStartLocal = startDate.Date.AddHours(firstHour);
            }
            else if (baseTime.HasValue)
            {
                dtStartLocal = startDate.Date + baseTime.Value;
            }
            else
            {
                dtStartLocal = startDate.Date;
            }

            // ✅ حالة مرة واحدة فقط
            if (string.IsNullOrWhiteSpace(rrule) || rrule.Contains("FREQ=ONCE"))
                return new List<DateTime> { dtStartLocal };

            var calendar = new Calendar();

            var ev = new CalendarEvent
            {
                Uid = $"reminder-{reminderId}",
                DtStart = new CalDateTime(dtStartLocal, timeZoneId),
                DtStamp = new CalDateTime(DateTime.UtcNow, "Etc/UTC")
            };

            RecurrencePattern pattern;
            try
            {
                pattern = new RecurrencePattern(rrule.Trim().ToUpperInvariant());

                if (pattern.Frequency == FrequencyType.None)
                    return new List<DateTime> { dtStartLocal };
            }
            catch
            {
                return new List<DateTime> { dtStartLocal };
            }

            // ✅✅✅ التصحيح الحقيقي هنا (DateTime وليس CalDateTime)
            if (endDate.HasValue)
            {
                var untilLocal = endDate.Value.Date.AddDays(1).AddTicks(-1);
                var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                pattern.Until = untilUtc;   // ✅ هذا هو التصليح النهائي
            }

            ev.RecurrenceRules.Add(pattern);

            // ✅ EXDATE
            if (!string.IsNullOrWhiteSpace(exdate))
            {
                var periodList = new PeriodList();

                foreach (var exStr in exdate.Split(',', StringSplitOptions.RemoveEmptyEntries))
                {
                    if (DateTime.TryParse(exStr.Trim(), out var exLocal))
                    {
                        periodList.Add(
                            new Period(
                                new CalDateTime(exLocal, timeZoneId)
                            )
                        );
                    }
                }

                if (periodList.Any())
                    ev.ExceptionDates.Add(periodList);
            }

            calendar.Events.Add(ev);

            // ✅ التحويل الصحيح من CalDateTime → DateTime
            var occurrences = calendar.GetOccurrences(fromUtc, toUtc)
                .Select(o => o.Period.StartTime.AsSystemLocal)
                .Where(dt => dt >= dtStartLocal)
                .OrderBy(dt => dt)
                .ToList();

            return occurrences.Any()
                ? occurrences
                : new List<DateTime> { dtStartLocal };
        }


        private int ExtractFirstByHour(string? rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return 0;

            var upper = rrule.ToUpperInvariant();

            var byHourPart = upper
                .Split(';')
                .FirstOrDefault(p => p.StartsWith("BYHOUR="));

            if (byHourPart == null)
                return 0;

            var hoursPart = byHourPart.Replace("BYHOUR=", "");

            var firstHourStr = hoursPart.Split(',').First();

            return int.TryParse(firstHourStr, out var hour) ? hour : 0;
        }



        private bool RruleHasExplicitTime(string? rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return false;

            var upper = rrule.ToUpperInvariant();

            return upper.Contains("BYHOUR")
                || upper.Contains("BYMINUTE")
                || upper.Contains("BYSECOND");
        }


    }
}