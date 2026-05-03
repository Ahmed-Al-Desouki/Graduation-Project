using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class TimeSlotService : ITimeSlotService
    {
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IScheduleExceptionRepository _exceptionRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IRealtimeService _realtimeService;
        private readonly ILogger<TimeSlotService> _logger;

        public TimeSlotService(
            ITimeSlotRepository timeSlotRepository,
            IScheduleExceptionRepository exceptionRepository,
            IAppointmentRepository appointmentRepository,
            IUnitOfWork unitOfWork,
            IRealtimeService realtimeService,
            ILogger<TimeSlotService> logger)
        {
            _timeSlotRepository = timeSlotRepository;
            _exceptionRepository = exceptionRepository;
            _appointmentRepository = appointmentRepository;
            _unitOfWork = unitOfWork;
            _realtimeService = realtimeService;
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
            await BroadcastSlotUpdatedAsync(slot, ct);

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
            await BroadcastSlotUpdatedAsync(slot, cancellationToken);

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
            await BroadcastSlotUpdatedAsync(slot, cancellationToken);

            _logger.LogInformation("Slot {SlotId} blocked", slotId);
        }

        public async Task<int> RestoreBlockedSlotsAsync(
            int doctorId,
            List<Guid> slotIds,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            EnsureDoctorAccess(doctorId, requesterUserId, requesterRole);

            var normalizedSlotIds = slotIds
                .Where(id => id != Guid.Empty)
                .Distinct()
                .ToList();

            if (!normalizedSlotIds.Any())
                throw new DomainException("At least one valid slot id is required");

            var restoredSlots = new List<TimeSlot>();

            foreach (var slotId in normalizedSlotIds)
            {
                var slot = await _timeSlotRepository.GetByIdAsync(slotId, cancellationToken);

                if (slot == null)
                    throw new NotFoundException("TimeSlot", slotId);

                if (slot.DoctorId != doctorId)
                    throw new DomainException($"Slot {slotId} does not belong to doctor {doctorId}");

                if (slot.Status != SlotStatus.Blocked)
                    throw new DomainException($"Slot {slotId} is not blocked");

                if (slot.IsExpired())
                    throw new DomainException($"Slot {slotId} is in the past or already ended");

                var appointment = await _appointmentRepository
                    .GetByTimeSlotIdAsync(slotId, cancellationToken);

                if (appointment != null)
                {
                    throw new DomainException(
                        $"Slot {slotId} cannot be restored because it is linked to appointment {appointment.Id}");
                }

                slot.MakeAvailable();
                await _timeSlotRepository.UpdateAsync(slot, cancellationToken);
                restoredSlots.Add(slot);
            }

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            foreach (var slot in restoredSlots)
            {
                await BroadcastSlotUpdatedAsync(slot, cancellationToken);
            }

            _logger.LogInformation(
                "Restored {Count} blocked slots for doctor {DoctorId}",
                restoredSlots.Count,
                doctorId);

            return restoredSlots.Count;
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
            EnsureDoctorRangeAccess(doctorId, requesterUserId, requesterRole);

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

        private static void EnsureDoctorRangeAccess(int doctorId, int requesterUserId, string requesterRole)
        {
            if (string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            EnsureDoctorAccess(doctorId, requesterUserId, requesterRole);
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

        private Task BroadcastSlotUpdatedAsync(TimeSlot slot, CancellationToken ct)
        {
            var payload = new SlotRealtimeDto
            {
                SlotId = slot.Id,
                DoctorId = slot.DoctorId,
                AppointmentId = slot.Appointment?.Id,
                Status = slot.Status,
                SlotDate = slot.SlotDate,
                StartTime = slot.StartTime,
                EndTime = slot.EndTime,
                IsManuallyCreated = slot.IsManuallyCreated,
                UpdatedAt = slot.UpdatedAt
            };

            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { slot.DoctorId },
                "timeslot",
                slot.Id.ToString("D"),
                "SlotUpdated",
                payload,
                ct);
        }
    }
}
