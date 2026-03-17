//using Microsoft.Extensions.DependencyInjection;
//using Microsoft.Extensions.Logging;
//using WelloraHealthCareManagement.Application.Interfaces;
//using WelloraHealthCareManagement.Domain.Entities;
//using WelloraHealthCareManagement.Domain.Enums;
//using WelloraHealthCareManagement.Domain.Exceptions;
//using WelloraHealthCareManagement.Domain.Factories;
//using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;
//using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;
//using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
//using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

//namespace WelloraHealthCareManagement.Infrastructure.Services
//{
//    public class DoctorScheduleService : IDoctorScheduleService
//    {
//        private readonly IDoctorScheduleRepository _scheduleRepository;
//        private readonly IScheduleExceptionRepository _exceptionRepository;
//        private readonly IUnitOfWork _unitOfWork;
//        private readonly ITimeSlotRepository _timeSlotRepository;
//        private readonly IAppointmentRepository _appointmentRepository;
//        private readonly IAppointmentReminderService _appointmentReminderService;
//        private readonly ITimeSlotGeneratorFactory _slotGeneratorFactory;
//        private readonly IServiceScopeFactory _serviceScopeFactory;
//        private readonly ILogger<DoctorScheduleService> _logger;

//        public DoctorScheduleService(
//            IDoctorScheduleRepository scheduleRepository,
//            IScheduleExceptionRepository exceptionRepository,
//            IUnitOfWork unitOfWork,
//            ITimeSlotRepository timeSlotRepository,
//            IAppointmentRepository appointmentRepository,
//            IAppointmentReminderService appointmentReminderService,
//            ITimeSlotGeneratorFactory slotGeneratorFactory,
//            IServiceScopeFactory serviceScopeFactory,
//            ILogger<DoctorScheduleService> logger)
//        {
//            _scheduleRepository = scheduleRepository;
//            _exceptionRepository = exceptionRepository;
//            _unitOfWork = unitOfWork;
//            _timeSlotRepository = timeSlotRepository;
//            _appointmentRepository = appointmentRepository;
//            _appointmentReminderService = appointmentReminderService;
//            _slotGeneratorFactory = slotGeneratorFactory;
//            _serviceScopeFactory = serviceScopeFactory;
//            _logger = logger;
//        }

//        private const int DEFAULT_BATCH_SIZE = 1000;
//        private const int ROLLING_WINDOW_MONTHS = 2;

//        public async Task<Guid> CreateScheduleAsync(
//            int doctorId,
//            CreateScheduleRequest request,
//            CancellationToken cancellationToken = default)
//        {
//            try
//            {
//                _logger.LogInformation(
//                    "Creating schedule for doctor {DoctorId} (Open-ended: {IsOpenEnded})",
//                    doctorId, !request.EffectiveToDate.HasValue);

//                // 1. Create template
//                var template = DoctorScheduleTemplate.Create(
//                    doctorId,
//                    request.TemplateName,
//                    request.SlotDurationMinutes,
//                    request.BufferTimeMinutes,
//                    request.EffectiveFromDate,
//                    request.EffectiveToDate
//                );

//                // 2. Add time ranges
//                foreach (var range in request.TimeRanges)
//                {
//                    template.AddTimeRange(range.DayOfWeek, range.StartTime, range.EndTime);
//                }

//                // 3. Deactivate other active templates
//                var activeTemplates = await _scheduleRepository
//                    .GetActiveTemplatesAsync(doctorId, cancellationToken);

//                foreach (var activeTemplate in activeTemplates)
//                {
//                    activeTemplate.Deactivate();
//                    await _scheduleRepository.UpdateAsync(activeTemplate, cancellationToken);
//                }

//                // 4. Save
//                await _scheduleRepository.AddAsync(template, cancellationToken);
//                await _unitOfWork.SaveChangesAsync(cancellationToken);

//                _logger.LogInformation(
//                    "Schedule {TemplateId} created (Open-ended: {IsOpenEnded})",
//                    template.Id, template.IsOpenEnded);

//                return template.Id;
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Error creating schedule for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        //public async Task UpdateScheduleAsync(
//        //    int doctorId,
//        //    UpdateScheduleRequest request,
//        //    CancellationToken cancellationToken = default)
//        //{
//        //    try
//        //    {
//        //        _logger.LogInformation("Updating schedule for doctor {DoctorId}", doctorId);

