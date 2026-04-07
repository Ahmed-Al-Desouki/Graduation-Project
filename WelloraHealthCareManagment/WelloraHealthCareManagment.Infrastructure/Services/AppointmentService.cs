using HealthCare_.Models.DoctorModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.DTOs.Payment;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.ValueObjects;
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
        private readonly IPaymentRepository _paymentRepository;
        private readonly IPaymentService _paymentService;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ILogger<AppointmentService> _logger;

        public AppointmentService(
            IAppointmentRepository appointmentRepository,
            ITimeSlotRepository timeSlotRepository,
            IMedicalHistoryAccessRepository accessRepository,
            IAppointmentReminderService appointmentReminderService,
            IAppointmentFactory appointmentFactory,
            IPaymentRepository paymentRepository,   
            IPaymentService paymentService,
            IUnitOfWork unitOfWork,
            ILogger<AppointmentService> logger)
        {
            _appointmentRepository = appointmentRepository;
            _timeSlotRepository = timeSlotRepository;
            _accessRepository = accessRepository;
            _appointmentReminderService = appointmentReminderService;
            _appointmentFactory = appointmentFactory;
            _paymentRepository = paymentRepository;
            _paymentService = paymentService;
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
                    throw new DomainException(
                        "This time slot has already passed and cannot be booked");

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

                // 4. Book TimeSlot
                timeSlot.Book();

                // 5. Persist Appointment & TimeSlot together
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
                        canViewLabResults: false);

                    await _accessRepository.AddAsync(accessGrant, cancellationToken);
                }

                // 7. Save everything and commit atomically
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // 8. Create Reminders AFTER commit — non-critical
                try
                {
                    await _appointmentReminderService.CreateAppointmentRemindersAsync(
                        appointment,
                        timeSlot,
                        patientId,
                        timeSlot.DoctorId,
                        cancellationToken);
                }
                catch (Exception reminderEx)
                {
                    _logger.LogWarning(reminderEx,
                        "Failed to create reminders for appointment {AppointmentId} — booking still succeeded",
                        appointment.Id);
                }

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
                _logger.LogError(ex,
                    "Error booking appointment for patient {PatientId}", patientId);
                throw;
            }
        }

        public async Task<CancellationResult> CancelByPatientAsync(
            Guid appointmentId,
            int patientId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            // Validate ownership
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            if (appointment.PatientId != patientId)
                throw new UnauthorizedAccessException(
                    "This appointment does not belong to you");

            return await ProcessCancellationAsync(
                appointment,
                cancelledBy: CancelledBy.Patient,
                reason: request.Reason,
                blockSlotAfterCancel: false,
                checkCancellationWindow: true,
                cancellationToken: cancellationToken);
        }

        public async Task<CancellationResult> CancelAndBlockByDoctorAsync(
            Guid appointmentId,
            int doctorId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
            // Validate ownership
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            if (appointment.DoctorId != doctorId)
                throw new UnauthorizedAccessException(
                    "This appointment does not belong to you");

            if (string.IsNullOrWhiteSpace(request.Reason))
                throw new DomainException(
                    "Reason is required when doctor cancels an appointment");

            return await ProcessCancellationAsync(
                appointment,
                cancelledBy: CancelledBy.Doctor,
                reason: request.Reason,
                blockSlotAfterCancel: true,
                checkCancellationWindow: false,
                cancellationToken: cancellationToken);
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

                await _unitOfWork.SaveChangesAsync(cancellationToken);
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

        // PRIVATE 
        private async Task<CancellationResult> ProcessCancellationAsync(
            Appointment appointment,
            CancelledBy cancelledBy,
            string? reason,
            bool blockSlotAfterCancel,
            bool checkCancellationWindow,
            CancellationToken cancellationToken)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "{CancelledBy} attempting to cancel appointment {AppointmentId}",
                    cancelledBy, appointment.Id);

                // 1. Validate cancellable status
                if (appointment.Status is AppointmentStatus.Completed
                    or AppointmentStatus.Cancelled
                    or AppointmentStatus.NoShow)
                {
                    return CancellationResult.Failed(
                        "Cannot cancel a completed, cancelled, or no-show appointment");
                }

                // 2. Get time slot
                var timeSlot = await _timeSlotRepository
                    .GetByIdAsync(appointment.TimeSlotId, cancellationToken);

                if (timeSlot == null)
                    return CancellationResult.Failed("Time slot not found");

                var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.StartTime);

                // 3. Process refund if payment exists
                decimal? refundAmount = null;
                decimal? refundPercentage = null;
                string? refundTransactionId = null;
                bool refundProcessed = false;

                var payment = await _paymentRepository
                    .GetByAppointmentIdAsync(appointment.Id, cancellationToken);

                if (payment != null && payment.Status == PaymentStatus.Paid)
                {
                    _logger.LogInformation(
                        "Appointment {AppointmentId} is paid. Processing refund...",
                        appointment.Id);

                    // 3.1 Check cancellation window (patient only)
                    if (checkCancellationWindow &&
                        !CancellationPolicy.CanCancelWithRefund(appointmentDateTime, payment.PaidAt))
                    {
                        await _unitOfWork.RollbackTransactionAsync(cancellationToken);

                        var remainingTime = CancellationPolicy
                            .GetRemainingCancellationWindow(appointmentDateTime);

                        return CancellationResult.Failed(
                            $"Cannot cancel. You must cancel at least " +
                            $"{CancellationPolicy.MINIMUM_CANCELLATION_HOURS} hours before the appointment. " +
                            $"Cancellation deadline was {remainingTime.TotalHours:F1} hours ago.");
                    }

                    // 3.2 Calculate refund
                    refundPercentage = cancelledBy == CancelledBy.Patient
                        ? CancellationPolicy.PATIENT_CANCELLATION_REFUND_PERCENTAGE
                        : CancellationPolicy.DOCTOR_CANCELLATION_REFUND_PERCENTAGE;

                    refundAmount = CancellationPolicy.CalculateRefundAmount(
                        payment.Amount, cancelledBy);

                    _logger.LogInformation(
                        "Refund: {Amount} EGP ({Percentage}%)",
                        refundAmount, refundPercentage);

                    // 3.3 Process refund
                    try
                    {
                        var refundRequest = new RefundPaymentRequest
                        {
                            PaymentId = payment.Id,
                            Amount = refundAmount.Value,
                            Reason = cancelledBy == CancelledBy.Patient
                                ? RefundReason.PatientCancellation
                                : RefundReason.DoctorCancellation,
                            RefundPercentage = refundPercentage,
                            Notes = $"{cancelledBy} cancelled appointment {appointment.Id}. " +
                                    $"Reason: {reason ?? "No reason provided"}"
                        };

                        var refundResponse = await _paymentService
                            .RefundPaymentAsync(refundRequest, cancellationToken);

                        if (!refundResponse.Success)
                        {
                            _logger.LogError(
                                "Refund failed for appointment {AppointmentId}: {Message}",
                                appointment.Id, refundResponse.Message);

                            await _unitOfWork.RollbackTransactionAsync(cancellationToken);

                            return CancellationResult.Failed(
                                $"Refund processing failed: {refundResponse.Message}. Please contact support.");
                        }

                        refundTransactionId = refundResponse.RefundTransactionId;
                        refundProcessed = true;

                        _logger.LogInformation(
                            "Refund processed. Transaction ID: {TransactionId}",
                            refundTransactionId);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex,
                            "Exception during refund for appointment {AppointmentId}",
                            appointment.Id);

                        await _unitOfWork.RollbackTransactionAsync(cancellationToken);

                        return CancellationResult.Failed(
                            $"Refund processing error: {ex.Message}. Please try again later.");
                    }
                }
                else if (payment != null)
                {
                    _logger.LogInformation(
                        "Appointment {AppointmentId} payment status is {Status}. No refund needed.",
                        appointment.Id, payment.Status);
                }
                else
                {
                    _logger.LogInformation(
                        "Appointment {AppointmentId} has no payment. Proceeding with cancellation only.",
                        appointment.Id);
                }

                // 4. Cancel appointment
                appointment.Cancel(cancelledBy, reason);
                appointment.ClearPatientData();

                // 5. Update time slot
                timeSlot.MakeAvailable();
                if (blockSlotAfterCancel)
                    timeSlot.Block();

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
                await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);

                // 6. Cancel reminders
                await _appointmentReminderService.CancelAppointmentRemindersAsync(
                    appointment.Id,
                    appointment.PatientId,
                    cancellationToken);

                // 7. Save and commit
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} cancelled by {CancelledBy}. Refund: {RefundProcessed}, Amount: {RefundAmount}",
                    appointment.Id, cancelledBy, refundProcessed, refundAmount);

                var message = refundProcessed
                    ? $"Appointment cancelled successfully. {refundPercentage}% refund ({refundAmount:F2} EGP) will be processed within 3-5 business days."
                    : "Appointment cancelled successfully. No refund applicable.";

                return CancellationResult.Succeeded(
                    message, refundAmount, refundPercentage, refundTransactionId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error cancelling appointment {AppointmentId}",
                    appointment.Id);
                throw;
            }
        }
    }
}