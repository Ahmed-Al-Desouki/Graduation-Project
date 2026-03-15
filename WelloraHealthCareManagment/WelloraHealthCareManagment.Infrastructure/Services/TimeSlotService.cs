using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System.Diagnostics;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class TimeSlotService : ITimeSlotService
    {
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IDoctorScheduleRepository _scheduleRepository;
        private readonly IScheduleExceptionRepository _exceptionRepository;
        private readonly ITimeSlotGeneratorFactory _slotGeneratorFactory;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<TimeSlotService> _logger;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public TimeSlotService(
            ITimeSlotRepository timeSlotRepository,
            IDoctorScheduleRepository scheduleRepository,
            IScheduleExceptionRepository exceptionRepository,
            ITimeSlotGeneratorFactory slotGeneratorFactory,
            IUnitOfWork unitOfWork,
            ILogger<TimeSlotService> logger,
            IHttpContextAccessor httpContextAccessor)
        {
            _timeSlotRepository = timeSlotRepository;
            _scheduleRepository = scheduleRepository;
            _exceptionRepository = exceptionRepository;
            _slotGeneratorFactory = slotGeneratorFactory;
            _unitOfWork = unitOfWork;
            _logger = logger;
            _httpContextAccessor = httpContextAccessor;
        }

        private const int MAX_GENERATION_MONTHS = 3;
        private const int DEFAULT_BATCH_SIZE = 1000;
        private const int ROLLING_WINDOW_MONTHS = 2; 
        //public async Task<GenerateSlotsResponse> GenerateSlotsAsync(
        //    int doctorId,
        //    GenerateSlotsRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        _logger.LogInformation(
        //            "Generating slots for doctor {DoctorId} from {StartDate} to {EndDate}",
        //            doctorId, request.StartDate, request.EndDate);

        //        // 1. Get active template
        //        var template = await _scheduleRepository
        //            .GetActiveTemplateAsync(doctorId, cancellationToken);

        //        if (template == null)
        //            throw new DomainException("No active schedule template found for this doctor");

        //        // 2. Get exceptions
        //        var exceptions = await _exceptionRepository
        //            .GetExceptionsForPeriodAsync(
        //                doctorId,
        //                request.StartDate,
        //                request.EndDate,
        //                cancellationToken);

        //        // 3. Generate slots using Factory
        //        var generatedSlots = _slotGeneratorFactory.GenerateSlotsForPeriod(
        //            template,
        //            request.StartDate,
        //            request.EndDate,
        //            exceptions
        //        );

        //        int slotsAdded = 0;
        //        int slotsSkipped = 0;

        //        // 4. Filter existing slots (مهم للمرونة!)
        //        foreach (var slot in generatedSlots)
        //        {
        //            // Check if slot already exists
        //            var exists = await _timeSlotRepository.ExistsAsync(
        //                slot.DoctorId,
        //                slot.SlotDate,
        //                slot.StartTime,
        //                cancellationToken);

        //            if (exists)
        //            {
        //                if (request.RegenerateExisting)
        //                {
        //                    // حذف القديم وإضافة الجديد
        //                    var existingSlots = await _timeSlotRepository
        //                        .GetExistingSlotsForDateAsync(slot.DoctorId, slot.SlotDate, cancellationToken);

        //                    var slotToDelete = existingSlots.FirstOrDefault(s =>
        //                        s.StartTime == slot.StartTime && s.Status == SlotStatus.Available);

        //                    if (slotToDelete != null)
        //                    {
        //                        await _timeSlotRepository.DeleteAsync(slotToDelete, cancellationToken);
        //                        await _timeSlotRepository.AddAsync(slot, cancellationToken);
        //                        slotsAdded++;
        //                    }
        //                    else
        //                    {
        //                        slotsSkipped++; // محجوز - لا يمكن حذفه
        //                    }
        //                }
        //                else
        //                {
        //                    slotsSkipped++;
        //                }
        //            }
        //            else
        //            {
        //                await _timeSlotRepository.AddAsync(slot, cancellationToken);
        //                slotsAdded++;
        //            }
        //        }

        //        await _unitOfWork.SaveChangesAsync(cancellationToken);

        //        _logger.LogInformation(
        //            "Generated {SlotsAdded} slots, skipped {SlotsSkipped} for doctor {DoctorId}",
        //            slotsAdded, slotsSkipped, doctorId);

        //        return new GenerateSlotsResponse
        //        {
        //            SlotsGenerated = slotsAdded,
        //            SlotsSkipped = slotsSkipped,
        //            GeneratedFrom = request.StartDate,
        //            GeneratedTo = request.EndDate
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error generating slots for doctor {DoctorId}", doctorId);
        //        throw;
        //    }
        //}

        public async Task<GenerateSlotsResponse> GenerateSlotsAsync(
            int doctorId,
            GenerateSlotsRequest request,
            CancellationToken cancellationToken = default)
        {
            var stopwatch = Stopwatch.StartNew();

            try
            {
                _logger.LogInformation(
                    "Generating slots for doctor {DoctorId} from {StartDate} to {EndDate}",
                    doctorId, request.StartDate, request.EndDate);

                // 1. Validation: حد أقصى 3 شهور
                var monthsDiff = (request.EndDate.Year - request.StartDate.Year) * 12
                    + request.EndDate.Month - request.StartDate.Month;

                if (monthsDiff > MAX_GENERATION_MONTHS)
                {
                    _logger.LogWarning(
                        "Generation period too long ({Months} months). Limiting to {Max} months",
                        monthsDiff, MAX_GENERATION_MONTHS);

                    request.EndDate = request.StartDate.AddMonths(MAX_GENERATION_MONTHS);
                }

                // 2. Get active template
                var template = await _scheduleRepository
                    .GetActiveTemplateAsync(doctorId, cancellationToken);

                if (template == null)
                    throw new DomainException("No active schedule template found");

                // 3. Get exceptions
                var exceptions = await _exceptionRepository
                    .GetExceptionsForPeriodAsync(
                        doctorId,
                        request.StartDate,
                        request.EndDate,
                        cancellationToken);

                // 4. Generate slots
                var generatedSlots = _slotGeneratorFactory.GenerateSlotsForPeriod(
                    template,
                    request.StartDate,
                    request.EndDate,
                    exceptions
                );

                // 5. Filter by days (لو مطلوب أيام معينة)
                if (request.OnlyForDays?.Any() == true)
                {
                    generatedSlots = generatedSlots
                        .Where(s => request.OnlyForDays.Contains(s.SlotDate.DayOfWeek))
                        .ToList();

                    _logger.LogInformation(
                        "Filtered slots to only include days: {Days}",
                        string.Join(", ", request.OnlyForDays));
                }

                // 6. Process in batches
                var result = await ProcessSlotsInBatchesAsync(
                    doctorId,
                    generatedSlots,
                    request.RegenerateExisting,
                    request.BatchSize,
                    cancellationToken);

                stopwatch.Stop();
                result.ProcessingTime = stopwatch.Elapsed;

                _logger.LogInformation(
                    "Generated {SlotsAdded} slots in {Time}ms ({Batches} batches)",
                    result.SlotsGenerated,
                    stopwatch.ElapsedMilliseconds,
                    result.BatchesProcessed);

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating slots for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        // معالجة الـ slots على دفعات لتجنب البطء
        //private async Task<GenerateSlotsResponse> ProcessSlotsInBatchesAsync(
        //    int doctorId,
        //    List<TimeSlot> generatedSlots,
        //    bool regenerateExisting,
        //    int batchSize,
        //    CancellationToken cancellationToken)
        //{
        //    int slotsAdded = 0;
        //    int slotsSkipped = 0;
        //    int batchesProcessed = 0;

        //    // Handle empty list
        //    if (!generatedSlots.Any())
        //    {
        //        _logger.LogWarning(
        //            "No slots generated for doctor {DoctorId}. Likely no matching days in the period.",
        //            doctorId);

        //        return new GenerateSlotsResponse
        //        {
        //            SlotsGenerated = 0,
        //            SlotsSkipped = 0,
        //            GeneratedFrom = DateTime.UtcNow.Date,
        //            GeneratedTo = DateTime.UtcNow.Date,
        //            BatchesProcessed = 0,
        //            ProcessingTime = TimeSpan.Zero
        //        };
        //    }

        //    // تقسيم الـ slots لدفعات
        //    var batches = generatedSlots
        //        .Select((slot, index) => new { slot, index })
        //        .GroupBy(x => x.index / batchSize)
        //        .Select(g => g.Select(x => x.slot).ToList())
        //        .ToList();

        //    _logger.LogInformation(
        //        "Processing {TotalSlots} slots in {BatchCount} batches",
        //        generatedSlots.Count, batches.Count);

        //    foreach (var batch in batches)
        //    {
        //        try
        //        {
        //            // Get existing slots for this batch
        //            var batchDates = batch.Select(s => s.SlotDate.Date).Distinct().ToList();
        //            var existingSlots = await _timeSlotRepository
        //                .GetSlotsForDatesAsync(doctorId, batchDates, cancellationToken);

        //            var existingDict = existingSlots
        //                .GroupBy(s => new { s.SlotDate, s.StartTime })
        //                .ToDictionary(
        //                    g => g.Key,
        //                    g => g.First());

        //            // Process each slot
        //            foreach (var slot in batch)
        //            {
        //                var key = new { SlotDate = slot.SlotDate.Date, slot.StartTime };

        //                if (existingDict.TryGetValue(key, out var existingSlot))
        //                {
        //                    if (regenerateExisting)
        //                    {
        //                        //  Only regenerate Available slots
        //                        if (existingSlot.Status == SlotStatus.Available)
        //                        {
        //                            // Check if slot properties changed
        //                            bool needsRegeneration =
        //                                existingSlot.EndTime != slot.EndTime || // Duration changed
        //                                existingSlot.GeneratedFromTemplateId != slot.GeneratedFromTemplateId; // Template changed

        //                            if (needsRegeneration)
        //                            {
        //                                await _timeSlotRepository.DeleteAsync(existingSlot, cancellationToken);
        //                                await _timeSlotRepository.AddAsync(slot, cancellationToken);
        //                                slotsAdded++;

        //                                _logger.LogDebug("Regenerated slot at {Date} {Time}",
        //                                    slot.SlotDate, slot.StartTime);
        //                            }
        //                            else
        //                            {
        //                                slotsSkipped++; // Same properties, skip
        //                            }
        //                        }
        //                        else
        //                        {
        //                            slotsSkipped++; // Booked/Blocked, cannot regenerate

        //                            _logger.LogWarning(
        //                                "Cannot regenerate slot at {Date} {Time} - Status: {Status}",
        //                                existingSlot.SlotDate, existingSlot.StartTime, existingSlot.Status);
        //                        }
        //                    }
        //                    else
        //                    {
        //                        slotsSkipped++; // RegenerateExisting = false
        //                    }
        //                }
        //            }

        //            // Save batch
        //            await _unitOfWork.SaveChangesAsync(cancellationToken);
        //            batchesProcessed++;

        //            _logger.LogDebug(
        //                "Processed batch {BatchNum}/{TotalBatches}",
        //                batchesProcessed, batches.Count);
        //        }
        //        catch (Exception ex)
        //        {
        //            _logger.LogError(ex, "Error processing batch {BatchNum}", batchesProcessed + 1);
        //            throw;
        //        }
        //    }

        //    return new GenerateSlotsResponse
        //    {
        //        SlotsGenerated = slotsAdded,
        //        SlotsSkipped = slotsSkipped,
        //        GeneratedFrom = generatedSlots.Min(s => s.SlotDate),
        //        GeneratedTo = generatedSlots.Max(s => s.SlotDate),
        //        BatchesProcessed = batchesProcessed
        //    };
        //}

        private async Task<GenerateSlotsResponse> ProcessSlotsInBatchesAsync(
    int doctorId,
    List<TimeSlot> generatedSlots,
    bool regenerateExisting,
    int batchSize,
    CancellationToken cancellationToken)
        {
            int slotsAdded = 0;
            int slotsSkipped = 0;
            int batchesProcessed = 0;

            if (!generatedSlots.Any())
            {
                _logger.LogWarning("No slots generated for doctor {DoctorId}.", doctorId);
                return new GenerateSlotsResponse
                {
                    SlotsGenerated = 0,
                    SlotsSkipped = 0,
                    GeneratedFrom = DateTime.UtcNow.Date,
                    GeneratedTo = DateTime.UtcNow.Date,
                    BatchesProcessed = 0,
                    ProcessingTime = TimeSpan.Zero
                };
            }

            // ✅ Fix: Guard against zero or negative batchSize
            if (batchSize <= 0) batchSize = 1000;

            var batches = generatedSlots
                .Select((slot, index) => new { slot, index })
                .GroupBy(x => x.index / batchSize)
                .Select(g => g.Select(x => x.slot).ToList())
                .ToList();

            _logger.LogInformation(
                "Processing {TotalSlots} slots in {BatchCount} batches",
                generatedSlots.Count, batches.Count);

            foreach (var batch in batches)
            {
                try
                {
                    var batchDates = batch.Select(s => s.SlotDate.Date).Distinct().ToList();
                    var existingSlots = await _timeSlotRepository
                        .GetSlotsForDatesAsync(doctorId, batchDates, cancellationToken);

                    var existingDict = existingSlots
                        .GroupBy(s => new { Date = s.SlotDate.Date, s.StartTime })
                        .ToDictionary(g => g.Key, g => g.First());

                    foreach (var slot in batch)
                    {
                        var key = new { Date = slot.SlotDate.Date, slot.StartTime };

                        if (existingDict.TryGetValue(key, out var existingSlot))
                        {
                            if (regenerateExisting && existingSlot.Status == SlotStatus.Available)
                            {
                                bool needsRegeneration =
                                    existingSlot.EndTime != slot.EndTime ||
                                    existingSlot.GeneratedFromTemplateId != slot.GeneratedFromTemplateId;

                                if (needsRegeneration)
                                {
                                    await _timeSlotRepository.DeleteAsync(existingSlot, cancellationToken);
                                    await _timeSlotRepository.AddAsync(slot, cancellationToken);
                                    slotsAdded++;
                                }
                                else
                                {
                                    slotsSkipped++;
                                }
                            }
                            else
                            {
                                slotsSkipped++;
                            }
                        }
                        else
                        {
                            // ✅ الـ Fix الأساسي: إضافة الـ slot الجديد
                            await _timeSlotRepository.AddAsync(slot, cancellationToken);
                            slotsAdded++;
                        }
                    }

                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                    batchesProcessed++;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing batch {BatchNum}", batchesProcessed + 1);
                    throw;
                }
            }

            return new GenerateSlotsResponse
            {
                SlotsGenerated = slotsAdded,
                SlotsSkipped = slotsSkipped,
                GeneratedFrom = generatedSlots.Min(s => s.SlotDate),
                GeneratedTo = generatedSlots.Max(s => s.SlotDate),
                BatchesProcessed = batchesProcessed
            };
        }


        public async Task<List<AvailableSlotDto>> GetAvailableSlotsAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            var slots = await _timeSlotRepository.GetAvailableSlotsAsync(
                doctorId,
                startDate,
                endDate,
                cancellationToken);

            return slots.Select(s => new AvailableSlotDto
            {
                SlotId = s.Id,
                SlotDate = s.SlotDate,
                StartTime = s.StartTime,
                EndTime = s.EndTime,
                IsManuallyCreated = s.IsManuallyCreated
            }).ToList();
        }

        public async Task<Guid> CreateManualSlotAsync(
            int doctorId,
            DateTime slotDate,
            TimeSpan startTime,
            TimeSpan endTime,
            CancellationToken cancellationToken = default)
        {
            // Check if slot already exists
            var exists = await _timeSlotRepository.ExistsAsync(
                doctorId, slotDate, startTime, cancellationToken);

            if (exists)
                throw new DomainException("A slot already exists at this time");

            var slot = TimeSlot.CreateManual(doctorId, slotDate, startTime, endTime);

            await _timeSlotRepository.AddAsync(slot, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "Manual slot {SlotId} created for doctor {DoctorId}",
                slot.Id, doctorId);

            return slot.Id;
        }

        public async Task DeleteSlotAsync(
            Guid slotId,
            CancellationToken cancellationToken = default)
        {
            var slot = await _timeSlotRepository.GetByIdAsync(slotId, cancellationToken);

            if (slot == null)
                throw new NotFoundException("TimeSlot", slotId);

            if (slot.Status != SlotStatus.Available)
                throw new DomainException("Cannot delete a booked or blocked slot");

            await _timeSlotRepository.DeleteAsync(slot, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Slot {SlotId} deleted", slotId);
        }

        public async Task BlockSlotAsync(
            Guid slotId,
            CancellationToken cancellationToken = default)
        {
            var slot = await _timeSlotRepository.GetByIdAsync(slotId, cancellationToken);

            if (slot == null)
                throw new NotFoundException("TimeSlot", slotId);

            slot.Block();

            await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Slot {SlotId} blocked", slotId);
        }

        public async Task<GetDoctorTimeSlotsResponse> GetDoctorTimeSlotsInRangeAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            string? statusFilter = null,
            CancellationToken cancellationToken = default)
        {
            // Normalize dates to UTC midnight
            var from = startDate.Date;
            var to = endDate.Date;

            var isDoctor = _httpContextAccessor.HttpContext?.User.IsInRole("Doctor") ?? false;
            var currentUserIdClaim = _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            // جلب كل الـ slots في الفترة
            var slots = await _timeSlotRepository.GetSlotsInDateRangeAsync(
                doctorId,
                from,
                to,
                cancellationToken);

            // فلترة حسب status إذا وجد
            if (!string.IsNullOrWhiteSpace(statusFilter) && statusFilter != "AllSlots")
            {
                if (Enum.TryParse<SlotStatus>(statusFilter, true, out var targetStatus))
                {
                    slots = slots.Where(s => s.Status == targetStatus).ToList();
                }
            }

            var grouped = slots
             .GroupBy(s => s.SlotDate.Date)
             .Select(g => new DailySlotsDto
             {
                 Date = g.Key,
                 DayOfWeek = g.Key.ToString("dddd", System.Globalization.CultureInfo.InvariantCulture),
                 Slots = g
                     .OrderBy(s => s.StartTime)
                     .Select(s => new TimeSlotDetailDto
                     {
                         SlotId = s.Id,
                         SlotDate = s.SlotDate,
                         StartTime = s.StartTime,
                         EndTime = s.EndTime,
                         Status = s.Status,
                         IsManuallyCreated = s.IsManuallyCreated,
                         GeneratedFromTemplateId = s.GeneratedFromTemplateId,
                         CreatedAt = s.CreatedAt,
                         UpdatedAt = s.UpdatedAt,

                         // ── Conditional fields للدكتور بس ──
                         AppointmentId = isDoctor ? s.Appointment?.Id : null,
                         PatientFullName = isDoctor ? s.Appointment?.Patient?.User?.FullName : null,
                         PatientNotes = isDoctor ? s.Appointment?.PatientNotes : null
                     })
                     .ToList()
             })
             .OrderBy(d => d.Date)
             .ToList();

            return new GetDoctorTimeSlotsResponse
            {
                DoctorId = doctorId,
                StartDate = from,
                EndDate = to,
                DailySlots = grouped
            };
        }
    }
}