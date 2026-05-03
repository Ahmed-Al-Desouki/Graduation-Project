//using Microsoft.EntityFrameworkCore;
//using Microsoft.Extensions.Logging;
//using System.Reflection.Metadata;
//using WelloraHealthCareManagement.Application.Interfaces;
//using WelloraHealthCareManagement.Domain.Entities;
//using WelloraHealthCareManagement.Domain.Enums;
//using WelloraHealthCareManagement.Domain.Exceptions;
//using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;
//using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
//using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;
//using WelloraHealthCareManagment.Application.Interfaces;
//using WelloraHealthCareManagment.Domain.Constants;
//using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
//using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
//using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

//namespace WelloraHealthCareManagement.Infrastructure.Services
//{
//    public class DoctorSlotConfigService : IDoctorSlotConfigService
//    {
//        private readonly IDoctorSlotConfigRepository _configRepository;
//        private readonly ITimeSlotRepository _timeSlotRepository;
//        private readonly IScheduleExceptionRepository _exceptionRepository;
//        private readonly IAppointmentRepository _appointmentRepository;
//        private readonly ISlotGenerationService _slotGenerationService;
//        private readonly IAppointmentReminderService _appointmentReminderService;
//        private readonly IUnitOfWork _unitOfWork;
//        private readonly ILogger<DoctorSlotConfigService> _logger;

//        private const int MAX_GENERATION_MONTHS = 3;

//        public DoctorSlotConfigService(
//            IDoctorSlotConfigRepository configRepository,
//            ITimeSlotRepository timeSlotRepository,
//            IScheduleExceptionRepository exceptionRepository,
//            IAppointmentRepository appointmentRepository,
//            ISlotGenerationService slotGenerationService,
//            IAppointmentReminderService appointmentReminderService,
//            IUnitOfWork unitOfWork,
//            ILogger<DoctorSlotConfigService> logger)
//        {
//            _configRepository = configRepository;
//            _timeSlotRepository = timeSlotRepository;
//            _exceptionRepository = exceptionRepository;
//            _appointmentRepository = appointmentRepository;
//            _slotGenerationService = slotGenerationService;
//            _appointmentReminderService = appointmentReminderService;
//            _unitOfWork = unitOfWork;
//            _logger = logger;
//        }

//        public async Task SetDayConfigAsync(
//            int doctorId,
//            SetDayConfigRequest request,
//            CancellationToken ct = default)
//        {
//            await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);

//            try
//            {
//                var existing = await _configRepository
//                    .GetByDoctorAndDayAsync(doctorId, request.DayOfWeek, ct);

//                bool isUpdate = existing != null;
//                bool settingsChanged = false;
//                bool wasInactive = false;

//                if (isUpdate)
//                {
//                    wasInactive = !existing!.IsActive;
//                    settingsChanged =
//                        existing.StartTime != request.StartTime ||
//                        existing.EndTime != request.EndTime ||
//                        existing.SlotDurationMinutes != request.SlotDurationMinutes ||
//                        existing.BufferTimeMinutes != request.BufferTimeMinutes;

//                    existing.Update(request.StartTime, request.EndTime,
//                        request.SlotDurationMinutes, request.BufferTimeMinutes);

//                    if (!existing.IsActive) existing.Activate();
//                    await _configRepository.UpdateAsync(existing, ct);
//                }
//                else
//                {
//                    var config = DoctorSlotConfig.Create(
//                        doctorId, request.DayOfWeek,
//                        request.StartTime, request.EndTime,
//                        request.SlotDurationMinutes, request.BufferTimeMinutes);

//                    await _configRepository.AddAsync(config, ct);
//                }

//                // save واحدة للـ config
//                await _unitOfWork.SaveChangesAsync(ct);

//                if (!isUpdate)
//                {
//                    // generate بعد الـ save عشان الـ config يكون موجود في الـ DB
//                    await GenerateSlotsInternalAsync(doctorId, request.DayOfWeek, ct);
//                }
//                else if (settingsChanged || wasInactive)
//                {
//                    //await _slotGenerationService.RegenerateForSingleDateAsync(doctorId, request.DayOfWeek, ct);
//                    await _slotGenerationService.GenerateAsync(
//                       doctorId,
//                       new GenerateSlotsByConfigRequest
//                       {
//                           StartDate = DateTime.UtcNow.Date,
//                           EndDate = DateTime.UtcNow.Date.AddMonths(3),
//                           RegenerateExisting = false,
//                           OnlyForDays = new List<DayOfWeek> { request.DayOfWeek },
//                           BatchSize = 1000
//                       },
//                       ct);
//                }

//                // save واحدة للـ slots
//                await _unitOfWork.SaveChangesAsync(ct);
//                await transaction.CommitAsync(ct);

//                _logger.LogInformation(
//                    "{Action} config for doctor {DoctorId} day {Day}",
//                    isUpdate ? "Updated" : "Created", doctorId, request.DayOfWeek);
//            }
//            catch (DbUpdateException ex)
//                when (ex.InnerException?.Message.Contains("UNIQUE") == true ||
//                      ex.InnerException?.Message.Contains("unique") == true)
//            {
//                await transaction.RollbackAsync(ct);
//                throw new DomainException(
//                    $"A config for {request.DayOfWeek} already exists for this doctor");
//            }
//            catch (Exception ex)
//            {
//                await transaction.RollbackAsync(ct);
//                _logger.LogError(ex,
//                    "Error setting day config for doctor {DoctorId} — rolled back", doctorId);
//                throw;
//            }
//        }

//        public async Task RemoveDayAsync(
//            int doctorId,
//            DayOfWeek day,
//            CancellationToken ct = default)
//        {
//            try
//            {
//                var config = await _configRepository
//                    .GetByDoctorAndDayAsync(doctorId, day, ct);