//        //        // 1. Get active template
//        //        var template = await _scheduleRepository
//        //            .GetActiveTemplateWithTimeRangesAsync(doctorId, cancellationToken);

//        //        if (template == null)
//        //            throw new DomainException("No active schedule found");

//        //        // 2. Track old state BEFORE any changes
//        //        var oldActiveDays = template.TimeRanges
//        //            .Where(tr => tr.IsAvailable)
//        //            .Select(tr => tr.DayOfWeek)
//        //            .ToHashSet();

//        //        // 3. Add new time ranges
//        //        var daysActuallyAdded = new List<DayOfWeek>();
//        //        foreach (var range in request.TimeRangesToAdd ?? new())
//        //        {
//        //            var existing = template.TimeRanges
//        //                .FirstOrDefault(tr => tr.DayOfWeek == range.DayOfWeek);

//        //            if (existing == null)
//        //            {
//        //                template.AddTimeRange(range.DayOfWeek, range.StartTime, range.EndTime);
//        //                daysActuallyAdded.Add(range.DayOfWeek);
//        //                _logger.LogInformation("Added new day: {Day}", range.DayOfWeek);
//        //            }
//        //            else if (!existing.IsAvailable)
//        //            {
//        //                existing.MarkAvailable();
//        //                existing.UpdateTime(range.StartTime, range.EndTime);
//        //                daysActuallyAdded.Add(range.DayOfWeek);
//        //                _logger.LogInformation("Re-enabled day: {Day}", range.DayOfWeek);
//        //            }
//        //            else
//        //            {
//        //                _logger.LogWarning("Day {Day} already active. Skipping.", range.DayOfWeek);
//        //            }
//        //        }

//        //        // 4. Remove time ranges + collect days to delete slots for
//        //        var daysToDeleteSlots = new List<DayOfWeek>();
//        //        foreach (var range in request.TimeRangesToRemove ?? new())
//        //        {
//        //            try
//        //            {
//        //                template.RemoveTimeRange(range.DayOfWeek);
//        //                daysToDeleteSlots.Add(range.DayOfWeek);
//        //                _logger.LogInformation("Removed day: {Day}", range.DayOfWeek);
//        //            }
//        //            catch (DomainException ex)
//        //            {
//        //                _logger.LogWarning(ex, "Could not remove day {Day}", range.DayOfWeek);
//        //            }
//        //        }

//        //        // 5. Update slot duration/buffer
//        //        if (request.NewSlotDurationMinutes.HasValue)
//        //            template.UpdateSlotDuration(request.NewSlotDurationMinutes.Value);

//        //        if (request.NewBufferTimeMinutes.HasValue)
//        //            template.UpdateBufferTime(request.NewBufferTimeMinutes.Value);

//        //        // 6. Save with retry - بس هنحفظ الـ template بس هنا
//        //        await SaveTemplateWithRetryAsync(
//        //            doctorId,
//        //            template,
//        //            daysActuallyAdded,      
//        //            daysToDeleteSlots,      
//        //            request,                
//        //            cancellationToken);

//        //        // 7. Delete Available slots for removed days
//        //        if (daysToDeleteSlots.Any())
//        //        {
//        //            await DeleteAvailableSlotsForDaysAsync(
//        //                doctorId, daysToDeleteSlots, cancellationToken);
//        //        }

//        //        // 8. Generate slots for NEW days only
//        //        if (daysActuallyAdded.Any())
//        //        {
//        //            _logger.LogInformation(
//        //                "Generating slots for new days: {Days}",
//        //                string.Join(", ", daysActuallyAdded));

//        //            using var scope = _serviceScopeFactory.CreateScope();
//        //            var timeSlotService = scope.ServiceProvider
//        //                .GetRequiredService<ITimeSlotService>();

//        //            await timeSlotService.GenerateSlotsAsync(
//        //                doctorId,
//        //                new GenerateSlotsRequest
//        //                {
//        //                    StartDate = DateTime.UtcNow.Date,
//        //                    EndDate = DateTime.UtcNow.Date.AddMonths(2),
//        //                    OnlyForDays = daysActuallyAdded,
//        //                    RegenerateExisting = false,
//        //                    BatchSize = 1000
//        //                },
//        //                cancellationToken);
//        //        }

