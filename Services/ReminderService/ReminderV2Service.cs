// File: Services/ReminderV2Service.cs
using Hangfire;
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.DTOs.V2.HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using HealthCare_.Services.Background;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;

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

        #region ==================== 1. CREATE & UPDATE ====================

        public async Task<ReminderV2> CreateAsync(int patientId, CreateReminderV2Dto dto)
        {
            try
            {
                var reminder = new ReminderV2
                {
                    PatientId = patientId,
                    Type = dto.Type,
                    Title = dto.Title.Trim(),
                    Message = dto.Message?.Trim(),
                    StartDate = dto.StartDate.Date,
                    EndDate = dto.EndDate?.Date,
                    TimeZoneId = dto.TimeZoneId ?? "Africa/Cairo",
                    BaseTime = ExtractBaseTime(dto),
                    PrescriptionMedId = dto.PrescriptionMedId,
                    AppointmentId = dto.AppointmentId,
                    RRULE = string.IsNullOrWhiteSpace(dto.RRULE)
                        ? GenerateRRuleFromSimple(dto.Simple ?? new SimpleFrequency())
                        : dto.RRULE.Trim().ToUpperInvariant(),
                    IsActive = true
                };

                _context.ReminderV2s.Add(reminder);
                await _context.SaveChangesAsync();

                BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(j => j.GenerateForPatientAsync(patientId));

                _logger.LogInformation("ReminderV2 created | ID: {Id} | Patient: {PatientId}", reminder.Id, patientId);
                return reminder;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create ReminderV2 for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task UpdateAsync(int reminderId, int patientId, UpdateReminderV2Dto dto)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);

            if (!string.IsNullOrWhiteSpace(dto.Title)) reminder.Title = dto.Title.Trim();
            if (dto.Message != null) reminder.Message = dto.Message.Trim();
            if (dto.StartDate.HasValue) reminder.StartDate = dto.StartDate.Value.Date;
            if (dto.EndDate.HasValue) reminder.EndDate = dto.EndDate.Value.Date;
            if (dto.TimeZoneId != null) reminder.TimeZoneId = dto.TimeZoneId;
            if (dto.IsActive.HasValue) reminder.IsActive = dto.IsActive.Value;

            if (dto.Simple != null || !string.IsNullOrWhiteSpace(dto.RRULE))
            {
                reminder.BaseTime = ExtractBaseTimeFromUpdate(dto);
                reminder.RRULE = !string.IsNullOrWhiteSpace(dto.RRULE)
                    ? dto.RRULE.Trim().ToUpperInvariant()
                    : GenerateRRuleFromSimple(dto.Simple!);
            }

            reminder.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(j => j.GenerateForPatientAsync(patientId));
        }

        private TimeSpan? ExtractBaseTime(CreateReminderV2Dto dto)
        {
            if (dto.Simple?.Times != null && dto.Simple.Times.Any())
                if (TimeSpan.TryParse(dto.Simple.Times.First(), out var t)) return t;

            return null; // ✅ لا يوجد وقت افتراضي
        }

        private TimeSpan? ExtractBaseTimeFromUpdate(UpdateReminderV2Dto dto)
        {
            if (dto.Simple?.Times != null && dto.Simple.Times.Any())
                if (TimeSpan.TryParse(dto.Simple.Times.First(), out var t)) return t;

            return null; // ✅ لا يوجد وقت افتراضي
        }

        private string GenerateRRuleFromSimple(SimpleFrequency simple)
        {
            if (simple == null) return "FREQ=DAILY;INTERVAL=1";

            return simple.Frequency switch
            {
                "Once" => "FREQ=ONCE",
                "EveryXHours" => $"FREQ=HOURLY;INTERVAL={simple.IntervalHours ?? 24}",
                "Weekly" => "FREQ=WEEKLY;INTERVAL=1",
                _ => "FREQ=DAILY;INTERVAL=1"
            };
        }

        #endregion

        #region ==================== 2. GET TODAY & UPCOMING (FROM CACHE) ====================

        public async Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId)
        {
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);
            return await GetFromCache(patientId, today, tomorrow);
        }

        public async Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30)
        {
            var from = DateTime.Today;
            var to = from.AddDays(daysAhead);
            return await GetFromCache(patientId, from, to);
        }

        private async Task<List<UpcomingOccurrenceDto>> GetFromCache(
            int patientId,
            DateTime fromInclusive,
            DateTime toExclusive)
        {
            var now = DateTime.Now;

            var cached = await _context.ReminderOccurrencesCache
                .AsNoTracking()
                .Where(x => x.PatientId == patientId
                         && x.DueDateTime >= fromInclusive
                         && x.DueDateTime < toExclusive)
                .OrderBy(x => x.DueDateTime)
                .ToListAsync();

            if (cached.Any())
            {
                return cached.Select(x => new UpcomingOccurrenceDto
                {
                    ReminderId = x.ReminderId,
                    Title = x.Title,
                    Message = x.Message ?? string.Empty,
                    DueDateTime = x.DueDateTime,
                    Type = x.Type,
                    IsMedication = x.Type == ReminderType.Medication,
                    Dosage = x.Dosage,
                    Status = GetStatus(x.Status, x.DueDateTime, now),
                    CanSnooze = x.Status == 0
                }).ToList();
            }

            _logger.LogWarning("Cache miss للمريض {PatientId} → توليد فوري", patientId);

            var result = await GenerateUpcomingOnTheFly(patientId, fromInclusive, toExclusive);

            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(j => j.GenerateForPatientAsync(patientId));

            return result;
        }

        private async Task<List<UpcomingOccurrenceDto>> GenerateUpcomingOnTheFly(
            int patientId,
            DateTime fromLocal,
            DateTime toLocal)
        {
            var reminders = await _context.ReminderV2s
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

            var result = new List<UpcomingOccurrenceDto>();
            var now = DateTime.Now;

            foreach (var r in reminders)
            {
                var tz = TimeZoneInfo.FindSystemTimeZoneById(r.TimeZoneId);

                var fromUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(fromLocal, DateTimeKind.Unspecified), tz);

                var toUtc = TimeZoneInfo.ConvertTimeToUtc(
                    DateTime.SpecifyKind(toLocal, DateTimeKind.Unspecified), tz);

                var occurrences = GenerateOccurrencesWithIcalNet(
                    r.Id,
                    r.StartDate,
                    r.BaseTime,
                    r.RRULE,
                    r.EXDATE,
                    r.EndDate,
                    r.TimeZoneId,
                    fromUtc,
                    toUtc
                );

                foreach (var dt in occurrences)
                {
                    if (dt >= fromLocal && dt < toLocal)
                    {
                        result.Add(new UpcomingOccurrenceDto
                        {
                            ReminderId = r.Id,
                            Title = r.Title,
                            Message = r.Message,
                            DueDateTime = dt,
                            Type = r.Type,
                            IsMedication = r.Type == ReminderType.Medication,
                            Dosage = r.Dosage,
                            Status = dt < now.AddMinutes(-30)
                                ? ReminderStatus.Overdue
                                : ReminderStatus.Pending,
                            CanSnooze = true
                        });
                    }
                }
            }

            return result.OrderBy(x => x.DueDateTime).ToList();
        }

        private static ReminderStatus GetStatus(byte status, DateTime dueDateTime, DateTime now)
        {
            return status switch
            {
                1 => ReminderStatus.Completed,
                2 => ReminderStatus.Skipped,
                _ => dueDateTime < now.AddMinutes(-30)
                    ? ReminderStatus.Overdue
                    : ReminderStatus.Pending
            };
        }

        #region ==================== OCCURRENCE GENERATOR ====================

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

            TimeSpan? effectiveBaseTime = hasExplicitTimeInRrule ? null : baseTime;

            var dtStartLocal = effectiveBaseTime.HasValue
                ? startDate.Date + effectiveBaseTime.Value
                : startDate.Date;

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

            // ✅ UNTIL لازم DateTime وليس CalDateTime
            if (endDate.HasValue)
            {
                var untilLocal = endDate.Value.Date.AddDays(1).AddTicks(-1);
                var untilUtc = TimeZoneInfo.ConvertTimeToUtc(untilLocal, tz);
                pattern.Until = untilUtc;
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

            // ✅ ✅ التحويل الصحيح من CalDateTime → DateTime
            var occurrences = calendar.GetOccurrences(fromUtc, toUtc)
                .Select(o => o.Period.StartTime.AsSystemLocal)
                .Where(dt => dt >= dtStartLocal)
                .OrderBy(dt => dt)
                .ToList();

            return occurrences.Any()
                ? occurrences
                : new List<DateTime> { dtStartLocal };
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


        #endregion

        #endregion

        #region ==================== 3. Confirm / Snooze / Skip (مع تحديث الكاش فورًا) ====================

        public async Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, IntakeStatus intake = IntakeStatus.Taken)
        {
            await ValidateReminderAccess(reminderId, patientId);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == dueDateTime)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = dueDateTime };

            log.Status = ReminderStatus.Completed;
            log.IntakeStatus = intake;
            log.ConfirmedAt = DateTime.UtcNow;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            await _context.Database.ExecuteSqlRawAsync(
                "UPDATE ReminderOccurrencesCache SET Status = 1 WHERE ReminderId = @p0 AND DueDateTime = @p1",
                reminderId, dueDateTime);
        }

        public async Task SnoozeOccurrenceAsync(int reminderId, DateTime originalDue, int patientId, int minutes = 15)
        {
            await ValidateReminderAccess(reminderId, patientId);

            var newDue = originalDue.AddMinutes(minutes);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == originalDue)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = originalDue };

            log.DueDateTime = newDue;
            log.Status = ReminderStatus.Pending;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            await _context.Database.ExecuteSqlRawAsync(@"
                DELETE FROM ReminderOccurrencesCache WHERE ReminderId = @p0 AND DueDateTime = @p1;
                INSERT INTO ReminderOccurrencesCache (PatientId, ReminderId, DueDateTime, Title, Message, Type, Dosage, Status)
                SELECT PatientId, ReminderId, @p2, Title, Message, Type, Dosage, 0
                FROM ReminderOccurrencesCache
                WHERE ReminderId = @p0 AND DueDateTime = @p1",
                reminderId, originalDue, newDue);
        }

        public async Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId)
        {
            await ValidateReminderAccess(reminderId, patientId);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == dueDateTime)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = dueDateTime };

            log.Status = ReminderStatus.Skipped;
            log.IntakeStatus = IntakeStatus.Skipped;
            log.ConfirmedAt = DateTime.UtcNow;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            await _context.Database.ExecuteSqlRawAsync(
                "UPDATE ReminderOccurrencesCache SET Status = 2 WHERE ReminderId = @p0 AND DueDateTime = @p1",
                reminderId, dueDateTime);
        }

        #endregion

        #region ==================== 4. CRUD + Helpers ====================

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
            reminder.Status = ReminderStatus.Dismissed;
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
            var next = await _context.ReminderOccurrencesCache
                .Where(c => c.ReminderId == r.Id && c.DueDateTime >= DateTime.Today)
                .OrderBy(c => c.DueDateTime)
                .Select(c => (DateTime?)c.DueDateTime)
                .FirstOrDefaultAsync();

            var taken = await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == r.Id && l.Status == ReminderStatus.Completed);

            var total = await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == r.Id);

            return new ReminderV2Dto
            {
                Id = r.Id,
                Title = r.Title,
                Type = r.Type,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                RRULE = r.RRULE,
                TimeZoneId = r.TimeZoneId,
                BaseTime = r.BaseTime,
                NextOccurrence = next,
                TakenCount = taken,
                TotalLogged = total,
                IsActive = r.IsActive
            };
        }

        #endregion

        #region ==================== Fast Fallback Generator (للـ Hybrid Mode) ====================

        private IEnumerable<DateTime> FastGenerateOccurrences(
            int reminderId,
            DateTime startDate,
            TimeSpan baseTime,
            string rrule,
            string timeZoneId,
            DateTime fromUtc,
            DateTime toUtc)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
            var startLocal = startDate.Date + baseTime;

            var fromLocal = TimeZoneInfo.ConvertTimeFromUtc(fromUtc, tz);
            var toLocal = TimeZoneInfo.ConvertTimeFromUtc(toUtc, tz);

            // مرة واحدة
            if (string.IsNullOrWhiteSpace(rrule) || rrule.Contains("FREQ=ONCE", StringComparison.OrdinalIgnoreCase))
            {
                if (startLocal >= fromLocal && startLocal < toLocal)
                    yield return startLocal;
                yield break;
            }

            // كل ساعات (مثلاً كل 8 ساعات)
            if (rrule.Contains("FREQ=HOURLY"))
            {
                int interval = 24;
                var parts = rrule.Split(';');
                foreach (var p in parts)
                {
                    if (p.StartsWith("INTERVAL="))
                        int.TryParse(p.Substring(9), out interval);
                }

                var current = startLocal.Date + baseTime;
                while (current < toLocal)
                {
                    if (current >= fromLocal)
                        yield return current;
                    current = current.AddHours(interval);
                }
                yield break;
            }

            // يومي
            if (rrule.Contains("FREQ=DAILY"))
            {
                var current = startLocal;
                while (current < toLocal)
                {
                    if (current >= fromLocal)
                        yield return current;
                    current = current.AddDays(1);
                }
                yield break;
            }

            // أسبوعي
            if (rrule.Contains("FREQ=WEEKLY"))
            {
                var current = startLocal;
                while (current < toLocal)
                {
                    if (current >= fromLocal)
                        yield return current;
                    current = current.AddDays(7);
                }
                yield break;
            }

            // Fallback آمن: يومي
            var fallback = startLocal;
            while (fallback < toLocal)
            {
                if (fallback >= fromLocal)
                    yield return fallback;
                fallback = fallback.AddDays(1);
            }
        }

        #endregion
    }
}