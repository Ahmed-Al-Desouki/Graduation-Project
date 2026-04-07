// Infrastructure/Services/ReminderV2Service.cs
using Hangfire;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;
using Ical.Net;
using Ical.Net.CalendarComponents;
using Ical.Net.DataTypes;
using Microsoft.Extensions.Logging;
using System.Text.RegularExpressions;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;
using WelloraHealthCareManagment.Infrastructure.Helpers;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class ReminderV2Service : IReminderV2Service
    {
        private readonly IReminderRepository _reminderRepository;
        private readonly IReminderOccurrencesCacheRepository _cacheRepository;
        private readonly IReminderOccurrenceLogRepository _logRepository;
        private readonly ITimezoneHelper _timezoneHelper;
        private readonly ILogger<ReminderV2Service> _logger;

        // Constants
        private const int WINDOW_OPENS_MINUTES = 30;
        private const int GRACE_PERIOD_HOURS = 2;
        private const int OVERDUE_THRESHOLD_MINUTES = 30;

        public ReminderV2Service(
            IReminderRepository reminderRepository,
            IReminderOccurrencesCacheRepository cacheRepository,
            IReminderOccurrenceLogRepository logRepository,
            ITimezoneHelper timezoneHelper,
            ILogger<ReminderV2Service> logger)
        {
            _reminderRepository = reminderRepository;
            _cacheRepository = cacheRepository;
            _logRepository = logRepository;
            _timezoneHelper = timezoneHelper;
            _logger = logger;
        }

        #region ==================== CREATE & UPDATE ====================

        public async Task<ReminderV2> CreateAsync(int patientId, CreateReminderV2Dto dto)
        {
            var userTimeZone = dto.TimeZoneId ?? "Africa/Cairo";

            var startDateUtc = _timezoneHelper.ConvertUserTimezoneToUtc(dto.StartDate, userTimeZone);
            var endDateUtc = dto.EndDate.HasValue
                ? _timezoneHelper.ConvertUserTimezoneToUtc(dto.EndDate.Value, userTimeZone)
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
                StartDateUtc = startDateUtc,
                EndDateUtc = endDateUtc,
                TimeZoneId = userTimeZone,
                IsActive = true,
                IsSimpleEveryXHours = false,
                FirstDoseTime = null,
                IntervalHours = null,
                RRULE = null,
                PrescriptionId = dto.PrescriptionId,      
                PrescriptionItemId = dto.PrescriptionItemId,
                AppointmentId = dto.AppointmentId
            };

            // MODE 1: SIMPLE MODE
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
            // MODE 2: RRULE MODE
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
            else if (dto.PrescriptionItemId.HasValue && string.IsNullOrWhiteSpace(dto.RRULE))
            {
                // الـ حالة الجديدة: Prescription مع mixed minutes → RRULE = null مسموح
                // هنعتمد على التوليد المنفصل في OccurrenceGenerator
                reminder.IsSimpleEveryXHours = false;
                reminder.RRULE = null;
                reminder.FirstDoseTime = null;
                reminder.IntervalHours = null;
                _logger.LogInformation(
                    "Reminder {Id} created for PrescriptionItem {ItemId} with NO RRULE (mixed times mode)",
                    reminder.Id, dto.PrescriptionItemId);
            }
            else
            {
                throw new ArgumentException(
                    "Reminder must specify either Simple (EveryXHours with Times) or RRULE");
            }

            await _reminderRepository.AddAsync(reminder);

            //BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
            //    j => j.GenerateForPatientAsync(patientId));

            if (reminder.PatientId.HasValue && !reminder.PrescriptionItemId.HasValue)
            {
                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                        j => j.GenerateForPatientAsync(reminder.PatientId.Value));
            }
            if (reminder.DoctorId.HasValue)
            {
                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForDoctorAsync(reminder.DoctorId.Value));
            }

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

            if (dto.StartDate.HasValue)
                reminder.StartDateUtc = _timezoneHelper.ConvertUserTimezoneToUtc(dto.StartDate.Value, userTimeZone);
            if (dto.EndDate.HasValue)
                reminder.EndDateUtc = _timezoneHelper.ConvertUserTimezoneToUtc(dto.EndDate.Value, userTimeZone);

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
            await _reminderRepository.UpdateAsync(reminder);

            //BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
            //    j => j.GenerateForPatientAsync(patientId));

            if (reminder.PatientId.HasValue && !reminder.PrescriptionItemId.HasValue)
            {
                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForPatientAsync(reminder.PatientId.Value));
            }
            if (reminder.DoctorId.HasValue)
            {
                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForDoctorAsync(reminder.DoctorId.Value));
            }
        }

        #endregion

        #region ==================== GET TODAY & UPCOMING ====================

        public async Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId)
        {
            var todayUtc = DateTime.UtcNow.Date;
            var tomorrowUtc = todayUtc.AddDays(1);
            return await GetFromCacheWithTimezoneConversion(patientId, todayUtc, tomorrowUtc);
        }

        public async Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30)
        {
            var fromUtc = DateTime.UtcNow.Date;
            var toUtc = fromUtc.AddDays(daysAhead);
            return await GetFromCacheWithTimezoneConversion(patientId, fromUtc, toUtc);
        }

        private async Task<List<UpcomingOccurrenceDto>> GetFromCacheWithTimezoneConversion(
            int patientId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            var fromUtc = _timezoneHelper.EnsureUtc(fromUtcInclusive);
            var toUtc = _timezoneHelper.EnsureUtc(toUtcExclusive);
            var nowUtc = DateTime.UtcNow;

            var cached = await _cacheRepository.GetByPatientAndDateRangeAsync(
                patientId, fromUtc, toUtc);

            if (!cached.Any())
            {
                _logger.LogWarning("Cache miss for patient {PatientId}", patientId);
                try
                {
                    var result = await GenerateUpcomingOnTheFly(patientId, fromUtc, toUtc);
                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
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
                var displayStatus = DeriveDisplayStatus(x.Status, _timezoneHelper.EnsureUtc(x.DueDateTimeUtc), nowUtc);
                var (canConfirm, canSnooze, canSkip, reason) = EvaluateActionAvailability(
                    displayStatus,
                    _timezoneHelper.EnsureUtc(x.DueDateTimeUtc),
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
                    IsMedication = x.Type == ReminderEnums.ReminderType.Medication,
                    Dosage = x.Dosage,
                    Status = displayStatus,
                    CanConfirm = canConfirm,
                    CanSnooze = canSnooze,
                    CanSkip = canSkip,
                    ActionUnavailableReason = reason
                };
            }).ToList();
        }

        #endregion

        #region ==================== OCCURRENCE GENERATOR ====================

        private async Task<List<UpcomingOccurrenceDto>> GenerateUpcomingOnTheFly(
            int patientId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            var reminders = await _reminderRepository.GetActiveByPatientIdAsync(patientId);

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
                            ? ReminderEnums.OccurrenceStatus.Missed
                            : ReminderEnums.OccurrenceStatus.Pending;

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
                            DueDateTime = _timezoneHelper.ConvertUtcToUserTimezone(_timezoneHelper.EnsureUtc(dtUtc), reminder.TimeZoneId),
                            TimeZoneId = reminder.TimeZoneId,
                            Type = reminder.Type,
                            IsMedication = reminder.Type == ReminderEnums.ReminderType.Medication,
                            Dosage = reminder.PrescriptionItem != null
                                ? $"{reminder.PrescriptionItem.Dosage} {reminder.PrescriptionItem.MedicationName}"
                                : null,
                            Status = displayStatus,
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

        #endregion

        #region ==================== CONFIRM / SNOOZE / SKIP ====================

        public async Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, ReminderEnums.IntakeStatus intake = ReminderEnums.IntakeStatus.Taken)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            var dueDateTimeUtc = _timezoneHelper.ConvertUserTimezoneToUtc(dueDateTime, reminder.TimeZoneId);
            var nowUtc = DateTime.UtcNow;

            _logger.LogInformation(
                "Confirming: Reminder={ReminderId}, DueLocal={DueLocal}, DueUtc={DueUtc}, Patient={PatientId}",
                reminderId, dueDateTime, dueDateTimeUtc, patientId);

            ValidateActionTiming(dueDateTimeUtc, "confirm");

            var existingLog = await _logRepository.GetByReminderAndDueDateAsync(reminderId, dueDateTimeUtc);

            if (existingLog?.Status == ReminderEnums.OccurrenceStatus.Taken)
            {
                _logger.LogInformation("Idempotent confirm - already taken: {ReminderId} at {Due}", reminderId, dueDateTimeUtc);
                return;
            }

            var log = existingLog ?? new ReminderOccurrenceLog
            {
                ReminderId = reminderId,
                DueDateTimeUtc = dueDateTimeUtc,
                DueDateTime = dueDateTime,
                PatientId = patientId
            };

            log.Status = ReminderEnums.OccurrenceStatus.Taken;
            log.IntakeStatus = intake;
            log.ConfirmedAt = nowUtc;
            log.ActionedAt = nowUtc;
            log.ActionedWithinWindow = true;

            if (log.Id == 0)
                await _logRepository.AddAsync(log);
            else
                await _logRepository.UpdateAsync(log);

            await _cacheRepository.UpdateStatusAsync(reminderId, dueDateTimeUtc, OccurrenceStatus.Taken);

            _logger.LogInformation(
                "Confirmed occurrence: Reminder={ReminderId}, DueUtc={Due}",
                reminderId, dueDateTimeUtc);
        }

        public async Task SnoozeOccurrenceAsync(int reminderId, DateTime originalDue, int patientId, int minutes = 15)
        {
            var reminder = await ValidateReminderAccess(reminderId, patientId);
            var originalDueUtc = _timezoneHelper.ConvertUserTimezoneToUtc(originalDue, reminder.TimeZoneId);
            var newDueUtc = originalDueUtc.AddMinutes(minutes);

            _logger.LogInformation(
                "Snoozing occurrence: Reminder={ReminderId}, OriginalDueLocal={OriginalLocal}, OriginalDueUtc={OriginalUtc}, Minutes={Minutes}",
                reminderId, originalDue, originalDueUtc, minutes);

            ValidateActionTiming(originalDueUtc, "snooze");

            var log = await _logRepository.GetByReminderAndDueDateAsync(reminderId, originalDueUtc)
                ?? new ReminderOccurrenceLog
                {
                    ReminderId = reminderId,
                    DueDateTimeUtc = originalDueUtc,
                    DueDateTime = originalDue,
                    PatientId = patientId
                };

            log.Status = ReminderEnums.OccurrenceStatus.Snoozed;
            log.ActionedAt = DateTime.UtcNow;

            if (log.Id == 0)
                await _logRepository.AddAsync(log);
            else
                await _logRepository.UpdateAsync(log);

            var newDueLocal = _timezoneHelper.ConvertUtcToUserTimezone(newDueUtc, reminder.TimeZoneId);

            var newLog = new ReminderOccurrenceLog
            {
                ReminderId = reminderId,
                PatientId = patientId,
                DueDateTimeUtc = newDueUtc,
                DueDateTime = newDueLocal,
                Status = ReminderEnums.OccurrenceStatus.Pending,
                IsSnoozeFromOriginal = true,
                OriginalDueDateTime = originalDueUtc,
                CreatedAt = DateTime.UtcNow
            };
            await _logRepository.AddAsync(newLog);

            await _cacheRepository.UpdateStatusAsync(reminderId, originalDueUtc, OccurrenceStatus.Snoozed);

            _logger.LogInformation(
                "Successfully snoozed occurrence: Reminder={ReminderId}, OriginalDue={Original}, NewDue={New}",
                reminderId, originalDueUtc, newDueUtc);
        }

        public async Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId)
        {
            await ValidateReminderAccess(reminderId, patientId);
            var dueDateTimeUtc = _timezoneHelper.EnsureUtc(dueDateTime);

            var log = await _logRepository.GetByReminderAndDueDateAsync(reminderId, dueDateTimeUtc)
                ?? new ReminderOccurrenceLog
                {
                    ReminderId = reminderId,
                    DueDateTimeUtc = dueDateTimeUtc,
                    DueDateTime = dueDateTime,
                    PatientId = patientId
                };

            log.Status = ReminderEnums.OccurrenceStatus.Skipped;
            log.IntakeStatus = ReminderEnums.IntakeStatus.Skipped;
            log.ActionedAt = DateTime.UtcNow;

            if (log.Id == 0)
                await _logRepository.AddAsync(log);
            else
                await _logRepository.UpdateAsync(log);

            await _cacheRepository.UpdateStatusAsync(reminderId, dueDateTimeUtc, OccurrenceStatus.Skipped);
        }

        #endregion

        #region ==================== CRUD & HELPERS ====================

        public async Task<ReminderV2Dto> GetByIdAsync(int reminderId, int patientId)
        {
            var reminder = await _reminderRepository.GetByIdAsync(reminderId, patientId)
                ?? throw new KeyNotFoundException("Reminder not found");

            return await MapToDtoAsync(reminder);
        }

        public async Task<List<ReminderV2Dto>> GetAllAsync(int patientId)
        {
            var reminders = await _reminderRepository.GetAllByPatientIdAsync(patientId);

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
            reminder.Status = ReminderEnums.ReminderStatus.Dismissed;
            reminder.UpdatedAt = DateTime.UtcNow;
            await _reminderRepository.UpdateAsync(reminder);

            if (!reminder.PrescriptionItemId.HasValue)
            {
                BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                    j => j.GenerateForPatientAsync(patientId));
            }
            else
            {
                // لو prescription reminder اتحذف، امسح كاشه مباشرةً
                await _cacheRepository.DeleteByReminderIdAsync(reminderId);
            }
        }

        private async Task<ReminderV2> ValidateReminderAccess(int reminderId, int patientId)
        {
            var reminder = await _reminderRepository.GetByIdAsync(reminderId, patientId);
            return reminder ?? throw new UnauthorizedAccessException("Access denied or reminder not found");
        }

        private async Task<ReminderV2Dto> MapToDtoAsync(ReminderV2 r)
        {
            var todayUtc = DateTime.UtcNow.Date;
            var tomorrowUtc = todayUtc.AddDays(1);

            // 1. نعرّف المتغير من غير قيمة أولية
            IEnumerable<ReminderOccurrencesCache> nextCache = Enumerable.Empty<ReminderOccurrencesCache>();

            // 2. لو فيه PatientId → نجيب الكاش
            if (r.PatientId.HasValue)
            {
                nextCache = await _cacheRepository.GetByPatientAndDateRangeAsync(
                    r.PatientId.Value,
                    todayUtc,
                    tomorrowUtc.AddDays(30));
            }

            var next = nextCache
                .Where(c => c.ReminderId == r.Id)
                .OrderBy(c => c.DueDateTimeUtc)
                .Select(c => (DateTime?)c.DueDateTimeUtc)
                .FirstOrDefault();

            var taken = await _logRepository.CountTakenByReminderIdAsync(r.Id);
            var total = await _logRepository.CountTotalByReminderIdAsync(r.Id);

            var nextOccurrence = next.HasValue
                ? _timezoneHelper.ConvertUtcToUserTimezone(
                    _timezoneHelper.EnsureUtc(next.Value),
                    r.TimeZoneId)
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

        #region ==================== TEMPORAL VALIDATION HELPERS ====================

        private void ValidateActionTiming(DateTime dueTimeUtc, string actionName)
        {
            var nowUtc = DateTime.UtcNow;
            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            const int ALLOWED_BEFORE_MINUTES = 30;
            const int ALLOWED_AFTER_HOURS = 24;

            if (minutesFromDue < -ALLOWED_BEFORE_MINUTES)
            {
                var minutesUntilAllowed = Math.Abs(minutesFromDue + ALLOWED_BEFORE_MINUTES);
                throw new InvalidOperationException(
                    $"Cannot {actionName} medication yet. Available in {minutesUntilAllowed:F0} minutes.");
            }

            if (minutesFromDue > ALLOWED_AFTER_HOURS * 60)
            {
                throw new InvalidOperationException(
                    $"Action window expired {(minutesFromDue - ALLOWED_AFTER_HOURS * 60):F0} minutes ago.");
            }
        }

        private static ReminderEnums.OccurrenceStatus DeriveDisplayStatus(ReminderEnums.OccurrenceStatus storedStatus, DateTime dueTimeUtc, DateTime nowUtc)
        {
            if (storedStatus is ReminderEnums.OccurrenceStatus.Taken or ReminderEnums.OccurrenceStatus.Skipped or ReminderEnums.OccurrenceStatus.Snoozed)
                return storedStatus;

            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            if (storedStatus == ReminderEnums.OccurrenceStatus.Scheduled && minutesFromDue >= -WINDOW_OPENS_MINUTES)
                return ReminderEnums.OccurrenceStatus.Pending;

            if (storedStatus == ReminderEnums.OccurrenceStatus.Pending && minutesFromDue > OVERDUE_THRESHOLD_MINUTES)
                return ReminderEnums.OccurrenceStatus.Missed;

            if (storedStatus == ReminderEnums.OccurrenceStatus.Missed && minutesFromDue > (GRACE_PERIOD_HOURS * 60))
                return ReminderEnums.OccurrenceStatus.Expired;

            return storedStatus;
        }

        private static (bool canConfirm, bool canSnooze, bool canSkip, string? reason) EvaluateActionAvailability(
            ReminderEnums.OccurrenceStatus status,
            DateTime dueTimeUtc,
            DateTime nowUtc)
        {
            if (status is ReminderEnums.OccurrenceStatus.Taken or ReminderEnums.OccurrenceStatus.Skipped)
                return (false, false, false, "Already completed");

            if (status == ReminderEnums.OccurrenceStatus.Snoozed)
                return (false, false, false, "Already snoozed");

            var minutesFromDue = (nowUtc - dueTimeUtc).TotalMinutes;

            if (minutesFromDue < -WINDOW_OPENS_MINUTES)
            {
                var minutesUntil = Math.Abs(minutesFromDue + WINDOW_OPENS_MINUTES);
                return (false, false, false, $"Available in {minutesUntil:F0} minutes");
            }

            if (minutesFromDue > (GRACE_PERIOD_HOURS * 60))
                return (false, false, true, "Window expired");

            return (true, true, true, null);
        }

        #endregion
    }
}