//        //        _logger.LogInformation(
//        //            "Schedule updated successfully for doctor {DoctorId}. " +
//        //            "Added: {Added}, Removed: {Removed}",
//        //            doctorId,
//        //            string.Join(", ", daysActuallyAdded),
//        //            string.Join(", ", daysToDeleteSlots));
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        _logger.LogError(ex, "Error updating schedule for doctor {DoctorId}", doctorId);
//        //        throw;
//        //    }
//        //}

//        public async Task UpdateScheduleAsync(
//    int doctorId,
//    UpdateScheduleRequest request,
//    CancellationToken cancellationToken = default)
//        {
//            try
//            {
//                _logger.LogInformation("Updating schedule for doctor {DoctorId}", doctorId);

//                var template = await _scheduleRepository
//                    .GetActiveTemplateWithTimeRangesAsync(doctorId, cancellationToken);

//                if (template == null)
//                    throw new DomainException("No active schedule found");

//                var daysActuallyAdded = new List<DayOfWeek>();
//                var daysToDeleteSlots = new List<DayOfWeek>();
//                var daysTimeUpdated = new List<(DayOfWeek Day, TimeSpan Start, TimeSpan End)>();
//                bool settingsChanged = false;

//                // ── 1. إضافة / تعديل أيام ──────────────────────────────────────
//                foreach (var range in request.TimeRangesToAdd ?? new())
//                {
//                    var existing = template.TimeRanges
//                        .FirstOrDefault(tr => tr.DayOfWeek == range.DayOfWeek);

//                    if (existing == null)
//                    {
//                        // يوم جديد خالص
//                        template.AddTimeRange(range.DayOfWeek, range.StartTime, range.EndTime);
//                        daysActuallyAdded.Add(range.DayOfWeek);
//                        _logger.LogInformation("Added new day: {Day}", range.DayOfWeek);
//                    }
//                    else if (!existing.IsAvailable)
//                    {
//                        // يوم كان محذوف - نرجّعه
//                        existing.MarkAvailable();
//                        existing.UpdateTime(range.StartTime, range.EndTime);
//                        daysActuallyAdded.Add(range.DayOfWeek);
//                        _logger.LogInformation("Re-enabled day: {Day}", range.DayOfWeek);
//                    }
//                    else
//                    {
//                        // يوم موجود وشغال - نحدّث الوقت بس
//                        bool timeChanged = existing.StartTime != range.StartTime
//                                        || existing.EndTime != range.EndTime;
//                        if (timeChanged)
//                        {
//                            existing.UpdateTime(range.StartTime, range.EndTime);
//                            daysTimeUpdated.Add((range.DayOfWeek, range.StartTime, range.EndTime));
//                            _logger.LogInformation(
//                                "Updated time for day: {Day} → {Start}-{End}",
//                                range.DayOfWeek, range.StartTime, range.EndTime);
//                        }
//                        else
//                        {
//                            _logger.LogInformation(
//                                "Day {Day} already active with same time. No change.", range.DayOfWeek);
//                        }
//                    }
//                }

//                // ── 2. حذف أيام ────────────────────────────────────────────────
//                foreach (var day in request.TimeRangesToRemove ?? new())
//                {
//                    var existing = template.TimeRanges
//                        .FirstOrDefault(tr => tr.DayOfWeek == day && tr.IsAvailable);

//                    if (existing == null)
//                    {
//                        _logger.LogWarning("Day {Day} not found or already removed. Skipping.", day);
//                        continue;
//                    }

//                    try
//                    {
//                        template.RemoveTimeRange(day);
//                        daysToDeleteSlots.Add(day);
//                        _logger.LogInformation("Removed day: {Day}", day);
//                    }
//                    catch (DomainException ex)
//                    {
//                        _logger.LogWarning(ex, "Could not remove day {Day}", day);
//                    }
//                }
//                // ── 3. تغيير Duration / Buffer ──────────────────────────────────
//                if (request.NewSlotDurationMinutes.HasValue
//                    && request.NewSlotDurationMinutes.Value != template.SlotDurationMinutes)
//                {
//                    template.UpdateSlotDuration(request.NewSlotDurationMinutes.Value);
//                    settingsChanged = true;
//                    _logger.LogInformation(
//                        "Updated slot duration to {Duration} min", request.NewSlotDurationMinutes.Value);
//                }