//                if (config == null)
//                    throw new DomainException($"No config found for {day}");

//                config.Deactivate();
//                await _configRepository.UpdateAsync(config, ct);

//                var fromDate = DateTime.UtcNow.Date;
//                var toDate = fromDate.AddMonths(3);

//                var slots = await _timeSlotRepository
//                    .GetSlotsForDaysInRangeAsync(
//                        doctorId, new List<DayOfWeek> { day }, fromDate, toDate, ct);

//                foreach (var slot in slots)
//                {
//                    if (slot.Status == SlotStatus.Booked)
//                    {
//                        await CancelAppointmentForSlotAsync(
//                            slot, "Doctor removed this day from their schedule", ct);
//                        slot.MakeAvailable();
//                    }

//                    if (slot.Status == SlotStatus.Available)
//                        slot.Block();

//                    await _timeSlotRepository.UpdateAsync(slot, ct);
//                }

//                await _unitOfWork.SaveChangesAsync(ct);

//                _logger.LogInformation(
//                    "Removed day {Day} for doctor {DoctorId}. Blocked {Count} slots",
//                    day, doctorId, slots.Count);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex,
//                    "Error removing day {Day} for doctor {DoctorId}", day, doctorId);
//                throw;
//            }
//        }

//        public async Task<List<DayConfigDto>> GetConfigsAsync(
//            int doctorId,
//            CancellationToken ct = default)
//        {
//            var configs = await _configRepository.GetAllConfigsAsync(doctorId, ct);

//            return configs.Select(c => new DayConfigDto
//            {
//                Id = c.Id,
//                DayOfWeek = c.DayOfWeek,
//                DayName = c.DayOfWeek.ToString(),
//                StartTime = c.StartTime,
//                EndTime = c.EndTime,
//                SlotDurationMinutes = c.SlotDurationMinutes,
//                BufferTimeMinutes = c.BufferTimeMinutes,
//                IsActive = c.IsActive,
//                EstimatedSlotsPerDay = c.EstimatedSlotsPerDay()
//            }).OrderBy(c => c.DayOfWeek).ToList();
//        }


//        // Slot Generation
//        //public async Task<GenerateSlotsResponse> GenerateSlotsAsync(
//        //    int doctorId,
//        //    GenerateSlotsByConfigRequest request,
//        //    CancellationToken ct = default)
//        //{
//        //    try
//        //    {
//        //        _logger.LogInformation(
//        //            "Generating slots for doctor {DoctorId} from {Start} to {End}",
//        //            doctorId, request.StartDate, request.EndDate);

//        //        // Clamp to max 3 months
//        //        var monthsDiff =
//        //            (request.EndDate.Year - request.StartDate.Year) * 12
//        //            + request.EndDate.Month - request.StartDate.Month;

//        //        if (monthsDiff > MAX_GENERATION_MONTHS)
//        //            request.EndDate = request.StartDate.AddMonths(MAX_GENERATION_MONTHS);

//        //        // 1. جيب الـ active configs
//        //        var configs = await _configRepository
//        //            .GetActiveConfigsAsync(doctorId, ct);

//        //        if (!configs.Any())
//        //            throw new DomainException(
//        //                "No active slot configs found for this doctor");

//        //        if (request.OnlyForDays?.Any() == true)
//        //            configs = configs
//        //                .Where(c => request.OnlyForDays.Contains(c.DayOfWeek))
//        //                .ToList();

//        //        // 2. جيب كل الـ exceptions في الفترة دي
//        //        var exceptions = await _exceptionRepository
//        //            .GetExceptionsForPeriodAsync(
//        //                doctorId, request.StartDate, request.EndDate, ct);

//        //        // index الـ exceptions بالتاريخ عشان lookup سريع
//        //        var exceptionByDate = exceptions
//        //            .GroupBy(e => e.ExceptionDate.Date)
//        //            .ToDictionary(g => g.Key, g => g.First());

//        //        var configByDay = configs.ToDictionary(c => c.DayOfWeek);
//        //        var now = DateTime.UtcNow;
//        //        var allSlots = new List<TimeSlot>();
//        //        var currentDate = request.StartDate.Date;

//        //        while (currentDate <= request.EndDate.Date)
//        //        {
//        //            if (configByDay.TryGetValue(currentDate.DayOfWeek, out var config))
//        //            {
//        //                exceptionByDate.TryGetValue(currentDate, out var exception);

//        //                // GetEffectiveSlotTimes تعالج DayOff و CustomHours تلقائياً
//        //                var slotTimes = config.GetEffectiveSlotTimes(exception);

//        //                foreach (var (start, end) in slotTimes)
//        //                {
//        //                    // تجاهل الأوقات الماضية
//        //                    if (currentDate < now.Date)
//        //                        break;

//        //                    if (currentDate == now.Date && start <= now.TimeOfDay)
//        //                        continue;

//        //                    allSlots.Add(
//        //                        TimeSlot.CreateFromConfig(doctorId, currentDate, start, end));
//        //                }
//        //            }

//        //            currentDate = currentDate.AddDays(1);
//        //        }

