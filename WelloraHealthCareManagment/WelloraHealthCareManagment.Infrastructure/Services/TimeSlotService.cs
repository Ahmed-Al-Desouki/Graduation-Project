using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class TimeSlotService : ITimeSlotService
    {
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IScheduleExceptionRepository _exceptionRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<TimeSlotService> _logger;

        public TimeSlotService(
            ITimeSlotRepository timeSlotRepository,
            IScheduleExceptionRepository exceptionRepository,
            IUnitOfWork unitOfWork,
            ILogger<TimeSlotService> logger)
        {
            _timeSlotRepository = timeSlotRepository;
            _exceptionRepository = exceptionRepository;
            _unitOfWork = unitOfWork;
            _logger = logger;
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
            int requesterUserId,
            string requesterRole,
            CancellationToken ct = default)
        {
            EnsureDoctorAccess(doctorId, requesterUserId, requesterRole);

            var hasOverlap = await _timeSlotRepository
                .HasOverlapAsync(doctorId, slotDate, startTime, endTime, null, ct);

            if (hasOverlap)
            {
                throw new DomainException("A slot already exists that overlaps with this time range");
            }

            var slot = TimeSlot.CreateManual(doctorId, slotDate, startTime, endTime);

            await _timeSlotRepository.AddAsync(slot, ct);
            await _unitOfWork.SaveChangesAsync(ct);

            _logger.LogInformation(
                "Manual slot {SlotId} created for doctor {DoctorId}",
                slot.Id,
                doctorId);

            return slot.Id;
        }

        public async Task DeleteSlotAsync(
            Guid slotId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var slot = await _timeSlotRepository.GetByIdAsync(slotId, cancellationToken);

            if (slot == null)
            {
                throw new NotFoundException("TimeSlot", slotId);
            }

            EnsureDoctorAccess(slot.DoctorId, requesterUserId, requesterRole);

            if (slot.Status != SlotStatus.Available)
            {
                throw new DomainException("Cannot delete a booked or blocked slot");
            }

            await _timeSlotRepository.DeleteAsync(slot, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Slot {SlotId} deleted", slotId);
        }

        public async Task BlockSlotAsync(
            Guid slotId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var slot = await _timeSlotRepository.GetByIdAsync(slotId, cancellationToken);

            if (slot == null)
            {
                throw new NotFoundException("TimeSlot", slotId);
            }

            EnsureDoctorAccess(slot.DoctorId, requesterUserId, requesterRole);

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
            int requesterUserId = 0,
            string requesterRole = "",
            CancellationToken cancellationToken = default)
        {
            EnsureDoctorAccess(doctorId, requesterUserId, requesterRole);

            var from = startDate.Date;
            var to = endDate.Date;
            var canSeePatientDetails =
                string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase);

            var slots = await _timeSlotRepository.GetSlotsInDateRangeAsync(
                doctorId,
                from,
                to,
                cancellationToken);

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
                            AppointmentId = canSeePatientDetails ? s.Appointment?.Id : null,
                            PatientFullName = canSeePatientDetails ? s.Appointment?.Patient?.User?.FullName : null,
                            PatientNotes = canSeePatientDetails ? s.Appointment?.PatientNotes : null
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

        private static void EnsureDoctorAccess(int doctorId, int requesterUserId, string requesterRole)
        {
            if (string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase) &&
                doctorId == requesterUserId)
            {
                return;
            }

            throw new UnauthorizedAccessException("You are not allowed to manage these time slots.");
        }
    }
}
