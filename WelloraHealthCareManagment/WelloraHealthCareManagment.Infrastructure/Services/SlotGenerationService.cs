using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Domain.Constants;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;


namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class SlotGenerationService : ISlotGenerationService
    {
        private readonly IDoctorSlotConfigRepository _configRepository;
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IScheduleExceptionRepository _exceptionRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<SlotGenerationService> _logger;

        public SlotGenerationService(
            IDoctorSlotConfigRepository configRepository,
            ITimeSlotRepository timeSlotRepository,
            IScheduleExceptionRepository exceptionRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            ILogger<SlotGenerationService> logger)
        {
            _configRepository = configRepository;
            _timeSlotRepository = timeSlotRepository;
            _exceptionRepository = exceptionRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }


        // Public API


        public async Task<GenerateSlotsResponse> GenerateAsync(
            int doctorId,
            GenerateSlotsByConfigRequest request,
            CancellationToken ct = default)
        {
            try
            {
                _logger.LogInformation(
                    "Generating slots for doctor {DoctorId} from {Start} to {End}",
                    doctorId, request.StartDate, request.EndDate);

                // Clamp to max months
                var monthsDiff =
                    (request.EndDate.Year - request.StartDate.Year) * 12
                    + request.EndDate.Month - request.StartDate.Month;

                if (monthsDiff > SlotSystemConstants.MaxGenerationMonths)
                    request.EndDate = request.StartDate
                        .AddMonths(SlotSystemConstants.MaxGenerationMonths);

                // 1. جيب الـ active configs
                var configs = await _configRepository
                    .GetActiveConfigsAsync(doctorId, ct);

                if (!configs.Any())
                    throw new DomainException(
                        "No active slot configs found for this doctor");

                if (request.OnlyForDays?.Any() == true)
                    configs = configs
                        .Where(c => request.OnlyForDays.Contains(c.DayOfWeek))
                        .ToList();

                // 2. جيب الـ exceptions
                var exceptions = await _exceptionRepository
                    .GetExceptionsForPeriodAsync(
                        doctorId, request.StartDate, request.EndDate, ct);

                var exceptionByDate = exceptions
                    .GroupBy(e => e.ExceptionDate.Date)
                    .ToDictionary(g => g.Key, g => g.First());

                // 3. ولّد الـ slots لكل config
                var allSlots = new List<TimeSlot>();

                foreach (var config in configs)
                {
                    // conflict check بيحصل في ProcessSlotsInBatchesAsync
                    var slots = BuildSlotsForDateRange(
                        doctorId, config,
                        request.StartDate, request.EndDate,
                        exceptionByDate,
                        occupiedByDate: new Dictionary<DateTime, List<TimeSlot>>());

                    allSlots.AddRange(slots);
                }

                return await ProcessSlotsInBatchesAsync(
                    doctorId,
                    allSlots,
                    request.RegenerateExisting,
                    request.BatchSize <= 0
                        ? SlotSystemConstants.DefaultBatchSize
                        : request.BatchSize,
                    ct);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error generating slots for doctor {DoctorId}", doctorId);
                throw;
            }
        }

        public async Task RegenerateForDayAsync(
            int doctorId,
            DayOfWeek day,
            CancellationToken ct = default)
        {
            var fromDate = DateTime.UtcNow.Date;
            var toDate = fromDate.AddMonths(SlotSystemConstants.RollingWindowMonths);

            // 1. جيب كل الـ slots للأيام دي
            var allSlots = await _timeSlotRepository
                .GetSlotsForDaysInRangeAsync(
                    doctorId, new List<DayOfWeek> { day }, fromDate, toDate, ct);

            // 2. امسح Available + Blocked غير المرتبطة بأي Appointment
            var protectedSlotIds = await GetProtectedSlotIdsAsync(allSlots, ct);

            var slotsToDelete = allSlots
                .Where(s =>
                    (s.Status == SlotStatus.Available ||
                     s.Status == SlotStatus.Blocked) &&
                    !protectedSlotIds.Contains(s.Id))
                .ToList();

            var occupiedByDate = allSlots
                .Where(s => s.Status == SlotStatus.Booked || protectedSlotIds.Contains(s.Id))
                .GroupBy(s => s.SlotDate.Date)
                .ToDictionary(g => g.Key, g => g.ToList());

            if (slotsToDelete.Any())
                await _timeSlotRepository.DeleteRangeAsync(slotsToDelete, ct);

            // 3. جيب الـ config
            var config = await _configRepository
                .GetByDoctorAndDayAsync(doctorId, day, ct);

            if (config == null || !config.IsActive)
            {
                _logger.LogInformation(
                    "No active config for {Day} — skipping regeneration", day);
                return;
            }

            // 4. جيب الـ exceptions للفترة دي
            var exceptions = await _exceptionRepository
                .GetExceptionsForPeriodAsync(doctorId, fromDate, toDate, ct);

            var exceptionByDate = exceptions
                .Where(e => e.ExceptionDate.DayOfWeek == day)
                .GroupBy(e => e.ExceptionDate.Date)
                .ToDictionary(g => g.Key, g => g.First());

            // 5. ولّد الـ slots الجديدة — نفس BuildSlotsForDateRange
            var slotsToAdd = BuildSlotsForDateRange(
                doctorId, config, fromDate, toDate,
                exceptionByDate, occupiedByDate);

            if (slotsToAdd.Any())
                await _timeSlotRepository.AddRangeAsync(slotsToAdd, ct);

            _logger.LogInformation(
                "Staged {Count} slots for doctor {DoctorId} day {Day}",
                slotsToAdd.Count, doctorId, day);
        }

        public async Task RegenerateForSingleDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken ct = default)
        {
            // 1. جيب الـ config
            var config = await _configRepository
                .GetByDoctorAndDayAsync(doctorId, date.DayOfWeek, ct);

            if (config == null || !config.IsActive)
            {
                _logger.LogInformation(
                    "No active config for {Day} — skipping regeneration",
                    date.DayOfWeek);
                return;
            }

            // 2. جيب كل الـ slots لليوم ده
            var allSlots = await _timeSlotRepository
                .GetSlotsForDaysInRangeAsync(
                    doctorId, new List<DayOfWeek> { date.DayOfWeek },
                    date.Date, date.Date, ct);

            // 3. امسح Available + Blocked غير المرتبطة بأي Appointment
            var protectedSlotIds = await GetProtectedSlotIdsAsync(allSlots, ct);

            var slotsToDelete = allSlots
                .Where(s =>
                    (s.Status == SlotStatus.Available ||
                     s.Status == SlotStatus.Blocked) &&
                    !protectedSlotIds.Contains(s.Id))
                .ToList();

            var occupiedByDate = allSlots
                .Where(s => s.Status == SlotStatus.Booked || protectedSlotIds.Contains(s.Id))
                .GroupBy(s => s.SlotDate.Date)
                .ToDictionary(g => g.Key, g => g.ToList());

            if (slotsToDelete.Any())
                await _timeSlotRepository.DeleteRangeAsync(slotsToDelete, ct);

            // 4. ولّد بالـ config الكامل — exception اتحذف قبل كده
            var slotsToAdd = BuildSlotsForDateRange(
                doctorId, config,
                date.Date, date.Date,
                exceptionByDate: new Dictionary<DateTime, ScheduleException>(),
                occupiedByDate);

            if (slotsToAdd.Any())
                await _timeSlotRepository.AddRangeAsync(slotsToAdd, ct);

            _logger.LogInformation(
                "Regenerated {Count} slots for doctor {DoctorId} on {Date}",
                slotsToAdd.Count, doctorId, date.Date);
        }


        // Private Helpers

        /// الميثود الوحيدة المسؤولة عن توليد الـ slots — كل الـ public methods بتستخدمها
        private List<TimeSlot> BuildSlotsForDateRange(
            int doctorId,
            DoctorSlotConfig config,
            DateTime fromDate,
            DateTime toDate,
            Dictionary<DateTime, ScheduleException> exceptionByDate,
            Dictionary<DateTime, List<TimeSlot>> occupiedByDate)
        {
            var result = new List<TimeSlot>();
            var now = DateTime.UtcNow;
            var currentDate = fromDate.Date;

            while (currentDate <= toDate.Date)
            {
                if (currentDate.DayOfWeek == config.DayOfWeek)
                {
                    exceptionByDate.TryGetValue(currentDate, out var exception);
                    var slotTimes = config.GetEffectiveSlotTimes(exception);
                    var occupied = occupiedByDate.GetValueOrDefault(
                        currentDate, new List<TimeSlot>());

                    foreach (var (start, end) in slotTimes)
                    {
                        // تجاهل الأوقات الماضية
                        if (currentDate < now.Date) break;
                        if (currentDate == now.Date && start <= now.TimeOfDay)
                            continue;

                        bool hasConflict = occupied.Any(o =>
                            start < o.EndTime && end > o.StartTime);

                        if (!hasConflict)
                            result.Add(TimeSlot.CreateFromConfig(
                                doctorId, currentDate, start, end));
                    }
                }

                currentDate = currentDate.AddDays(1);
            }

            return result;
        }

        private async Task<HashSet<Guid>> GetProtectedSlotIdsAsync(
            IEnumerable<TimeSlot> slots,
            CancellationToken ct)
        {
            var slotIds = slots
                .Select(s => s.Id)
                .Distinct()
                .ToList();

            if (!slotIds.Any())
                return new HashSet<Guid>();

            var appointments = await _appointmentRepository
                .GetByTimeSlotIdsAsync(slotIds, ct);

            return appointments
                .Select(a => a.TimeSlotId)
                .ToHashSet();
        }

        //private async Task<GenerateSlotsResponse> ProcessSlotsInBatchesAsync(
        //    int doctorId,
        //    List<TimeSlot> generatedSlots,
        //    bool regenerateExisting,
        //    int batchSize,
        //    CancellationToken ct)
        //{
        //    // ── Deduplication داخلي قوي (احتياطي) ──
        //    if (generatedSlots.Any())
        //    {
        //        var uniqueSlots = new Dictionary<(DateTime Date, TimeSpan StartTime), TimeSlot>();

        //        foreach (var slot in generatedSlots)
        //        {
        //            var key = (slot.SlotDate.Date, slot.StartTime);
        //            if (!uniqueSlots.ContainsKey(key))
        //                uniqueSlots[key] = slot;
        //            else
        //                _logger.LogDebug("Internal duplicate ignored: {Date} {StartTime}", slot.SlotDate.Date, slot.StartTime);
        //        }

        //        var removed = generatedSlots.Count - uniqueSlots.Count;
        //        if (removed > 0)
        //            _logger.LogWarning("Removed {Removed} internal duplicates for doctor {DoctorId}", removed, doctorId);

        //        generatedSlots = uniqueSlots.Values.ToList();
        //    }

        //    int slotsAdded = 0, slotsSkipped = 0, batchesProcessed = 0;

        //    if (!generatedSlots.Any())
        //    {
        //        _logger.LogInformation("No unique slots to generate for doctor {DoctorId}", doctorId);
        //        return new GenerateSlotsResponse { SlotsGenerated = 0, SlotsSkipped = 0, BatchesProcessed = 0 };
        //    }

        //    // ── Regenerate: احذف Available و Blocked فقط ──
        //    if (regenerateExisting)
        //    {
        //        var allDates = generatedSlots.Select(s => s.SlotDate.Date).Distinct().ToList();
        //        var toDelete = (await _timeSlotRepository.GetSlotsForDatesAsync(doctorId, allDates, ct))
        //            .Where(s => s.Status == SlotStatus.Available || s.Status == SlotStatus.Blocked)
        //            .ToList();

        //        if (toDelete.Any())
        //        {
        //            await _timeSlotRepository.DeleteRangeAsync(toDelete, ct);
        //            await _unitOfWork.SaveChangesAsync(ct);
        //            _logger.LogInformation("Deleted {Count} old Available/Blocked slots before regeneration", toDelete.Count);
        //        }
        //    }

        //    // ── Batch Processing مع check قوي ضد الداتابيز ──
        //    var batches = generatedSlots
        //        .Select((s, i) => new { s, i })
        //        .GroupBy(x => x.i / (batchSize > 0 ? batchSize : 1000))
        //        .Select(g => g.Select(x => x.s).ToList())
        //        .ToList();

        //    _logger.LogInformation("Processing {Total} unique slots in {Batches} batches for doctor {DoctorId}",
        //        generatedSlots.Count, batches.Count, doctorId);

        //    foreach (var batch in batches)
        //    {
        //        var batchDates = batch.Select(s => s.SlotDate.Date).Distinct().ToList();

        //        // جيب كل الـ slots الموجودة فعلاً في الداتابيز لهذه التواريخ
        //        var existingSlots = await _timeSlotRepository.GetSlotsForDatesAsync(doctorId, batchDates, ct);

        //        // HashSet للـ keys الموجودة (هذا هو الـ gate النهائي ضد duplicate)
        //        var existingKeys = existingSlots
        //            .Select(s => (s.SlotDate.Date, s.StartTime))
        //            .ToHashSet();

        //        var bookedByDate = existingSlots
        //            .Where(s => s.Status == SlotStatus.Booked)
        //            .GroupBy(s => s.SlotDate.Date)
        //            .ToDictionary(g => g.Key, g => g.ToList());

        //        var slotsToInsert = new List<TimeSlot>();

        //        foreach (var slot in batch)
        //        {
        //            var key = (slot.SlotDate.Date, slot.StartTime);

        //            // 1. لو موجود فعلاً في الداتابيز (Booked أو Cancelled) → skip
        //            if (existingKeys.Contains(key))
        //            {
        //                slotsSkipped++;
        //                _logger.LogDebug("Skipped existing slot (preserve Booked/Cancelled): {Date} {StartTime}",
        //                    slot.SlotDate.Date, slot.StartTime);
        //                continue;
        //            }

        //            // 2. check overlap مع Booked (احتياطي)
        //            var booked = bookedByDate.GetValueOrDefault(slot.SlotDate.Date, new List<TimeSlot>());
        //            bool hasConflict = booked.Any(o =>
        //                slot.StartTime < o.EndTime && slot.EndTime > o.StartTime);

        //            if (hasConflict)
        //            {
        //                slotsSkipped++;
        //                _logger.LogDebug("Skipped due to overlap with Booked slot: {Date} {StartTime}",
        //                    slot.SlotDate.Date, slot.StartTime);
        //                continue;
        //            }

        //            slotsToInsert.Add(slot);
        //            slotsAdded++;
        //        }

        //        if (slotsToInsert.Any())
        //        {
        //            await _timeSlotRepository.BulkInsertAsync(slotsToInsert, ct);
        //            _logger.LogInformation("Batch {Batch} → Inserted {Count} new slots",
        //                batchesProcessed + 1, slotsToInsert.Count);
        //        }

        //        batchesProcessed++;
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
    CancellationToken ct)
        {
            // Deduplication داخلي قوي
            if (generatedSlots.Any())
            {
                var uniqueSlots = new Dictionary<(DateTime Date, TimeSpan StartTime), TimeSlot>();

                foreach (var slot in generatedSlots)
                {
                    var key = (slot.SlotDate.Date, slot.StartTime);
                    if (!uniqueSlots.ContainsKey(key))
                        uniqueSlots[key] = slot;
                    else
                        _logger.LogDebug("Internal duplicate ignored: {Date} {StartTime}", slot.SlotDate.Date, slot.StartTime);
                }

                var removed = generatedSlots.Count - uniqueSlots.Count;
                if (removed > 0)
                    _logger.LogWarning("Removed {Removed} internal duplicates for doctor {DoctorId}", removed, doctorId);

                generatedSlots = uniqueSlots.Values.ToList();
            }

            int slotsAdded = 0, slotsSkipped = 0, batchesProcessed = 0;

            if (!generatedSlots.Any())
            {
                _logger.LogInformation("No unique slots to generate for doctor {DoctorId}", doctorId);
                return new GenerateSlotsResponse { SlotsGenerated = 0, SlotsSkipped = 0, BatchesProcessed = 0 };
            }

            // ── RegenerateExisting: نحذف Available + Blocked ونسيب Booked كما هي ──
            if (regenerateExisting)
            {
                var allDates = generatedSlots.Select(s => s.SlotDate.Date).Distinct().ToList();
                var existingSlots = await _timeSlotRepository.GetSlotsForDatesAsync(doctorId, allDates, ct);
                var protectedSlotIds = await GetProtectedSlotIdsAsync(existingSlots, ct);

                var toDelete = existingSlots
                    .Where(s =>
                        (s.Status == SlotStatus.Available ||
                         s.Status == SlotStatus.Blocked) &&
                        !protectedSlotIds.Contains(s.Id))
                    .ToList();

                if (toDelete.Any())
                {
                    await _timeSlotRepository.DeleteRangeAsync(toDelete, ct);
                    await _unitOfWork.SaveChangesAsync(ct);
                    _logger.LogInformation(
                        "Deleted {Count} Available/Blocked slots before regeneration (Booked slots preserved)",
                        toDelete.Count);
                }
                else
                {
                    _logger.LogInformation(
                        "No Available/Blocked slots to delete for regeneration (Booked slots preserved)");
                }
            }

            // ── Batch Processing مع overlap prevention قوي ──
            var batches = generatedSlots
                .Select((s, i) => new { s, i })
                .GroupBy(x => x.i / (batchSize > 0 ? batchSize : 1000))
                .Select(g => g.Select(x => x.s).ToList())
                .ToList();

            _logger.LogInformation("Processing {Total} unique slots in {Batches} batches for doctor {DoctorId}",
                generatedSlots.Count, batches.Count, doctorId);

            foreach (var batch in batches)
            {
                var batchDates = batch.Select(s => s.SlotDate.Date).Distinct().ToList();
                var existingSlots = await _timeSlotRepository.GetSlotsForDatesAsync(doctorId, batchDates, ct);

                var existingKeys = existingSlots
                    .Select(s => (s.SlotDate.Date, s.StartTime))
                    .ToHashSet();

                var bookedByDate = existingSlots
                    .Where(s => s.Status == SlotStatus.Booked)
                    .GroupBy(s => s.SlotDate.Date)
                    .ToDictionary(g => g.Key, g => g.ToList());

                var slotsToInsert = new List<TimeSlot>();

                foreach (var slot in batch)
                {
                    var key = (slot.SlotDate.Date, slot.StartTime);

                    // 1. لو الـ slot موجود بالفعل في الداتابيز (Booked أو أي status) → skip
                    if (existingKeys.Contains(key))
                    {
                        slotsSkipped++;
                        _logger.LogDebug("Skipped existing slot (preserve Booked): {Date} {StartTime}",
                            slot.SlotDate.Date, slot.StartTime);
                        continue;
                    }

                    // 2. overlap check مع Booked slots (مهم جداً زي ما قلت)
                    var booked = bookedByDate.GetValueOrDefault(slot.SlotDate.Date, new List<TimeSlot>());
                    bool hasConflict = booked.Any(o =>
                        slot.StartTime < o.EndTime && slot.EndTime > o.StartTime);

                    if (hasConflict)
                    {
                        slotsSkipped++;
                        _logger.LogDebug("Skipped due to overlap with Booked slot: {Date} {StartTime}",
                            slot.SlotDate.Date, slot.StartTime);
                        continue;
                    }

                    slotsToInsert.Add(slot);
                    slotsAdded++;
                }

                if (slotsToInsert.Any())
                {
                    await _timeSlotRepository.BulkInsertAsync(slotsToInsert, ct);
                    _logger.LogInformation("Batch {Batch} → Inserted {Count} new slots",
                        batchesProcessed + 1, slotsToInsert.Count);
                }

                batchesProcessed++;
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
    }
}
