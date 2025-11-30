// File: Services/ReminderV2Service.cs
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.DTOs.V2.HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
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

        // 1. CREATE REMINDER
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
                    PrescriptionMedId = dto.PrescriptionMedId,
                    AppointmentId = dto.AppointmentId,
                    RRULE = string.IsNullOrWhiteSpace(dto.RRULE)
                        ? GenerateRRuleFromSimple(dto.Simple ?? new SimpleFrequency())
                        : dto.RRULE.Trim().ToUpperInvariant()
                };

                _context.ReminderV2s.Add(reminder);
                await _context.SaveChangesAsync();

                _logger.LogInformation("ReminderV2 created | ID: {Id} | Patient: {PatientId}", reminder.Id, patientId);
                return reminder;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create ReminderV2 for patient {PatientId}", patientId);
                throw;
            }
        }

        private string GenerateRRuleFromSimple(SimpleFrequency simple)
        {
            if (simple == null) return "FREQ=DAILY";

            var parts = new List<string>();

            switch (simple.Frequency)
            {
                case "Once":
                    return "FREQ=ONCE";

                case "Daily":
                    parts.Add("FREQ=DAILY");
                    parts.Add("INTERVAL=1");
                    break;

                case "Weekly":
                    parts.Add("FREQ=WEEKLY");
                    parts.Add("INTERVAL=1");
                    break;

                case "EveryXHours":
                    parts.Add($"FREQ=HOURLY");
                    parts.Add($"INTERVAL={simple.IntervalHours ?? 24}");
                    break;

                default:
                    parts.Add("FREQ=DAILY");
                    parts.Add("INTERVAL=1");
                    break;
            }

            if (simple.Times != null && simple.Times.Count > 0)
            {
                var hours = new List<string>();
                foreach (var timeStr in simple.Times)
                {
                    if (TimeSpan.TryParse(timeStr, out var time))
                    {
                        hours.Add(time.Hours.ToString()); // 8 أو 20
                    }
                }

                if (hours.Any())
                {
                    parts.Add($"BYHOUR={string.Join(",", hours)}");
                }
            }

            return string.Join(";", parts);
        }


        // 2. GET UPCOMING / TODAY (Virtual Core)
        public async Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30)
        {
            var fromUtc = DateTime.UtcNow.AddHours(-2);
            var toUtc = DateTime.UtcNow.AddDays(daysAhead);
            return await GetOccurrencesInRangeAsync(patientId, fromUtc, toUtc);
        }

        public async Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById("Africa/Cairo");
            var todayLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz).Date;
            var tomorrowLocal = todayLocal.AddDays(1);

            var fromUtc = TimeZoneInfo.ConvertTimeToUtc(todayLocal, tz);
            var toUtc = TimeZoneInfo.ConvertTimeToUtc(tomorrowLocal, tz);

            return await GetOccurrencesInRangeAsync(patientId, fromUtc, toUtc);
        }

        private async Task<List<UpcomingOccurrenceDto>> GetOccurrencesInRangeAsync(int patientId, DateTime fromUtc, DateTime toUtc)
        {
            var reminders = await _context.ReminderV2s
                .Where(r => r.PatientId == patientId && r.IsActive)
                .Include(r => r.PrescriptionMed)
                .ToListAsync();

            var result = new List<UpcomingOccurrenceDto>();

            foreach (var reminder in reminders)
            {
                var occurrences = GenerateOccurrences(reminder, fromUtc, toUtc);
                foreach (var dueLocal in occurrences)
                {
                    var status = await GetOccurrenceStatusAsync(reminder.Id, dueLocal);

                    result.Add(new UpcomingOccurrenceDto
                    {
                        ReminderId = reminder.Id,
                        Title = reminder.Title,
                        Message = reminder.Message,
                        DueDateTime = dueLocal,
                        Type = reminder.Type,
                        IsMedication = reminder.Type == ReminderType.Medication,
                        Dosage = reminder.PrescriptionMed != null
                            ? $"{reminder.PrescriptionMed.Dosage} {reminder.PrescriptionMed.MedicationName}"
                            : null,
                        Status = status,
                        CanSnooze = status == ReminderStatus.Pending || status == ReminderStatus.Active
                    });
                }
            }

            return result.OrderBy(x => x.DueDateTime).ToList();
        }


        // 3. GENERATE OCCURRENCES 
        private IEnumerable<DateTime> GenerateOccurrences(ReminderV2 reminder, DateTime fromUtc, DateTime toUtc)
        {
            var results = new List<DateTime>();

            // حالة خاصة: مرة واحدة أو RRULE فاضي
            if (string.IsNullOrWhiteSpace(reminder.RRULE) ||
                reminder.RRULE.Trim().Equals("FREQ=ONCE", StringComparison.OrdinalIgnoreCase))
            {
                var singleTime = reminder.StartDate.Date + (reminder.BaseTime ?? TimeSpan.FromHours(8));
                if (singleTime >= fromUtc && singleTime < toUtc)
                    results.Add(singleTime);
                return results;
            }

            try
            {
                // بناء الـ CalendarEvent زي الـ example الرسمي
                var calendarEvent = new CalendarEvent
                {
                    DtStart = new CalDateTime(reminder.StartDate.Date + (reminder.BaseTime ?? TimeSpan.Zero)),
                    RecurrenceRules = { new RecurrencePattern(reminder.RRULE) }
                };

                // الطريقة الرسمية من Wiki v5.x: GetOccurrences() بدون parameters
                var allOccurrences = calendarEvent.GetOccurrences();

                var tz = TimeZoneInfo.FindSystemTimeZoneById(reminder.TimeZoneId);

                foreach (var occ in allOccurrences)
                {
                    
                    if (results.Count > 10000)
                    {
                        _logger.LogWarning("Too many occurrences generated for reminder {Id}, truncating results", reminder.Id);
                        break; 
                    }
                    var localTime = TimeZoneInfo.ConvertTimeFromUtc(occ.Period.StartTime.AsUtc, tz);

                    if (reminder.BaseTime.HasValue && reminder.BaseTime.Value != TimeSpan.Zero)
                        localTime = localTime.Date + reminder.BaseTime.Value;

                    // فلترة للنطاق المطلوب (بدل ما نمرر parameters للـ method)
                    if (localTime >= fromUtc && localTime < toUtc)
                        results.Add(localTime);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "RRULE evaluation failed for reminder {Id}, using fallback", reminder.Id);
            }

            // Fallback قوي وآمن دائمًا
            if (!results.Any())
            {
                var current = reminder.StartDate.Date + (reminder.BaseTime ?? TimeSpan.FromHours(8));
                while (current < toUtc)
                {
                    if (current >= fromUtc)
                        results.Add(current);
                    current = current.AddDays(1);
                }
            }

            return results.OrderBy(d => d);
        }


        // 4. GET OCCURRENCE STATUS
        private async Task<ReminderStatus> GetOccurrenceStatusAsync(int reminderId, DateTime dueLocal)
        {
            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == dueLocal);

            if (log != null) return log.Status;

            return dueLocal < DateTime.Now.AddMinutes(-30)
                ? ReminderStatus.Overdue
                : ReminderStatus.Pending;
        }

        // 5. CONFIRM / SNOOZE / SKIP
        public async Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, IntakeStatus intake = IntakeStatus.Taken)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == dueDateTime)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = dueDateTime };

            log.Status = ReminderStatus.Completed;
            log.IntakeStatus = intake;
            log.ConfirmedAt = DateTime.UtcNow;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Dose CONFIRMED | Reminder {Id} | {Time}", reminderId, dueDateTime);
        }

        public async Task SnoozeOccurrenceAsync(int reminderId, DateTime originalDue, int patientId, int minutes = 15)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            var newDue = originalDue.AddMinutes(minutes);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == originalDue)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = originalDue };

            log.DueDateTime = newDue;
            log.Status = ReminderStatus.Pending;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Dose SNOOZED | Reminder {Id} | From {Old} → {New}", reminderId, originalDue, newDue);
        }

        public async Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);

            var log = await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId && l.DueDateTime == dueDateTime)
                ?? new ReminderOccurrenceLog { ReminderId = reminderId, DueDateTime = dueDateTime };

            log.Status = ReminderStatus.Skipped;
            log.IntakeStatus = IntakeStatus.Skipped;
            log.ConfirmedAt = DateTime.UtcNow;

            if (log.Id == 0) _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Dose SKIPPED | Reminder {Id} | {Time}", reminderId, dueDateTime);
        }


        // 6. CRUD + HELPERS
        public async Task<ReminderV2Dto> GetByIdAsync(int reminderId, int patientId)
        {
            var reminder = await _context.ReminderV2s
                .Include(r => r.PrescriptionMed)
                .FirstOrDefaultAsync(r => r.Id == reminderId && r.PatientId == patientId)
                ?? throw new KeyNotFoundException("Reminder not found");

            return MapToDto(reminder);
        }

        public async Task<List<ReminderV2Dto>> GetAllAsync(int patientId)
        {
            var reminders = await _context.ReminderV2s
                .Where(r => r.PatientId == patientId)
                .ToListAsync();

            return reminders.Select(MapToDto).ToList();
        }

        public async Task UpdateAsync(int reminderId, int patientId, UpdateReminderV2Dto dto)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);

            if (!string.IsNullOrWhiteSpace(dto.Title)) reminder.Title = dto.Title;
            if (dto.Message != null) reminder.Message = dto.Message;
            if (dto.StartDate.HasValue) reminder.StartDate = dto.StartDate.Value.Date;
            if (dto.EndDate.HasValue) reminder.EndDate = dto.EndDate.Value.Date;
            if (dto.TimeZoneId != null) reminder.TimeZoneId = dto.TimeZoneId;
            if (dto.IsActive.HasValue) reminder.IsActive = dto.IsActive.Value;

            // === الجزء الجديد والمهم جدًا ===
            if (!string.IsNullOrWhiteSpace(dto.RRULE))
            {
                reminder.RRULE = dto.RRULE.Trim().ToUpperInvariant();
            }
            else if (dto.Simple != null)
            {
                reminder.RRULE = GenerateRRuleFromSimple(dto.Simple);
            }
            // === انتهى ===

            reminder.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteAsync(int reminderId, int patientId)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            reminder.IsActive = false;
            reminder.Status = ReminderStatus.Dismissed;
            reminder.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        private async Task<ReminderV2> ValidateReminderAccess(int reminderId, int patientId)
        {
            var reminder = await _context.ReminderV2s
                .FirstOrDefaultAsync(r => r.Id == reminderId && r.PatientId == patientId);

            return reminder ?? throw new UnauthorizedAccessException("Access denied or reminder not found");
        }

        private ReminderV2Dto MapToDto(ReminderV2 r)
        {
            var next = GenerateOccurrences(r, DateTime.UtcNow, DateTime.UtcNow.AddMonths(6)).FirstOrDefault();

            return new ReminderV2Dto
            {
                Id = r.Id,
                Title = r.Title,
                Type = r.Type,
                StartDate = r.StartDate,
                EndDate = r.EndDate,
                RRULE = r.RRULE,
                TimeZoneId = r.TimeZoneId,
                NextOccurrence = next,
                TakenCount = _context.ReminderOccurrenceLogs
                    .Count(l => l.ReminderId == r.Id && l.Status == ReminderStatus.Completed),
                TotalLogged = _context.ReminderOccurrenceLogs
                    .Count(l => l.ReminderId == r.Id),
                IsActive = r.IsActive
            };
        }

    }
}