//                if (request.NewBufferTimeMinutes.HasValue
//                    && request.NewBufferTimeMinutes.Value != template.BufferTimeMinutes)
//                {
//                    template.UpdateBufferTime(request.NewBufferTimeMinutes.Value);
//                    settingsChanged = true;
//                    _logger.LogInformation(
//                        "Updated buffer time to {Buffer} min", request.NewBufferTimeMinutes.Value);
//                }

//                // ── 4. Save ─────────────────────────────────────────────────────
//                await _scheduleRepository.UpdateAsync(template, cancellationToken);
//                await _unitOfWork.SaveChangesAsync(cancellationToken);

//                // ── 5. حذف / Block slots للأيام المحذوفة ────────────────────────
//                if (daysToDeleteSlots.Any())
//                {
//                    await BlockSlotsForRemovedDaysAsync(
//                        doctorId, daysToDeleteSlots, cancellationToken);
//                }

//                // ── 6. Update وقت الـ slots للأيام اللي اتغير وقتها ────────────
//                if (daysTimeUpdated.Any())
//                {
//                    await UpdateSlotTimesForDaysAsync(
//                        doctorId, daysTimeUpdated, template, cancellationToken);
//                }

//                // ── 7. توليد slots للأيام الجديدة أو المُرجَّعة ─────────────────
//                if (daysActuallyAdded.Any())
//                {
//                    _logger.LogInformation(
//                        "Generating slots for days: {Days}",
//                        string.Join(", ", daysActuallyAdded));

//                    using var scope = _serviceScopeFactory.CreateScope();
//                    var timeSlotService = scope.ServiceProvider
//                        .GetRequiredService<ITimeSlotService>();

//                    await timeSlotService.GenerateSlotsAsync(
//                        doctorId,
//                        new GenerateSlotsRequest
//                        {
//                            StartDate = DateTime.UtcNow.Date,
//                            EndDate = DateTime.UtcNow.Date.AddMonths(2),
//                            OnlyForDays = daysActuallyAdded,
//                            RegenerateExisting = false,
//                            BatchSize = 1000
//                        },
//                        cancellationToken);
//                }

//                // ── 8. إعادة توليد slots لو Duration أو Buffer اتغير ─────────────
//                if (settingsChanged)
//                {
//                    await RegenerateSlotsAfterSettingsChangeAsync(
//                        doctorId, template, cancellationToken);
//                }

//                _logger.LogInformation(
//                    "Schedule updated for doctor {DoctorId}. Added:{Added} Removed:{Removed} TimeUpdated:{TimeUpdated} SettingsChanged:{Settings}",
//                    doctorId,
//                    string.Join(",", daysActuallyAdded),
//                    string.Join(",", daysToDeleteSlots),
//                    string.Join(",", daysTimeUpdated.Select(d => d.Day)),
//                    settingsChanged);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Error updating schedule for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        // ── Block slots للأيام المحذوفة (من النهارده مش من بكره) ──────────────
//        private async Task BlockSlotsForRemovedDaysAsync(
//            int doctorId,
//            List<DayOfWeek> days,
//            CancellationToken cancellationToken)
//        {
//            var fromDate = DateTime.UtcNow.Date; // من النهارده مش من بكره
//            var toDate = fromDate.AddMonths(3);

//            var allSlots = await _timeSlotRepository
//                .GetSlotsForDaysInRangeAsync(doctorId, days, fromDate, toDate, cancellationToken);

//            if (!allSlots.Any()) return;

//            foreach (var slot in allSlots)
//            {
//                if (slot.Status == SlotStatus.Booked)
//                {
//                    var appointment = await _appointmentRepository
//                        .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

//                    if (appointment != null)
//                    {
//                        appointment.Cancel(
//                            CancelledBy.Doctor,
//                            reason: "Doctor removed this day from their schedule");
//                        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
//                        await _appointmentReminderService.CancelAppointmentRemindersAsync(
//                            appointment.Id, appointment.PatientId, cancellationToken);
//                    }
//                }

