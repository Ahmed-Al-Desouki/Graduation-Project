using HealthCare_.Models.DoctorModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class AppointmentService : IAppointmentService
    {
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IMedicalHistoryAccessRepository _accessRepository;
        private readonly IAppointmentReminderService _appointmentReminderService;
        private readonly IAppointmentFactory _appointmentFactory;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<AppointmentService> _logger;

        public AppointmentService(
            IAppointmentRepository appointmentRepository,
            ITimeSlotRepository timeSlotRepository,
            IMedicalHistoryAccessRepository accessRepository,
            IAppointmentReminderService appointmentReminderService,
            IAppointmentFactory appointmentFactory,
            IUnitOfWork unitOfWork,
            ILogger<AppointmentService> logger)
        {
            _appointmentRepository = appointmentRepository;
            _timeSlotRepository = timeSlotRepository;
            _accessRepository = accessRepository;
            _appointmentReminderService = appointmentReminderService;
            _appointmentFactory = appointmentFactory;
            _unitOfWork = unitOfWork;
            _logger = logger;
        }
        public async Task<BookAppointmentResponse> BookAppointmentAsync(
            int patientId,
            BookAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Patient {PatientId} attempting to book slot {SlotId}",
                    patientId, request.TimeSlotId);

                // 1. Get TimeSlot with Doctor
                var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                    request.TimeSlotId, cancellationToken);

                if (timeSlot == null)
                    throw new NotFoundException("TimeSlot", request.TimeSlotId);

                if (timeSlot.IsExpired())
                    throw new DomainException("This time slot has already passed and cannot be booked");

                if (timeSlot.Doctor == null)
                    throw new DomainException("Doctor information is missing");

                // 2. Check double booking
                var existingAppointment = await _appointmentRepository
                    .GetByTimeSlotIdAsync(request.TimeSlotId, cancellationToken);

                if (existingAppointment != null)
                    throw new DomainException("This time slot is already booked");

                // 3. Create Appointment
                var appointment = Appointment.Create(
                    timeSlot.Id,
                    timeSlot.DoctorId,
                    patientId,
                    request.PatientNotes);

                // 4. Update TimeSlot
                timeSlot.Book();

                // 5. Save Appointment & TimeSlot
                await _appointmentRepository.AddAsync(appointment, cancellationToken);
                await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);

                // 6. Create Medical History Access Grant (if requested)
                MedicalHistoryAccessGrant? accessGrant = null;
                if (request.GrantMedicalHistoryAccess)
                {
                    var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.EndTime);
                    var expiryDate = appointmentDateTime.AddHours(24);

                    accessGrant = MedicalHistoryAccessGrant.Create(
                        patientId: patientId,
                        doctorId: timeSlot.DoctorId,
                        appointmentId: appointment.Id,
                        grantType: GrantType.Appointment,
                        expiresAt: expiryDate,
                        canViewMedicalHistory: true,
                        canViewPrescriptions: true,
                        canViewLabResults: false
                    );

                    await _accessRepository.AddAsync(accessGrant, cancellationToken);
                }

                // 7. Create Appointment Reminders using ReminderV2 system
                await _appointmentReminderService.CreateAppointmentRemindersAsync(
                    appointment,
                    timeSlot,
                    patientId,
                    timeSlot.DoctorId,
                    cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} booked successfully by patient {PatientId}",
                    appointment.Id, patientId);

                return new BookAppointmentResponse
                {
                    AppointmentId = appointment.Id,
                    AppointmentDate = timeSlot.SlotDate,
                    AppointmentTime = timeSlot.StartTime,
                    DoctorName = timeSlot.Doctor.User?.FullName ?? "Dr. (Name unavailable)",
                    MedicalHistoryAccessGranted = accessGrant != null
                };
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error booking appointment for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task CancelByPatientAsync(
            Guid appointmentId,
            int patientId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                // Validate ownership
                if (appointment.PatientId != patientId)
                    throw new UnauthorizedAccessException("This appointment does not belong to you");

                // Validate cancellable status
                if (appointment.Status is AppointmentStatus.Completed
                    or AppointmentStatus.Cancelled
                    or AppointmentStatus.NoShow)
                    throw new DomainException("Cannot cancel a completed, cancelled, or no-show appointment");

                // Determine who cancelled
                var cancelledBy = CancelledBy.Patient;

                // Cancel appointment
                appointment.Cancel(cancelledBy, request.Reason);
                appointment.ClearPatientData();

                // Free up the time slot
                var timeSlot = await _timeSlotRepository.GetByIdAsync(
                    appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    timeSlot.MakeAvailable();
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                // Cancel all reminders
                await _appointmentReminderService.CancelAppointmentRemindersAsync(
                    appointmentId,
                    appointment.PatientId,
                    cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} cancelled by Patient",
                    appointmentId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error cancelling appointment {AppointmentId} by patient", appointmentId);
                throw;
            }
        }

        // Cancel and block appointment by doctor - blocks slot to prevent re-booking
        public async Task CancelAndBlockByDoctorAsync(
            Guid appointmentId,
            int doctorId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                // Validate ownership
                if (appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("This appointment does not belong to you");

                // Reason is required when doctor cancels
                if (string.IsNullOrWhiteSpace(request.Reason))
                    throw new DomainException("Reason is required when doctor cancels an appointment");

                // Determine who cancelled
                var cancelledBy = CancelledBy.Doctor;

                // Cancel appointment
                appointment.Cancel(cancelledBy, request.Reason);
                appointment.ClearPatientData();

                // Get and update the time slot
                var timeSlot = await _timeSlotRepository.GetByIdAsync(
                    appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    // Step 1: Free the slot first (remove booking)
                    timeSlot.MakeAvailable();

                    // Step 2: Then block it to prevent future bookings
                    timeSlot.Block();

                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                // Cancel all reminders
                await _appointmentReminderService.CancelAppointmentRemindersAsync(
                    appointmentId,
                    appointment.PatientId,
                    cancellationToken);

                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} cancelled and slot blocked by Doctor. Reason: {Reason}",
                    appointmentId, request.Reason);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error cancelling and blocking appointment {AppointmentId} by doctor", appointmentId);
                throw;
            }
        }

        public async Task<AppointmentDetailsDto?> GetAppointmentDetailsAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdWithDetailsAsync(appointmentId, cancellationToken);

            if (appointment == null)
                return null;

            return new AppointmentDetailsDto
            {
                AppointmentId = appointment.Id,
                AppointmentDate = appointment.TimeSlot.SlotDate,
                StartTime = appointment.TimeSlot.StartTime,
                EndTime = appointment.TimeSlot.EndTime,
                Status = appointment.Status,
                PatientNotes = appointment.PatientNotes,
                DoctorId = appointment.DoctorId,
                DoctorName = $"Dr. {appointment.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = appointment.PatientId,
                PatientName = $"{appointment.Patient?.User?.FullName ?? "Patient (Unknown)"}",
                MedicalRecord = appointment.MedicalRecord != null ? new AppointmentMedicalRecordDto
                {
                    Id = appointment.MedicalRecord.Id, 
                    ChiefComplaint = appointment.MedicalRecord.ChiefComplaint,
                    VitalSigns = appointment.MedicalRecord.VitalSigns,
                    PhysicalExamination = appointment.MedicalRecord.PhysicalExamination,
                    Diagnosis = appointment.MedicalRecord.Diagnosis,
                    DiagnosisCode = appointment.MedicalRecord.DiagnosisCode,
                    TreatmentPlan = appointment.MedicalRecord.TreatmentPlan,
                    DoctorNotes = appointment.MedicalRecord.DoctorNotes,
                    FollowUpRequired = appointment.MedicalRecord.FollowUpRequired,
                    FollowUpDate = appointment.MedicalRecord.FollowUpDate,
                    FollowUpInstructions = appointment.MedicalRecord.FollowUpInstructions
                } : null,
                Prescriptions = appointment.Prescriptions.Select(p => new PrescriptionDto
                {
                    PrescriptionId = p.Id,
                    PrescriptionNumber = p.PrescriptionNumber,
                    IssuedAt = p.IssuedAt,
                    Items = p.Items.Select(i => new PrescriptionItemDto
                    {
                        ItemId = i.Id, 
                        MedicationName = i.MedicationName,
                        Dosage = i.Dosage,
                        Frequency = i.Frequency,
                        Duration = i.Duration,
                        Quantity = i.Quantity,
                        Instructions = i.Instructions
                    }).ToList()
                }).ToList()
            };
        }

        public async Task<List<AppointmentDetailsDto>> GetPatientAppointmentsAsync(
            int patientId,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var appointments = await _appointmentRepository
                .GetPatientAppointmentsAsync(patientId, status, cancellationToken);

            return appointments.Select(a => new AppointmentDetailsDto
            {
                AppointmentId = a.Id,
                AppointmentDate = a.TimeSlot.SlotDate,
                StartTime = a.TimeSlot.StartTime,
                EndTime = a.TimeSlot.EndTime,
                Status = a.Status,
                PatientNotes = a.PatientNotes,
                DoctorId = a.DoctorId,
                DoctorName = $"Dr. {a.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = a.PatientId,
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}"
            }).ToList();
        }

        public async Task<List<AppointmentDetailsDto>> GetDoctorAppointmentsAsync(
            int doctorId,
            DateTime? date = null,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var appointments = await _appointmentRepository
                .GetDoctorAppointmentsAsync(doctorId, date, status, cancellationToken);

            return appointments.Select(a => new AppointmentDetailsDto
            {
                AppointmentId = a.Id,
                AppointmentDate = a.TimeSlot.SlotDate,
                StartTime = a.TimeSlot.StartTime,
                EndTime = a.TimeSlot.EndTime,
                Status = a.Status,
                PatientNotes = a.PatientNotes,
                DoctorId = a.DoctorId,
                DoctorName = $"Dr. {a.Doctor?.User?.FullName ?? "(Unknown)"}",
                PatientId = a.PatientId,
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}"
            }).ToList();
        }

        public async Task ConfirmAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            appointment.Confirm();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} confirmed", appointmentId);
        }

        public async Task StartAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            appointment.Start();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} started", appointmentId);
        }

        public async Task CompleteAppointmentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                appointment.Complete();

                // Mark time slot as completed
                var timeSlot = await _timeSlotRepository.GetByIdAsync(
                    appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    timeSlot.Complete();
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation("Appointment {AppointmentId} completed", appointmentId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex, "Error completing appointment {AppointmentId}", appointmentId);
                throw;
            }
        }

        public async Task<FollowUpResponse> BookFollowUpOnExistingSlotAsync(
            Guid originalAppointmentId,
            BookFollowUpExistingRequest request,
            int doctorId,
            CancellationToken ct = default)
        {
            await _unitOfWork.BeginTransactionAsync(ct);

            var original = await _appointmentRepository.GetByIdAsync(originalAppointmentId, ct);
            if (original == null || original.DoctorId != doctorId || original.Status != AppointmentStatus.Completed)
                throw new DomainException("Invalid follow-up operation");

            var slot = await _timeSlotRepository.GetByIdAsync(request.SlotId, ct);
            if (slot == null || slot.DoctorId != doctorId || slot.Status != SlotStatus.Available)
                throw new DomainException("Slot not available or not owned by this doctor");

            slot.Book();

            var newAppt = Appointment.Create(
                slot.Id,
                doctorId,
                original.PatientId,
                request.PatientNotes ?? $"Follow-up from appointment {originalAppointmentId}");

            newAppt.SetFollowUpFrom(originalAppointmentId);

            if (!string.IsNullOrWhiteSpace(request.FollowUpInstructions))
                newAppt.UpdatePatientNotes($"Follow-up Instructions: {request.FollowUpInstructions}");

            await _appointmentRepository.AddAsync(newAppt, ct);
            await _timeSlotRepository.UpdateAsync(slot, ct);

            await _unitOfWork.CommitTransactionAsync(ct);

            return new FollowUpResponse
            {
                NewAppointmentId = newAppt.Id,
                NewTimeSlotId = slot.Id,
                AppointmentDate = slot.SlotDate,
                StartTime = slot.StartTime,
                Message = "Follow-up booked on existing slot"
            };
        }

        public async Task<FollowUpResponse> CreateAndBookFollowUpSlotAsync(
             Guid originalAppointmentId,
             BookFollowUpNewRequest request,
             int doctorId,
             CancellationToken ct = default)
        {
            await _unitOfWork.BeginTransactionAsync(ct);

            var original = await _appointmentRepository.GetByIdAsync(originalAppointmentId, ct);
            if (original == null || original.DoctorId != doctorId || original.Status != AppointmentStatus.Completed)
                throw new DomainException("Invalid follow-up operation");

            if (!request.FollowUpDate.HasValue || !request.StartTime.HasValue)
                throw new DomainException("FollowUpDate and StartTime are required when creating new slot");

            var date = request.FollowUpDate.Value.Date;
            var start = request.StartTime.Value;
            var end = start.Add(TimeSpan.FromMinutes(request.DurationMinutes));

            // Validation: check overlap
            var existingSlots = await _timeSlotRepository.GetSlotsInDateRangeAsync(
                doctorId, date, date, ct);

            if (existingSlots.Any(s => s.StartTime < end && s.EndTime > start))
                throw new DomainException("Time overlaps with existing slot");

            // إنشاء slot جديد
            var newSlot = TimeSlot.CreateManual(doctorId, date, start, end);
            newSlot.Book();

            await _timeSlotRepository.AddAsync(newSlot, ct);

            var newAppt = Appointment.Create(
                newSlot.Id,
                doctorId,
                original.PatientId,
                request.PatientNotes ?? $"Follow-up from appointment {originalAppointmentId}");

            newAppt.SetFollowUpFrom(originalAppointmentId);

            if (!string.IsNullOrWhiteSpace(request.FollowUpInstructions))
                newAppt.UpdatePatientNotes($"Follow-up Instructions: {request.FollowUpInstructions}");

            await _appointmentRepository.AddAsync(newAppt, ct);

            await _unitOfWork.CommitTransactionAsync(ct);

            return new FollowUpResponse
            {
                NewAppointmentId = newAppt.Id,
                NewTimeSlotId = newSlot.Id,
                AppointmentDate = newSlot.SlotDate,
                StartTime = newSlot.StartTime,
                Message = "New follow-up slot created and booked"
            };
        }

        public async Task GrantMedicalHistoryAccessAsync(
            int patientId,
            Guid appointmentId,
            CancellationToken ct = default)
        {
            var appointment = await _appointmentRepository.GetByIdWithGrantsAsync(appointmentId, ct)
                ?? throw new NotFoundException("Appointment", appointmentId);

            if (appointment.PatientId != patientId)
                throw new UnauthorizedAccessException("This is not your appointment");

            // تحقق إن مفيش grant موجودة أصلاً
            var existingGrant = await _accessRepository.GetActiveGrantAsync(
                patientId, appointment.DoctorId, appointmentId, ct);

            if (existingGrant != null)
                throw new DomainException("Medical history access already granted for this appointment");

            var appointmentDateTime = appointment.TimeSlot.SlotDate.Add(appointment.TimeSlot.EndTime);
            var expiryDate = appointmentDateTime.AddHours(24);

            var grant = MedicalHistoryAccessGrant.Create(
                patientId: patientId,
                doctorId: appointment.DoctorId,
                appointmentId: appointmentId,
                grantType: GrantType.Appointment,
                expiresAt: expiryDate,
                canViewMedicalHistory: true,
                canViewPrescriptions: true,
                canViewLabResults: false);

            await _accessRepository.AddAsync(grant, ct);
            await _unitOfWork.SaveChangesAsync(ct);
        }
    }
}