//        //        return await ProcessSlotsInBatchesAsync(
//        //            doctorId,
//        //            allSlots,
//        //            request.RegenerateExisting,
//        //            request.BatchSize <= 0 ? 1000 : request.BatchSize,
//        //            ct);
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        _logger.LogError(ex,
//        //            "Error generating slots for doctor {DoctorId}", doctorId);
//        //        throw;
//        //    }
//        //}

//        //private async Task<GenerateSlotsResponse> ProcessSlotsInBatchesAsync(
//        //    int doctorId,
//        //    List<TimeSlot> generatedSlots,
//        //    bool regenerateExisting,
//        //    int batchSize,
//        //    CancellationToken ct)
//        //{
//        //    int slotsAdded = 0, slotsSkipped = 0, batchesProcessed = 0;

//        //    if (!generatedSlots.Any())
//        //    {
//        //        _logger.LogWarning("No slots to generate for doctor {DoctorId}", doctorId);
//        //        return new GenerateSlotsResponse
//        //        {
//        //            SlotsGenerated = 0,
//        //            SlotsSkipped = 0,
//        //            GeneratedFrom = DateTime.UtcNow.Date,
//        //            GeneratedTo = DateTime.UtcNow.Date,
//        //            BatchesProcessed = 0,
//        //            ProcessingTime = TimeSpan.Zero
//        //        };
//        //    }

//        //    // لو regenerateExisting → امسح كل Available + Blocked الأول دفعة واحدة
//        //    if (regenerateExisting)
//        //    {
//        //        var allDates = generatedSlots
//        //            .Select(s => s.SlotDate.Date)
//        //            .Distinct()
//        //            .ToList();

//        //        var existingToDelete = await _timeSlotRepository
//        //            .GetSlotsForDatesAsync(doctorId, allDates, ct);

//        //        var toDelete = existingToDelete
//        //            .Where(s =>
//        //                s.Status == SlotStatus.Available ||
//        //                s.Status == SlotStatus.Blocked)
//        //            .ToList();

//        //        if (toDelete.Any())
//        //        {
//        //            await _timeSlotRepository.DeleteRangeAsync(toDelete, ct);
//        //            await _unitOfWork.SaveChangesAsync(ct);

//        //            _logger.LogInformation(
//        //                "Deleted {Count} old Available/Blocked slots before regeneration",
//        //                toDelete.Count);
//        //        }
//        //    }

//        //    var batches = generatedSlots
//        //        .Select((slot, i) => new { slot, i })
//        //        .GroupBy(x => x.i / (batchSize <= 0 ? 1000 : batchSize))
//        //        .Select(g => g.Select(x => x.slot).ToList())
//        //        .ToList();

//        //    foreach (var batch in batches)
//        //    {
//        //        try
//        //        {
//        //            var batchDates = batch.Select(s => s.SlotDate.Date).Distinct().ToList();

//        //            // جيب الـ Booked فقط للـ conflict check
//        //            var existingSlots = await _timeSlotRepository
//        //                .GetSlotsForDatesAsync(doctorId, batchDates, ct);

//        //            var bookedByDate = existingSlots
//        //                .Where(s => s.Status == SlotStatus.Booked)
//        //                .GroupBy(s => s.SlotDate.Date)
//        //                .ToDictionary(g => g.Key, g => g.ToList());

//        //            // لو مش regenerate → نشيك على الـ existing عادي
//        //            var existingDict = regenerateExisting
//        //                ? new Dictionary<object, TimeSlot>()
//        //                : existingSlots
//        //                    .GroupBy(s => new { Date = s.SlotDate.Date, s.StartTime } as object)
//        //                    .ToDictionary(g => g.Key, g => g.First());

//        //            foreach (var slot in batch)
//        //            {
//        //                if (!regenerateExisting)
//        //                {
//        //                    var key = new { Date = slot.SlotDate.Date, slot.StartTime } as object;
//        //                    if (existingDict.ContainsKey(key))
//        //                    {
//        //                        slotsSkipped++;
//        //                        continue;
//        //                    }
//        //                }

//        //                // conflict check ضد Booked بس
//        //                var booked = bookedByDate.TryGetValue(slot.SlotDate.Date, out var b)
//        //                    ? b : new List<TimeSlot>();

//        //                bool hasConflict = booked.Any(o =>
//        //                    slot.StartTime < o.EndTime && slot.EndTime > o.StartTime);

//        //                if (hasConflict)
//        //                {
//        //                    slotsSkipped++;
//        //                    _logger.LogDebug(
//        //                        "Skipped {Start}-{End} on {Date} — conflicts with Booked slot",
//        //                        slot.StartTime, slot.EndTime, slot.SlotDate);
//        //                }
//        //                else
//        //                {
//        //                    await _timeSlotRepository.AddAsync(slot, ct);
//        //                    slotsAdded++;
//        //                }
//        //            }

//        //            await _unitOfWork.SaveChangesAsync(ct);
//        //            batchesProcessed++;
//        //        }
//        //        catch (Exception ex)
//        //        {
//        //            _logger.LogError(ex, "Error in batch {Batch}", batchesProcessed + 1);
//        //            throw;
//        //        }
//        //    }

//        //    return new GenerateSlotsResponse
//        //    {
//        //        SlotsGenerated = slotsAdded,
//        //        SlotsSkipped = slotsSkipped,
//        //        GeneratedFrom = generatedSlots.Min(s => s.SlotDate),
//        //        GeneratedTo = generatedSlots.Max(s => s.SlotDate),
//        //        BatchesProcessed = batchesProcessed
//        //    };
//        //}

//        //private async Task RegenerateSlotsForDayAsync(
//        //     int doctorId,
//        //     DayOfWeek day,
//        //     CancellationToken ct)
//        //{
//        //    var fromDate = DateTime.UtcNow.Date;
//        //    var toDate = fromDate.AddMonths(2);

//        //    var allSlots = await _timeSlotRepository
//        //        .GetSlotsForDaysInRangeAsync(doctorId, new List<DayOfWeek> { day },
//        //            fromDate, toDate, ct);

//        //    var slotsToDelete = allSlots
//        //        .Where(s => s.Status == SlotStatus.Available || s.Status == SlotStatus.Blocked)
//        //        .ToList();

//        //    var occupiedByDate = allSlots
//        //        .Where(s => s.Status == SlotStatus.Booked)
//        //        .GroupBy(s => s.SlotDate.Date)
//        //        .ToDictionary(g => g.Key, g => g.ToList());

//        //    if (slotsToDelete.Any())
//        //        await _timeSlotRepository.DeleteRangeAsync(slotsToDelete, ct);

//        //    var config = await _configRepository.GetByDoctorAndDayAsync(doctorId, day, ct);
//        //    if (config == null || !config.IsActive) return;

//        //    var exceptions = await _exceptionRepository
//        //        .GetExceptionsForPeriodAsync(doctorId, fromDate, toDate, ct);

//        //    var exceptionByDate = exceptions
//        //        .Where(e => e.ExceptionDate.DayOfWeek == day)
//        //        .GroupBy(e => e.ExceptionDate.Date)
//        //        .ToDictionary(g => g.Key, g => g.First());

//        //    var now = DateTime.UtcNow;
//        //    var slotsToAdd = new List<TimeSlot>();
//        //    var currentDate = fromDate;

//        //    while (currentDate <= toDate)
//        //    {
//        //        if (currentDate.DayOfWeek == day)
//        //        {
//        //            exceptionByDate.TryGetValue(currentDate, out var exception);
//        //            var slotTimes = config.GetEffectiveSlotTimes(exception);
//        //            var occupied = occupiedByDate.GetValueOrDefault(currentDate, new());

//        //            foreach (var (start, end) in slotTimes)
//        //            {
//        //                if (currentDate == now.Date && start <= now.TimeOfDay) continue;

//        //                bool hasConflict = occupied.Any(o =>
//        //                    start < o.EndTime && end > o.StartTime);

//        //                if (!hasConflict)
//        //                    slotsToAdd.Add(TimeSlot.CreateFromConfig(
//        //                        doctorId, currentDate, start, end));
//        //            }
//        //        }
//        //        currentDate = currentDate.AddDays(1);
//        //    }

//        //    // AddRange على الـ tracker بس — مش SaveChangesAsync
//        //    if (slotsToAdd.Any())
//        //        await _timeSlotRepository.AddRangeAsync(slotsToAdd, ct);

//        //    _logger.LogInformation(
//        //        "Staged {Count} slots for regeneration — doctor {DoctorId} day {Day}",
//        //        slotsToAdd.Count, doctorId, day);
//        //}

//        /// يُستخدم لما يُحذف Exception — يعيد توليد لتاريخ واحد بعينه
//        //private async Task RegenerateSlotsForSingleDateAsync(
//        //    int doctorId,
//        //    DateTime date,
//        //    CancellationToken ct)
//        //{
//        //    var config = await _configRepository
//        //        .GetByDoctorAndDayAsync(doctorId, date.DayOfWeek, ct);

//        //    if (config == null || !config.IsActive)
//        //    {
//        //        _logger.LogInformation(
//        //            "No active config for {Day} — skipping regeneration",
//        //            date.DayOfWeek);
//        //        return;
//        //    }

//        //    // جيب كل slots اليوم ده
//        //    var allSlots = await _timeSlotRepository
//        //        .GetSlotsForDaysInRangeAsync(
//        //            doctorId, new List<DayOfWeek> { date.DayOfWeek },
//        //            date.Date, date.Date, ct);

//        //    // امسح الـ Blocked فقط (اللي اتبلكت بسبب الـ exception)
//        //    // الـ Available (لو في) اتعملت قبل الـ exception وكانت خارج الـ interval
//        //    var slotsToDelete = allSlots
//        //        .Where(s =>
//        //            s.Status == SlotStatus.Blocked ||
//        //            s.Status == SlotStatus.Available)
//        //        .ToList();

//        //    var occupiedSlots = allSlots
//        //        .Where(s => s.Status == SlotStatus.Booked)
//        //        .ToList();

//        //    if (slotsToDelete.Any())
//        //    {
//        //        await _timeSlotRepository.DeleteRangeAsync(slotsToDelete, ct);
//        //        await _unitOfWork.SaveChangesAsync(ct);
//        //    }

//        //    // ولّد الـ slots الجديدة بالـ config الكامل (مفيش exception دلوقتي)
//        //    var slotTimes = config.GetEffectiveSlotTimes(null);
//        //    var now = DateTime.UtcNow;
//        //    var slotsToAdd = new List<TimeSlot>();

//        //    foreach (var (start, end) in slotTimes)
//        //    {
//        //        if (date.Date == now.Date && start <= now.TimeOfDay)
//        //            continue;

//        //        bool hasConflict = occupiedSlots.Any(o =>
//        //            start < o.EndTime && end > o.StartTime);

//        //        if (!hasConflict)
//        //            slotsToAdd.Add(
//        //                TimeSlot.CreateFromConfig(doctorId, date, start, end));
//        //    }

//        //    if (slotsToAdd.Any())
//        //    {
//        //        await _timeSlotRepository.AddRangeAsync(slotsToAdd, ct);
//        //        await _unitOfWork.SaveChangesAsync(ct);
//        //    }

//        //    _logger.LogInformation(
//        //        "Regenerated {Count} slots for doctor {DoctorId} on {Date}",
//        //        slotsToAdd.Count, doctorId, date.Date);
//        //}


//        // Exceptions
//        public async Task AddDayOffAsync(
//            int doctorId,
//            CreateDayOffRequest request,
//            CancellationToken ct = default)
//        {
//            try
//            {
//                var existing = await _exceptionRepository
//                    .GetExceptionForDateAsync(doctorId, request.Date, ct);

//                if (existing != null)
//                    throw new DomainException(
//                        $"An exception already exists for {request.Date:yyyy-MM-dd}");

//                var slots = await _timeSlotRepository
//                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, ct);

//                foreach (var slot in slots)
//                {
//                    if (slot.Status == SlotStatus.Booked)
//                    {
//                        await CancelAppointmentForSlotAsync(
//                            slot,
//                            $"Doctor day off: {request.Reason ?? "No reason provided"}",
//                            ct);
//                        slot.MakeAvailable();
//                    }

//                    slot.Block();
//                    await _timeSlotRepository.UpdateAsync(slot, ct);
//                }

//                await _exceptionRepository.AddAsync(
//                    ScheduleException.CreateDayOff(doctorId, request.Date, request.Reason),
//                    ct);

//                await _unitOfWork.SaveChangesAsync(ct);

//                _logger.LogInformation(
//                    "Day off added for doctor {DoctorId} on {Date}. Blocked {Count} slots",
//                    doctorId, request.Date, slots.Count);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex,
//                    "Error adding day off for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        public async Task AddCustomHoursAsync(
//            int doctorId,
//            CreateCustomHoursRequest request,
//            CancellationToken ct = default)
//        {
//            try
//            {
//                var existing = await _exceptionRepository
//                    .GetExceptionForDateAsync(doctorId, request.Date, ct);

//                if (existing != null)
//                    throw new DomainException(
//                        $"An exception already exists for {request.Date:yyyy-MM-dd}");

//                var slots = await _timeSlotRepository
//                    .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, ct);

//                var slotsOutside = slots
//                    .Where(s =>
//                        s.StartTime < request.StartTime ||
//                        s.EndTime > request.EndTime)
//                    .ToList();

//                foreach (var slot in slotsOutside)
//                {
//                    if (slot.Status == SlotStatus.Booked)
//                    {
//                        await CancelAppointmentForSlotAsync(
//                            slot,
//                            $"Doctor schedule changed: {request.Reason ?? "Custom hours applied"}",
//                            ct);
//                        slot.MakeAvailable();
//                    }

//                    slot.Block();
//                    await _timeSlotRepository.UpdateAsync(slot, ct);
//                }

//                await _exceptionRepository.AddAsync(
//                    ScheduleException.CreateCustomHours(
//                        doctorId, request.Date,
//                        request.StartTime, request.EndTime, request.Reason),
//                    ct);

//                await _unitOfWork.SaveChangesAsync(ct);

//                _logger.LogInformation(
//                    "Custom hours added for doctor {DoctorId} on {Date}. Blocked {Count} slots",
//                    doctorId, request.Date, slotsOutside.Count);
//            }
//            catch (Exception ex)
//            {
//                _logger.LogError(ex,
//                    "Error adding custom hours for doctor {DoctorId}", doctorId);
//                throw;
//            }
//        }

//        //public async Task RemoveExceptionAsync(
//        //    int doctorId,
//        //    DateTime date,
//        //    CancellationToken ct = default)
//        //{
//        //    try
//        //    {
//        //        var exception = await _exceptionRepository
//        //            .GetExceptionForDateAsync(doctorId, date, ct);

//        //        if (exception == null)
//        //            throw new NotFoundException(
//        //                "ScheduleException", $"{doctorId}-{date:yyyy-MM-dd}");

//        //        await _exceptionRepository.DeleteAsync(exception, ct);
//        //        await _unitOfWork.SaveChangesAsync(ct);

//        //        // لو التاريخ في المستقبل → أعد التوليد
//        //        if (date.Date >= DateTime.UtcNow.Date)
//        //            await _slotGenerationService.RegenerateForSingleDateAsync(doctorId, date, ct);

//        //        _logger.LogInformation(
//        //            "Exception removed for doctor {DoctorId} on {Date}",
//        //            doctorId, date);
//        //    }
//        //    catch (Exception ex)
//        //    {
//        //        _logger.LogError(ex,
//        //            "Error removing exception for doctor {DoctorId}", doctorId);
//        //        throw;
//        //    }
//        //}


//        // Shared Helper

//        public async Task RemoveExceptionAsync(
//    int doctorId,
//    DateTime date,
//    CancellationToken ct = default)
//        {
//            await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
//            try
//            {
//                var exception = await _exceptionRepository
//                    .GetExceptionForDateAsync(doctorId, date, ct);

//                if (exception == null)
//                    throw new NotFoundException(
//                        "ScheduleException", $"{doctorId}-{date:yyyy-MM-dd}");

//                await _exceptionRepository.DeleteAsync(exception, ct);
//                await _unitOfWork.SaveChangesAsync(ct);

//                // ✅ regenerate فقط لو التاريخ النهارده أو في المستقبل
//                // مش منطقي نعمل regenerate لتاريخ فات منه أكتر من يوم
//                bool shouldRegenerate = date.Date >=
//                    DateTime.UtcNow.Date
//                        .AddDays(SlotSystemConstants.MaxPastDaysForRegeneration);

//                if (shouldRegenerate)
//                {
//                    await _slotGenerationService.RegenerateForSingleDateAsync(doctorId, date, ct);
//                    await _unitOfWork.SaveChangesAsync(ct);
//                }

//                await transaction.CommitAsync(ct);

//                _logger.LogInformation(
//                    "Exception removed for doctor {DoctorId} on {Date}. Regenerated: {Regen}",
//                    doctorId, date, shouldRegenerate);
//            }
//            catch (Exception ex)
//            {
//                await transaction.RollbackAsync(ct);
//                _logger.LogError(ex,
//                    "Error removing exception for doctor {DoctorId} — rolled back", doctorId);
//                throw;
//            }
//        }
//        private async Task GenerateSlotsInternalAsync(
//            int doctorId,
//            DayOfWeek day,
//            CancellationToken ct)
//        {
//            var startDate = DateTime.UtcNow.Date;
//            var endDate = startDate.AddMonths(3);

//            var config = await _configRepository.GetByDoctorAndDayAsync(doctorId, day, ct);
//            if (config == null) return;

//            var exceptions = await _exceptionRepository
//                .GetExceptionsForPeriodAsync(doctorId, startDate, endDate, ct);

//            var exceptionByDate = exceptions
//                .GroupBy(e => e.ExceptionDate.Date)
//                .ToDictionary(g => g.Key, g => g.First());

//            var now = DateTime.UtcNow;
//            var slotsToAdd = new List<TimeSlot>();
//            var currentDate = startDate;

//            while (currentDate <= endDate)
//            {
//                if (currentDate.DayOfWeek == day)
//                {
//                    exceptionByDate.TryGetValue(currentDate, out var exception);
//                    var slotTimes = config.GetEffectiveSlotTimes(exception);

//                    foreach (var (start, end) in slotTimes)
//                    {
//                        if (currentDate == now.Date && start <= now.TimeOfDay) continue;
//                        slotsToAdd.Add(TimeSlot.CreateFromConfig(
//                            doctorId, currentDate, start, end));
//                    }
//                }
//                currentDate = currentDate.AddDays(1);
//            }

//            if (slotsToAdd.Any())
//                await _timeSlotRepository.AddRangeAsync(slotsToAdd, ct);
//        }

//        private async Task CancelAppointmentForSlotAsync(
//            TimeSlot slot,
//            string reason,
//            CancellationToken ct)
//        {
//            var appointment = await _appointmentRepository
//                .GetByTimeSlotIdAsync(slot.Id, ct);

//            if (appointment == null) return;

//            appointment.Cancel(CancelledBy.Doctor, reason);
//            appointment.ClearPatientData();
//            await _appointmentRepository.UpdateAsync(appointment, ct);
//            await _appointmentReminderService.CancelAppointmentRemindersAsync(
//                appointment.Id, appointment.PatientId, ct);
//        }
//    }
//}
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Constants;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

public class DoctorSlotConfigService : IDoctorSlotConfigService
{
    private readonly IDoctorSlotConfigRepository _configRepository;
    private readonly ITimeSlotRepository _timeSlotRepository;
    private readonly IScheduleExceptionRepository _exceptionRepository;
    private readonly IAppointmentRepository _appointmentRepository;
    private readonly IAppointmentReminderService _appointmentReminderService;
    private readonly ISlotGenerationService _generationService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly INotificationService _notificationService;
    private readonly IRealtimeService _realtimeService;
    private readonly ILogger<DoctorSlotConfigService> _logger;

    public DoctorSlotConfigService(
        IDoctorSlotConfigRepository configRepository,
        ITimeSlotRepository timeSlotRepository,
        IScheduleExceptionRepository exceptionRepository,
        IAppointmentRepository appointmentRepository,
        IAppointmentReminderService appointmentReminderService,
        ISlotGenerationService generationService,
        IUnitOfWork unitOfWork,
        INotificationService notificationService,
        IRealtimeService realtimeService,
        ILogger<DoctorSlotConfigService> logger)
    {
        _configRepository = configRepository;
        _timeSlotRepository = timeSlotRepository;
        _exceptionRepository = exceptionRepository;
        _appointmentRepository = appointmentRepository;
        _appointmentReminderService = appointmentReminderService;
        _generationService = generationService;
        _unitOfWork = unitOfWork;
        _notificationService = notificationService;
        _realtimeService = realtimeService;
        _logger = logger;
    }

    public async Task SetDayConfigAsync(
        int doctorId,
        SetDayConfigRequest request,
        CancellationToken ct = default)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
        try
        {
            var existing = await _configRepository
                .GetByDoctorAndDayAsync(doctorId, request.DayOfWeek, ct);

            bool isUpdate = existing != null;
            bool settingsChanged = false;
            bool wasInactive = false;

            if (isUpdate)
            {
                wasInactive = !existing!.IsActive;
                settingsChanged =
                    existing.StartTime != request.StartTime ||
                    existing.EndTime != request.EndTime ||
                    existing.SlotDurationMinutes != request.SlotDurationMinutes ||
                    existing.BufferTimeMinutes != request.BufferTimeMinutes;

                existing.Update(request.StartTime, request.EndTime,
                    request.SlotDurationMinutes, request.BufferTimeMinutes);

                if (!existing.IsActive) existing.Activate();
                await _configRepository.UpdateAsync(existing, ct);
                await _unitOfWork.SaveChangesAsync(ct);

                if (settingsChanged || wasInactive)
                    await _generationService.RegenerateForDayAsync(
                        doctorId, request.DayOfWeek, ct);
            }
            else
            {
                var config = DoctorSlotConfig.Create(
                    doctorId, request.DayOfWeek,
                    request.StartTime, request.EndTime,
                    request.SlotDurationMinutes, request.BufferTimeMinutes);

                await _configRepository.AddAsync(config, ct);
                await _unitOfWork.SaveChangesAsync(ct);

                await _generationService.GenerateAsync(
                    doctorId,
                    new GenerateSlotsByConfigRequest
                    {
                        StartDate = DateTime.UtcNow.Date,
                        EndDate = DateTime.UtcNow.Date
                            .AddMonths(SlotSystemConstants.MaxGenerationMonths),
                        RegenerateExisting = false,
                        OnlyForDays = new List<DayOfWeek> { request.DayOfWeek },
                        BatchSize = SlotSystemConstants.DefaultBatchSize
                    }, ct);
            }

            await transaction.CommitAsync(ct);
            await BroadcastScheduleUpdatedAsync(
                doctorId,
                isUpdate ? "DayConfigUpdated" : "DayConfigCreated",
                request.DayOfWeek.ToString(),
                null,
                null,
                ct);

            _logger.LogInformation(
                "{Action} config for doctor {DoctorId} day {Day}",
                isUpdate ? "Updated" : "Created", doctorId, request.DayOfWeek);
        }
        catch (DbUpdateException ex)
            when (ex.InnerException?.Message.Contains("UNIQUE") == true ||
                  ex.InnerException?.Message.Contains("unique") == true)
        {
            await transaction.RollbackAsync(ct);
            throw new DomainException(
                $"A config for {request.DayOfWeek} already exists for this doctor");
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(ct);
            _logger.LogError(ex,
                "Error setting day config for doctor {DoctorId} — rolled back",
                doctorId);
            throw;
        }
    }

    public async Task RemoveDayAsync(
        int doctorId,
        DayOfWeek day,
        CancellationToken ct = default)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
        try
        {
            var config = await _configRepository
                .GetByDoctorAndDayAsync(doctorId, day, ct);

            if (config == null)
                throw new DomainException($"No config found for {day}");

            config.Deactivate();
            await _configRepository.UpdateAsync(config, ct);

            var fromDate = DateTime.UtcNow.Date;
            var toDate = fromDate.AddMonths(SlotSystemConstants.MaxGenerationMonths);

            var slots = await _timeSlotRepository
                .GetSlotsForDaysInRangeAsync(
                    doctorId, new List<DayOfWeek> { day }, fromDate, toDate, ct);

            var transientSlotsToDelete = slots
                .Where(slot =>
                    slot.Status == SlotStatus.Available ||
                    slot.Status == SlotStatus.Blocked)
                .ToList();

            if (transientSlotsToDelete.Any())
                await _timeSlotRepository.DeleteRangeAsync(transientSlotsToDelete, ct);

            await _unitOfWork.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            await BroadcastScheduleUpdatedAsync(
                doctorId,
                "DayRemoved",
                day.ToString(),
                null,
                "Doctor removed this day from their schedule. Future transient slots were deleted.",
                ct);

            _logger.LogInformation(
                "Removed day {Day} for doctor {DoctorId}. Deleted {DeletedCount} transient slots and preserved {PreservedCount} booked/completed/history slots",
                day,
                doctorId,
                transientSlotsToDelete.Count,
                slots.Count - transientSlotsToDelete.Count);
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(ct);
            _logger.LogError(ex, "Error removing day {Day} — rolled back", day);
            throw;
        }
    }

    public async Task<List<DayConfigDto>> GetConfigsAsync(
        int doctorId,
        CancellationToken ct = default)
    {
        var configs = await _configRepository.GetAllConfigsAsync(doctorId, ct);

        return configs
            .Select(c => new DayConfigDto
            {
                Id = c.Id,
                DayOfWeek = c.DayOfWeek,
                DayName = c.DayOfWeek.ToString(),
                StartTime = c.StartTime,
                EndTime = c.EndTime,
                SlotDurationMinutes = c.SlotDurationMinutes,
                BufferTimeMinutes = c.BufferTimeMinutes,
                IsActive = c.IsActive,
                EstimatedSlotsPerDay = c.EstimatedSlotsPerDay()
            })
            .OrderBy(c => c.DayOfWeek)
            .ToList();
    }

    public async Task AddDayOffAsync(
     int doctorId,
     CreateDayOffRequest request,
     CancellationToken ct = default)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
        try
        {
            var existing = await _exceptionRepository
                .GetExceptionForDateAsync(doctorId, request.Date, ct);

            if (existing != null)
                throw new DomainException(
                    $"An exception already exists for {request.Date:yyyy-MM-dd}");

            var slots = await _timeSlotRepository
                .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, ct);

            // ✅ query واحدة
            await CancelAppointmentsForSlotsAsync(
                slots,
                $"Doctor day off: {request.Reason ?? "No reason provided"}",
                ct);

            foreach (var slot in slots)
            {
                if (slot.Status == SlotStatus.Booked)
                    slot.MakeAvailable();

                slot.Block();
                await _timeSlotRepository.UpdateAsync(slot, ct);
            }

            await _exceptionRepository.AddAsync(
                ScheduleException.CreateDayOff(doctorId, request.Date, request.Reason),
                ct);

            await _unitOfWork.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            await BroadcastScheduleUpdatedAsync(
                doctorId,
                "DayOffAdded",
                request.Date.DayOfWeek.ToString(),
                request.Date,
                request.Reason,
                ct);

            _logger.LogInformation(
                "Day off added for doctor {DoctorId} on {Date}. Blocked {Count} slots",
                doctorId, request.Date, slots.Count);
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(ct);
            _logger.LogError(ex,
                "Error adding day off for doctor {DoctorId} — rolled back", doctorId);
            throw;
        }
    }

    public async Task AddCustomHoursAsync(
     int doctorId,
     CreateCustomHoursRequest request,
     CancellationToken ct = default)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
        try
        {
            var existing = await _exceptionRepository
                .GetExceptionForDateAsync(doctorId, request.Date, ct);

            if (existing != null)
                throw new DomainException(
                    $"An exception already exists for {request.Date:yyyy-MM-dd}");

            var slots = await _timeSlotRepository
                .GetAvailableAndBookedSlotsForDateAsync(doctorId, request.Date, ct);

            var slotsOutside = slots
                .Where(s =>
                    s.StartTime < request.StartTime ||
                    s.EndTime > request.EndTime)
                .ToList();

            // ✅ query واحدة
            await CancelAppointmentsForSlotsAsync(
                slotsOutside,
                $"Doctor schedule changed: {request.Reason ?? "Custom hours applied"}",
                ct);

            foreach (var slot in slotsOutside)
            {
                if (slot.Status == SlotStatus.Booked)
                    slot.MakeAvailable();

                slot.Block();
                await _timeSlotRepository.UpdateAsync(slot, ct);
            }

            await _exceptionRepository.AddAsync(
                ScheduleException.CreateCustomHours(
                    doctorId, request.Date,
                    request.StartTime, request.EndTime, request.Reason),
                ct);

            await _unitOfWork.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            await BroadcastScheduleUpdatedAsync(
                doctorId,
                "CustomHoursAdded",
                request.Date.DayOfWeek.ToString(),
                request.Date,
                request.Reason,
                ct);

            _logger.LogInformation(
                "Custom hours added for doctor {DoctorId} on {Date}. Blocked {Count} slots",
                doctorId, request.Date, slotsOutside.Count);
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(ct);
            _logger.LogError(ex,
                "Error adding custom hours for doctor {DoctorId} — rolled back", doctorId);
            throw;
        }
    }

    public async Task RemoveExceptionAsync(
        int doctorId,
        DateTime date,
        CancellationToken ct = default)
    {
        await using var transaction = await _unitOfWork.BeginTransactionAsync(ct);
        try
        {
            var exception = await _exceptionRepository
                .GetExceptionForDateAsync(doctorId, date, ct);

            if (exception == null)
                throw new NotFoundException(
                    "ScheduleException", $"{doctorId}-{date:yyyy-MM-dd}");

            await _exceptionRepository.DeleteAsync(exception, ct);
            await _unitOfWork.SaveChangesAsync(ct);

            bool shouldRegenerate = date.Date >=
                DateTime.UtcNow.Date
                    .AddDays(-SlotSystemConstants.MaxPastDaysForRegeneration);

            if (shouldRegenerate)
                await _generationService.RegenerateForSingleDateAsync(
                    doctorId, date, ct);

            await _unitOfWork.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            await BroadcastScheduleUpdatedAsync(
                doctorId,
                "ExceptionRemoved",
                date.DayOfWeek.ToString(),
                date,
                null,
                ct);

            _logger.LogInformation(
                "Exception removed for doctor {DoctorId} on {Date}. Regenerated: {Regen}",
                doctorId, date, shouldRegenerate);
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(ct);
            _logger.LogError(ex,
                "Error removing exception for doctor {DoctorId} — rolled back", doctorId);
            throw;
        }
    }


    // Shared Helper


    private async Task CancelAppointmentsForSlotsAsync(
        IEnumerable<TimeSlot> slots,
        string reason,
        CancellationToken ct)
    {
        var bookedSlots = slots
            .Where(s => s.Status == SlotStatus.Booked)
            .ToList();

        if (!bookedSlots.Any()) return;

        var slotIds = bookedSlots.Select(s => s.Id).ToList();

        // ✅ query واحدة بدل N queries
        var appointments = await _appointmentRepository
            .GetByTimeSlotIdsAsync(slotIds, ct);

        var appointmentBySlotId = appointments
            .ToDictionary(a => a.TimeSlotId);

        foreach (var slot in bookedSlots)
        {
            if (!appointmentBySlotId.TryGetValue(slot.Id, out var appointment))
                continue;

            var patientId = appointment.PatientId;
            var doctorId = appointment.DoctorId;

            appointment.Cancel(CancelledBy.Doctor, reason);
            appointment.ClearPatientData();
            await _appointmentRepository.UpdateAsync(appointment, ct);
            await _appointmentReminderService.CancelAppointmentRemindersAsync(
                appointment.Id, patientId, ct);

            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = patientId,
                Title = "Appointment Cancelled",
                Message =
                    $"Your appointment on {WelloraHealthCareManagment.Infrastructure.Services.Notifications.NotificationMessageFormatter.FormatAppointmentDateTime(slot.SlotDate, slot.StartTime)} " +
                    $"was cancelled because the doctor's schedule changed. " +
                    $"{WelloraHealthCareManagment.Infrastructure.Services.Notifications.NotificationMessageFormatter.FormatReason(reason)}",
                Type = NotificationType.AppointmentCancelledByDoctor,
                RelatedEntityType = "Appointment",
                Data = new Dictionary<string, string>
                {
                    ["appointmentId"] = appointment.Id.ToString(),
                    ["doctorId"] = doctorId.ToString(),
                    ["patientId"] = patientId.ToString(),
                    ["reason"] = reason
                }
            }, ct);

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { patientId, doctorId },
                "appointment",
                appointment.Id.ToString("D"),
                "AppointmentCancelled",
                new AppointmentRealtimeDto
                {
                    AppointmentId = appointment.Id,
                    TimeSlotId = appointment.TimeSlotId,
                    DoctorId = doctorId,
                    PatientId = patientId,
                    Status = appointment.Status,
                    IsPaid = appointment.IsPaid,
                    CancellationReason = appointment.CancellationReason,
                    BookedAt = appointment.BookedAt,
                    ConfirmedAt = appointment.ConfirmedAt,
                    StartedAt = appointment.StartedAt,
                    CompletedAt = appointment.CompletedAt,
                    CancelledAt = appointment.CancelledAt
                },
                ct);
        }
    }

    private Task BroadcastScheduleUpdatedAsync(
        int doctorId,
        string changeType,
        string? dayOfWeek,
        DateTime? date,
        string? reason,
        CancellationToken ct)
    {
        return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
            new[] { doctorId },
            "schedule",
            doctorId.ToString(),
            "ScheduleUpdated",
            new ScheduleRealtimeDto
            {
                DoctorId = doctorId,
                ChangeType = changeType,
                DayOfWeek = dayOfWeek,
                Date = date,
                Reason = reason,
                OccurredAt = DateTime.UtcNow
            },
            ct);
    }
}