//                slot.MakeAvailable();
//                slot.Block();
//                await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//            }

//            await _unitOfWork.SaveChangesAsync(cancellationToken);

//            _logger.LogInformation(
//                "Blocked {Count} slots for removed days: {Days}",
//                allSlots.Count, string.Join(", ", days));
//        }

//        // ── Update وقت الـ slots للأيام اللي اتغير وقتها ────────────────────────
//        private async Task UpdateSlotTimesForDaysAsync(
//            int doctorId,
//            List<(DayOfWeek Day, TimeSpan Start, TimeSpan End)> daysTimeUpdated,
//            DoctorScheduleTemplate template,
//            CancellationToken cancellationToken)
//        {
//            var fromDate = DateTime.UtcNow.Date;
//            var toDate = fromDate.AddMonths(3);
//            var days = daysTimeUpdated.Select(d => d.Day).ToList();

//            var allSlots = await _timeSlotRepository
//                .GetSlotsForDaysInRangeAsync(doctorId, days, fromDate, toDate, cancellationToken);

//            if (!allSlots.Any()) return;

//            // بنولد slots جديدة عشان نحسب الـ StartTime/EndTime الجديدة
//            var newSlotsGenerated = _slotGeneratorFactory.GenerateSlotsForPeriod(
//                template, fromDate, toDate,
//                await _exceptionRepository.GetExceptionsForPeriodAsync(
//                    doctorId, fromDate, toDate, cancellationToken));

//            // بنحول الـ new slots لـ dictionary عشان نستخدمها في الـ lookup
//            var newSlotsDict = newSlotsGenerated
//                .Where(s => days.Contains(s.SlotDate.DayOfWeek))
//                .GroupBy(s => new { Date = s.SlotDate.Date, s.StartTime })
//                .ToDictionary(g => g.Key, g => g.First());

//            int updatedCount = 0;

//            foreach (var slot in allSlots)
//            {
//                // نلاقي الـ new slot المقابلة
//                var matchedNew = newSlotsDict
//                    .Values
//                    .FirstOrDefault(ns =>
//                        ns.SlotDate.Date == slot.SlotDate.Date &&
//                        ns.StartTime == slot.StartTime);

//                if (matchedNew != null && slot.EndTime != matchedNew.EndTime)
//                {
//                    slot.UpdateTimes(slot.StartTime, matchedNew.EndTime);
//                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//                    updatedCount++;
//                }
//            }

//            if (updatedCount > 0)
//            {
//                await _unitOfWork.SaveChangesAsync(cancellationToken);
//                _logger.LogInformation(
//                    "Updated end times for {Count} slots in days: {Days}",
//                    updatedCount, string.Join(", ", days));
//            }
//        }

//        // ── إعادة توليد slots بعد تغيير Duration أو Buffer ──────────────────────
//        private async Task RegenerateSlotsAfterSettingsChangeAsync(
//            int doctorId,
//            DoctorScheduleTemplate template,
//            CancellationToken cancellationToken)
//        {
//            _logger.LogInformation(
//                "Regenerating slots after settings change for doctor {DoctorId}", doctorId);

//            using var scope = _serviceScopeFactory.CreateScope();
//            var timeSlotService = scope.ServiceProvider
//                .GetRequiredService<ITimeSlotService>();

//            await timeSlotService.GenerateSlotsAsync(
//                doctorId,
//                new GenerateSlotsRequest
//                {
//                    StartDate = DateTime.UtcNow.Date,
//                    EndDate = DateTime.UtcNow.Date.AddMonths(2),
//                    OnlyForDays = null,          // كل الأيام
//                    RegenerateExisting = true,          // نعمل update للـ existing slots
//                    BatchSize = 1000
//                },
//                cancellationToken);
//        }

