using Microsoft.Extensions.Logging;
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

        public TimeSlotService(
            ITimeSlotRepository timeSlotRepository,
            IDoctorScheduleRepository scheduleRepository,
            IScheduleExceptionRepository exceptionRepository,
            ITimeSlotGeneratorFactory slotGeneratorFactory,
            IUnitOfWork unitOfWork,
            ILogger<TimeSlotService> logger)
        {
            _timeSlotRepository = timeSlotRepository;
            _scheduleRepository = scheduleRepository;
            _exceptionRepository = exceptionRepository;
            _slotGeneratorFactory = slotGeneratorFactory;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }

        public async Task<GenerateSlotsResponse> GenerateSlotsAsync(
            int doctorId,
            GenerateSlotsRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Generating slots for doctor {DoctorId} from {StartDate} to {EndDate}",
                    doctorId, request.StartDate, request.EndDate);

                // 1. Get active template
                var template = await _scheduleRepository
                    .GetActiveTemplateAsync(doctorId, cancellationToken);

                if (template == null)
                    throw new DomainException("No active schedule template found for this doctor");

                // 2. Get exceptions
                var exceptions = await _exceptionRepository
                    .GetExceptionsForPeriodAsync(
                        doctorId,
                        request.StartDate,
                        request.EndDate,
                        cancellationToken);

                // 3. Generate slots using Factory
                var generatedSlots = _slotGeneratorFactory.GenerateSlotsForPeriod(
                    template,
                    request.StartDate,
                    request.EndDate,
                    exceptions
                );

                int slotsAdded = 0;
                int slotsSkipped = 0;

                // 4. Filter existing slots (مهم للمرونة!)
                foreach (var slot in generatedSlots)
                {
                    // Check if slot already exists
                    var exists = await _timeSlotRepository.ExistsAsync(
                        slot.DoctorId,
                        slot.SlotDate,
                        slot.StartTime,
                        cancellationToken);

                    if (exists)
                    {
                        if (request.RegenerateExisting)
                        {
                            // حذف القديم وإضافة الجديد
                            var existingSlots = await _timeSlotRepository
                                .GetExistingSlotsForDateAsync(slot.DoctorId, slot.SlotDate, cancellationToken);

                            var slotToDelete = existingSlots.FirstOrDefault(s =>
                                s.StartTime == slot.StartTime && s.Status == SlotStatus.Available);

                            if (slotToDelete != null)
                            {
                                await _timeSlotRepository.DeleteAsync(slotToDelete, cancellationToken);
                                await _timeSlotRepository.AddAsync(slot, cancellationToken);
                                slotsAdded++;
                            }
                            else
                            {
                                slotsSkipped++; // محجوز - لا يمكن حذفه
                            }
                        }
                        else
                        {
                            slotsSkipped++;
                        }
                    }
                    else
                    {
                        await _timeSlotRepository.AddAsync(slot, cancellationToken);
                        slotsAdded++;
                    }
                }

                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Generated {SlotsAdded} slots, skipped {SlotsSkipped} for doctor {DoctorId}",
                    slotsAdded, slotsSkipped, doctorId);

                return new GenerateSlotsResponse
                {
                    SlotsGenerated = slotsAdded,
                    SlotsSkipped = slotsSkipped,
                    GeneratedFrom = request.StartDate,
                    GeneratedTo = request.EndDate
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating slots for doctor {DoctorId}", doctorId);
                throw;
            }
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
    }
}