//        private async Task SaveTemplateWithRetryAsync(
//            int doctorId,
//            DoctorScheduleTemplate template,
//            List<DayOfWeek> daysToAdd,
//            List<DayOfWeek> daysToRemove,
//            UpdateScheduleRequest request,
//            CancellationToken cancellationToken)
//        {
//            // Template فقط بدون TimeRanges في الـ EF tracker
//            await _scheduleRepository.UpdateAsync(template, cancellationToken);
//            await _unitOfWork.SaveChangesAsync(cancellationToken);
//        }
//        private async Task DeleteAvailableSlotsForDaysAsync(
//             int doctorId,
//             List<DayOfWeek> days,
//             CancellationToken cancellationToken)
//        {
//            var fromDate = DateTime.UtcNow.Date.AddDays(1);
//            var toDate = fromDate.AddMonths(3);

//            var allSlots = await _timeSlotRepository
//                .GetSlotsForDaysInRangeAsync(doctorId, days, fromDate, toDate, cancellationToken);

//            if (!allSlots.Any()) return;

//            foreach (var slot in allSlots)
//            {
//                if (slot.Status == SlotStatus.Booked)
//                {
//                    // لغّي الـ appointment بس - من غير ما نحذف أي حاجة
//                    var appointment = await _appointmentRepository
//                        .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

//                    if (appointment != null)
//                    {
//                        appointment.Cancel(
//                            CancelledBy.Doctor,
//                            reason: "Doctor removed this day from their schedule");

//                        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

//                        await _appointmentReminderService.CancelAppointmentRemindersAsync(
//                            appointment.Id,
//                            appointment.PatientId,
//                            cancellationToken);
//                    }
//                }

//                // كل الـ slots تتبلوك بدل الحذف
//                slot.MakeAvailable();
//                slot.Block();
//                await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//            }

//            await _unitOfWork.SaveChangesAsync(cancellationToken);

//            _logger.LogInformation(
//                "Blocked {Count} slots for removed days {Days}",
//                allSlots.Count,
//                string.Join(", ", days));
//        }

//        public async Task<object?> GetActiveScheduleAsync(
//            int doctorId,
//            CancellationToken cancellationToken = default)
//        {
//            var template = await _scheduleRepository
//                .GetActiveTemplateAsync(doctorId, cancellationToken);

//            if (template == null)
//                return null;

//            return new
//            {
//                template.Id,
//                template.TemplateName,
//                template.SlotDurationMinutes,
//                template.BufferTimeMinutes,
//                template.EffectiveFromDate,
//                template.EffectiveToDate,
//                TimeRanges = template.TimeRanges.Select(tr => new
//                {
//                    tr.DayOfWeek,
//                    tr.StartTime,
//                    tr.EndTime,
//                    tr.IsAvailable
//                })
//            };
//        }

//        public async Task AddDayOffAsync(
//             int doctorId,
//             CreateDayOffRequest request,
//             CancellationToken cancellationToken = default)
//        {
//            try
//            {
//                // 1. تحقق إن مفيش exception موجود
//                var existing = await _exceptionRepository
//                    .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

//                if (existing != null)
//                    throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

//                // 2. جيب كل الـ slots في اليوم ده
//                var slots = await _timeSlotRepository
//                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, cancellationToken);

//                // 3. الـ booked slots - لغّيها
//                var bookedSlots = slots.Where(s => s.Status == SlotStatus.Booked).ToList();
//                foreach (var slot in bookedSlots)
//                {
//                    var appointment = await _appointmentRepository
//                        .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

//                    if (appointment != null)
//                    {
//                        appointment.Cancel(
//                            CancelledBy.Doctor,
//                            reason: $"Doctor day off: {request.Reason ?? "No reason provided"}");
//                        appointment.ClearPatientData();
//                        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

//                        // لغّي الـ reminders
//                        await _appointmentReminderService.CancelAppointmentRemindersAsync(
//                            appointment.Id,
//                            appointment.PatientId,
//                            cancellationToken);
//                    }

//                    slot.MakeAvailable();
//                    slot.Block();
//                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//                }

//                // 4. الـ available slots - بلوكها
//                var availableSlots = slots.Where(s => s.Status == SlotStatus.Available).ToList();
//                foreach (var slot in availableSlots)
//                {
//                    slot.Block();
//                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//                }

//                // 5. احفظ الـ exception
//                var exception = ScheduleException.CreateDayOff(
//                    doctorId, request.Date, request.Reason);

//                await _exceptionRepository.AddAsync(exception, cancellationToken);
//                await _unitOfWork.SaveChangesAsync(cancellationToken);

//                _logger.LogInformation(
//                    "Day off added for doctor {DoctorId} on {Date}. Blocked {Total} slots, cancelled {Booked} appointments",
//                    doctorId, request.Date, slots.Count, bookedSlots.Count);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Error adding day off for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        //public async Task AddCustomHoursAsync(
//        //    int doctorId,
//        //    CreateCustomHoursRequest request,
//        //    CancellationToken cancellationToken = default)
//        //{
//        //    try
//        //    {
//        //        var existing = await _exceptionRepository
//        //            .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

//        //        if (existing != null)
//        //            throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

//        //        var exception = ScheduleException.CreateCustomHours(
//        //            doctorId,
//        //            request.Date,
//        //            request.StartTime,
//        //            request.EndTime,
//        //            request.Reason
//        //        );

//        //        await _exceptionRepository.AddAsync(exception, cancellationToken);
//        //        await _unitOfWork.SaveChangesAsync(cancellationToken);

//        //        _logger.LogInformation(
//        //            "Custom hours added for doctor {DoctorId} on {Date}",
//        //            doctorId, request.Date);
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
//        //        throw;
//        //    }
//        //}
//        public async Task AddCustomHoursAsync(
//            int doctorId,
//            CreateCustomHoursRequest request,
//            CancellationToken cancellationToken = default)
//        {
//            try
//            {
//                var existing = await _exceptionRepository
//                    .GetExceptionForDateAsync(doctorId, request.Date, cancellationToken);

//                if (existing != null)
//                    throw new DomainException($"An exception already exists for {request.Date:yyyy-MM-dd}");

//                // جيب كل الـ slots في اليوم ده
//                var slots = await _timeSlotRepository
//                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, cancellationToken);

//                // الـ slots اللي بره الوقت الجديد
//                var slotsOutsideNewHours = slots
//                    .Where(s => s.StartTime < request.StartTime || s.EndTime > request.EndTime)
//                    .ToList();

//                foreach (var slot in slotsOutsideNewHours)
//                {
//                    if (slot.Status == SlotStatus.Booked)
//                    {
//                        var appointment = await _appointmentRepository
//                            .GetByTimeSlotIdAsync(slot.Id, cancellationToken);

//                        if (appointment != null)
//                        {
//                            appointment.Cancel(
//                                CancelledBy.Doctor,
//                                reason: $"Doctor schedule changed: {request.Reason ?? "Custom hours applied"}");
//                            appointment.ClearPatientData();
//                            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

//                            await _appointmentReminderService.CancelAppointmentRemindersAsync(
//                                appointment.Id,
//                                appointment.PatientId,
//                                cancellationToken);
//                        }

//                        slot.MakeAvailable();
//                        slot.Block();
//                    }
//                    else
//                    {
//                        slot.Block();
//                    }

//                    await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
//                }

//                var exception = ScheduleException.CreateCustomHours(
//                    doctorId, request.Date, request.StartTime, request.EndTime, request.Reason);

//                await _exceptionRepository.AddAsync(exception, cancellationToken);
//                await _unitOfWork.SaveChangesAsync(cancellationToken);

//                _logger.LogInformation(
//                    "Custom hours added for doctor {DoctorId} on {Date}. Blocked {Count} slots outside new hours",
//                    doctorId, request.Date, slotsOutsideNewHours.Count);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex, "Error adding custom hours for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        public async Task RemoveExceptionAsync(
//            int doctorId,
//            DateTime date,
//            CancellationToken cancellationToken = default)
//        {
//            var exception = await _exceptionRepository
//                .GetExceptionForDateAsync(doctorId, date, cancellationToken);

//            if (exception == null)
//                throw new NotFoundException("ScheduleException", $"{doctorId}-{date:yyyy-MM-dd}");

//            await _exceptionRepository.DeleteAsync(exception, cancellationToken);
//            await _unitOfWork.SaveChangesAsync(cancellationToken);

//            _logger.LogInformation(
//                "Exception removed for doctor {DoctorId} on {Date}",
//                doctorId, date);
//        }
//    }
//}