using HealthCare_.Models.DoctorModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;
using WelloraHealthCareManagment.Application.DTOs.Payment;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.DTOs.Realtime;
using WelloraHealthCareManagment.Domain.Enums;
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
        private readonly INotificationService _notificationService;
        private readonly IRealtimeService _realtimeService;
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
            INotificationService notificationService,
            IRealtimeService realtimeService,
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
            _notificationService = notificationService;
            _realtimeService = realtimeService;
            _logger = logger;
        }

        // ════════════════════════════════════════════════════════════════════
        // 1. BOOK APPOINTMENT  —  Free Flow (بدون دفع)
        // ════════════════════════════════════════════════════════════════════

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

                // 3. Create Appointment & Book Slot
                var appointment = Appointment.Create(
                    timeSlot.Id,
                    timeSlot.DoctorId,
                    patientId,
                    request.PatientNotes);

                timeSlot.Book();

                // 4. Persist Appointment & TimeSlot
                await _appointmentRepository.AddAsync(appointment, cancellationToken);
                await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);

                // ★ CRITICAL: SaveChanges هنا عشان appointment.Id (Guid) يتولد في الـ DB
                //             قبل ما نحاول نربط الـ Grant بيه
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} persisted. Creating Grant if requested.",
                    appointment.Id);

                // 5. Create Medical History Access Grant (بعد ما الـ ID اتولد فعلاً)
                if (request.GrantMedicalHistoryAccess)
                {
                    await CreateMedicalAccessGrantInternalAsync(
                        patientId: patientId,
                        appointmentId: appointment.Id,
                        doctorId: timeSlot.DoctorId,
                        timeSlot: timeSlot,
                        canViewMedicalHistory: true,
                        canViewPrescriptions: true,
                        canViewLabResults: false,
                        cancellationToken: cancellationToken);

                    // حفظ الـ Grant والـ Log معاً
                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                }

                // 6. Commit everything atomically
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // 7. Create Reminders AFTER commit — non-critical
                await TryCreateRemindersAsync(
                    appointment, timeSlot, patientId, timeSlot.DoctorId, cancellationToken);
                await SendAppointmentBookedNotificationsAsync(
                    appointment.Id,
                    patientId,
                    timeSlot.DoctorId,
                    timeSlot,
                    cancellationToken);
                await BroadcastAppointmentCreatedAsync(appointment, timeSlot, cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} booked successfully by Patient {PatientId}",
                    appointment.Id, patientId);

                return new BookAppointmentResponse
                {
                    AppointmentId = appointment.Id,
                    AppointmentDate = timeSlot.SlotDate,
                    AppointmentTime = timeSlot.StartTime,
                    DoctorName = timeSlot.Doctor.User?.FullName ?? "Dr. (Name unavailable)",
                    MedicalHistoryAccessGranted = request.GrantMedicalHistoryAccess
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

        // 2. INITIATE BOOKING WITH PAYMENT  —  يُنشئ Payment فقط ويوجّه لـ Paymob
        //    الـ Appointment والـ Grant يُنشآن لاحقاً في CompleteBookingAfterPaymentAsync

        public async Task<InitiateBookingPaymentResponse> InitiateBookingWithPaymentAsync(
            int patientId,
            BookAppointmentRequest request,
            PaymentMethod paymentMethod,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Patient {PatientId} initiating booking with payment for slot {TimeSlotId}",
                    patientId, request.TimeSlotId);

                var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                    request.TimeSlotId, cancellationToken);

                if (timeSlot == null)
                    throw new NotFoundException("TimeSlot", request.TimeSlotId);

                if (timeSlot.IsExpired())
                    throw new DomainException("This time slot has already passed and cannot be booked");

                if (timeSlot.Status != SlotStatus.Available)
                    throw new DomainException(
                        $"This time slot is no longer available. Current status: {timeSlot.Status}");

                if (timeSlot.Doctor == null)
                    throw new DomainException("Doctor information is missing");

                var existingAppointment = await _appointmentRepository
                    .GetByTimeSlotIdAsync(request.TimeSlotId, cancellationToken);

                if (existingAppointment != null)
                    throw new DomainException("This time slot is already booked");

                var createPaymentRequest = new CreatePaymentRequest
                {
                    TimeSlotId = request.TimeSlotId,
                    PatientId = patientId,
                    PaymentMethod = paymentMethod,
                    PatientNotes = request.PatientNotes,
                    GrantMedicalHistoryAccess = request.GrantMedicalHistoryAccess
                };

                var paymentResult = await _paymentService.CreatePaymentAsync(
                    createPaymentRequest,
                    patientId,
                    "Patient",
                    cancellationToken);

                _logger.LogInformation(
                    "Payment {PaymentId} initiated for slot {TimeSlotId}. Awaiting Paymob confirmation.",
                    paymentResult.PaymentId, request.TimeSlotId);

                return new InitiateBookingPaymentResponse
                {
                    PaymentId = paymentResult.PaymentId,
                    PaymentUrl = paymentResult.PaymentUrl,
                    PaymobOrderId = paymentResult.PaymobOrderId,
                    TimeSlotId = request.TimeSlotId,
                    Amount = paymentResult.Amount,
                    AppointmentDate = timeSlot.SlotDate,
                    AppointmentTime = timeSlot.StartTime,
                    DoctorName = timeSlot.Doctor.User?.FullName ?? "Dr. (Name unavailable)"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error initiating booking with payment for patient {PatientId}, slot {TimeSlotId}",
                    patientId, request.TimeSlotId);
                throw;
            }
        }

        // 3. COMPLETE BOOKING AFTER PAYMENT  —  يُستدعى من PaymentService
        //    بعد تأكيد Paymob (Webhook / Callback)
        //    ينشئ الـ Appointment + الـ Grant في نفس الـ Transaction
        public async Task<BookAppointmentResponse> CompleteBookingAfterPaymentAsync(
            Guid paymentId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                _logger.LogInformation(
                    "Completing booking for confirmed payment {PaymentId}", paymentId);

                // 1. جلب الـ Payment المؤكد
                var payment = await _paymentRepository
                    .GetByIdAsync(paymentId, cancellationToken)
                    ?? throw new NotFoundException("Payment", paymentId);

                if (payment.Status != PaymentStatus.Paid)
                    throw new DomainException(
                        $"Payment {paymentId} is not confirmed. Current status: {payment.Status}");

                // 2. Idempotency Guard
                var existingAppointment = await _appointmentRepository
                    .GetByTimeSlotIdAsync((Guid)payment.TimeSlotId, cancellationToken);

                if (existingAppointment != null)
                {
                    _logger.LogWarning(
                        "Appointment already exists for slot {TimeSlotId}. Skipping duplicate creation.",
                        payment.TimeSlotId);

                    await _unitOfWork.RollbackTransactionAsync(cancellationToken);

                    var existingSlot = await _timeSlotRepository
                        .GetByIdWithDoctorAsync((Guid)payment.TimeSlotId, cancellationToken);

                    return BuildBookingResponse(
                        existingAppointment,
                        existingSlot!,
                        payment.GrantMedicalHistoryAccess);
                }

                // 3. جلب الـ TimeSlot
                var timeSlot = await _timeSlotRepository
                    .GetByIdWithDoctorAsync((Guid)payment.TimeSlotId, cancellationToken)
                    ?? throw new NotFoundException("TimeSlot", payment.TimeSlotId);

                if (timeSlot.Status != SlotStatus.Available)
                    throw new DomainException(
                        $"Slot {payment.TimeSlotId} is no longer available after payment confirmation.");

                // 4. Create Appointment & Book Slot
                var appointment = Appointment.Create(
                    timeSlot.Id,
                    timeSlot.DoctorId,
                    payment.PatientId,
                    payment.PatientNotes);

                timeSlot.Book();
                payment.LinkToAppointment(appointment.Id);

                await _appointmentRepository.AddAsync(appointment, cancellationToken);
                await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                await _paymentRepository.UpdateAsync(payment, cancellationToken);

                // ★ SaveChanges عشان appointment.Id يتولد في الـ DB
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Appointment {AppointmentId} created for paid slot {TimeSlotId}.",
                    appointment.Id, timeSlot.Id);

                // 5. Medical History Access Grant
                if (payment.GrantMedicalHistoryAccess)
                {
                    await CreateMedicalAccessGrantInternalAsync(
                        patientId: payment.PatientId,
                        appointmentId: appointment.Id,
                        doctorId: timeSlot.DoctorId,
                        timeSlot: timeSlot,
                        canViewMedicalHistory: true,
                        canViewPrescriptions: true,
                        canViewLabResults: false,
                        cancellationToken: cancellationToken);

                    await _unitOfWork.SaveChangesAsync(cancellationToken);
                }

                // 6. Commit
                await _unitOfWork.CommitTransactionAsync(cancellationToken);

                // 7. ✅ Create Reminders AFTER commit — non-critical
                await TryCreateRemindersAsync(
                    appointment, timeSlot, payment.PatientId, timeSlot.DoctorId, cancellationToken);
                await SendAppointmentBookedNotificationsAsync(
                    appointment.Id,
                    payment.PatientId,
                    timeSlot.DoctorId,
                    timeSlot,
                    cancellationToken);
                await BroadcastAppointmentCreatedAsync(appointment, timeSlot, cancellationToken);

                _logger.LogInformation(
                    "Booking completed: Appointment {AppointmentId}, Payment {PaymentId}",
                    appointment.Id, paymentId);

                return BuildBookingResponse(
                    appointment,
                    timeSlot,
                    payment.GrantMedicalHistoryAccess);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error completing booking after payment {PaymentId}", paymentId);
                throw;
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // 4. CANCEL BY PATIENT
        // ════════════════════════════════════════════════════════════════════

        public async Task<CancellationResult> CancelByPatientAsync(
            Guid appointmentId,
            int patientId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
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

        // ════════════════════════════════════════════════════════════════════
        // 5. CANCEL AND BLOCK BY DOCTOR
        // ════════════════════════════════════════════════════════════════════

        public async Task<CancellationResult> CancelAndBlockByDoctorAsync(
            Guid appointmentId,
            int doctorId,
            CancelAppointmentRequest request,
            CancellationToken cancellationToken = default)
        {
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

        // ════════════════════════════════════════════════════════════════════
        // 6. GET APPOINTMENT DETAILS
        // ════════════════════════════════════════════════════════════════════

        public async Task<AppointmentDetailsDto?> GetAppointmentDetailsAsync(
            Guid appointmentId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdWithDetailsAsync(appointmentId, cancellationToken);

            if (appointment == null)
                return null;

            EnsureCanAccessAppointment(appointment, requesterUserId, requesterRole);

            var activeGrant = await _accessRepository
                .GetActiveAppointmentGrantAsync(appointmentId, cancellationToken);

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
                CanViewMedicalHistory = activeGrant?.CanViewMedicalHistory ?? false,
                CanViewPrescriptions = activeGrant?.CanViewPrescriptions ?? false,
                CanViewLabResults = activeGrant?.CanViewLabResults ?? false,
                CancelledBy = appointment.Status == AppointmentStatus.Cancelled
                    ? appointment.CancelledBy
                    : null,
                     CancellationReason = appointment.Status == AppointmentStatus.Cancelled
                    ? appointment.CancellationReason
                    : null,
                MedicalRecord = appointment.MedicalRecord != null
                    ? new AppointmentMedicalRecordDto
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
                    }
                    : null,
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

        // 7. GET PATIENT APPOINTMENTS
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
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}",
                CancelledBy = a.Status == AppointmentStatus.Cancelled
                    ? a.CancelledBy
                    : null,
                     CancellationReason = a.Status == AppointmentStatus.Cancelled
                    ? a.CancellationReason
                    : null,
                MedicalRecord = a.MedicalRecord == null ? null : new AppointmentMedicalRecordDto
                {
                    Id = a.MedicalRecord.Id,
                    ChiefComplaint = a.MedicalRecord.ChiefComplaint,
                    VitalSigns = a.MedicalRecord.VitalSigns,
                    PhysicalExamination = a.MedicalRecord.PhysicalExamination,
                    Diagnosis = a.MedicalRecord.Diagnosis,
                    DiagnosisCode = a.MedicalRecord.DiagnosisCode,
                    TreatmentPlan = a.MedicalRecord.TreatmentPlan,
                    DoctorNotes = a.MedicalRecord.DoctorNotes,
                    FollowUpRequired = a.MedicalRecord.FollowUpRequired,
                    FollowUpDate = a.MedicalRecord.FollowUpDate,
                    FollowUpInstructions = a.MedicalRecord.FollowUpInstructions
                },
                Prescriptions = a.Prescriptions.Select(p => new PrescriptionDto
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
            }).ToList();
        }

        // ════════════════════════════════════════════════════════════════════
        // 8. GET DOCTOR APPOINTMENTS
        // ════════════════════════════════════════════════════════════════════

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
                PatientName = $"{a.Patient?.User?.FullName ?? "Patient (Unknown)"}",
                MedicalRecord = a.MedicalRecord == null ? null : new AppointmentMedicalRecordDto
                {
                    Id = a.MedicalRecord.Id,
                    ChiefComplaint = a.MedicalRecord.ChiefComplaint,
                    VitalSigns = a.MedicalRecord.VitalSigns,
                    PhysicalExamination = a.MedicalRecord.PhysicalExamination,
                    Diagnosis = a.MedicalRecord.Diagnosis,
                    DiagnosisCode = a.MedicalRecord.DiagnosisCode,
                    TreatmentPlan = a.MedicalRecord.TreatmentPlan,
                    DoctorNotes = a.MedicalRecord.DoctorNotes,
                    FollowUpRequired = a.MedicalRecord.FollowUpRequired,
                    FollowUpDate = a.MedicalRecord.FollowUpDate,
                    FollowUpInstructions = a.MedicalRecord.FollowUpInstructions
                },
                Prescriptions = a.Prescriptions.Select(p => new PrescriptionDto
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
            }).ToList();
        }

        // ════════════════════════════════════════════════════════════════════
        // 9. CONFIRM APPOINTMENT
        // ════════════════════════════════════════════════════════════════════

        public async Task ConfirmAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            if (appointment.DoctorId != doctorId)
                throw new UnauthorizedAccessException("This appointment does not belong to you.");

            appointment.Confirm();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            await BroadcastAppointmentUpdatedAsync(appointment, cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} confirmed", appointmentId);
        }

        // ════════════════════════════════════════════════════════════════════
        // 10. START APPOINTMENT
        // ════════════════════════════════════════════════════════════════════

        public async Task StartAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdAsync(appointmentId, cancellationToken);

            if (appointment == null)
                throw new NotFoundException("Appointment", appointmentId);

            if (appointment.DoctorId != doctorId)
                throw new UnauthorizedAccessException("This appointment does not belong to you.");

            appointment.Start();

            await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            await BroadcastAppointmentUpdatedAsync(appointment, cancellationToken);

            _logger.LogInformation("Appointment {AppointmentId} started", appointmentId);
        }

        // ════════════════════════════════════════════════════════════════════
        // 11. COMPLETE APPOINTMENT
        // ════════════════════════════════════════════════════════════════════

        public async Task CompleteAppointmentAsync(
            Guid appointmentId,
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                var appointment = await _appointmentRepository
                    .GetByIdAsync(appointmentId, cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", appointmentId);

                if (appointment.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("This appointment does not belong to you.");

                appointment.Complete();

                // Mark time slot as completed
                var timeSlot = await _timeSlotRepository
                    .GetByIdAsync(appointment.TimeSlotId, cancellationToken);

                if (timeSlot != null)
                {
                    timeSlot.Complete();
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                }

                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);

                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _unitOfWork.CommitTransactionAsync(cancellationToken);
                await _notificationService.NotifyAsync(new NotificationDispatchRequest
                {
                    UserId = appointment.PatientId,
                    Title = "Appointment Completed",
                    Message = "Your appointment is completed. Share your feedback and review your doctor.",
                    Type = NotificationType.ReviewRequested,
                    RelatedEntityType = "Appointment",
                    Data = new Dictionary<string, string>
                    {
                        ["appointmentId"] = appointment.Id.ToString(),
                        ["doctorId"] = appointment.DoctorId.ToString()
                    }
                }, cancellationToken);
                await BroadcastAppointmentUpdatedAsync(appointment, cancellationToken);

                if (timeSlot != null)
                {
                    await BroadcastSlotUpdatedAsync(timeSlot, appointment.Id, cancellationToken);
                }

                _logger.LogInformation("Appointment {AppointmentId} completed", appointmentId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error completing appointment {AppointmentId}", appointmentId);
                throw;
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // 12. BOOK FOLLOW-UP ON EXISTING SLOT
        // ════════════════════════════════════════════════════════════════════

        public async Task<FollowUpResponse> BookFollowUpOnExistingSlotAsync(
             Guid originalAppointmentId,
             BookFollowUpExistingRequest request,
             int doctorId,
             CancellationToken ct = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(ct);

                var original = await _appointmentRepository
                    .GetByIdWithDetailsAsync(originalAppointmentId, ct);

                if (original == null)
                    throw new DomainException("Original appointment not found");

                if (original.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("This appointment does not belong to you");

                if (original.Status != AppointmentStatus.Completed)
                    throw new DomainException("Original appointment must be completed to create a follow-up");

                var slot = await _timeSlotRepository.GetByIdAsync(request.SlotId, ct);

                if (slot == null)
                    throw new DomainException("Slot not found");

                if (slot.DoctorId != doctorId)
                    throw new DomainException("Slot does not belong to this doctor");

                if (slot.Status != SlotStatus.Available)
                    throw new DomainException("Slot is not available");

                // Book الـ slot
                slot.Book();
                await _timeSlotRepository.UpdateAsync(slot, ct);

                // إنشاء الـ appointment
                var newAppt = Appointment.Create(
                    slot.Id,
                    doctorId,
                    original.PatientId,
                    request.PatientNotes ?? $"Follow-up from appointment {originalAppointmentId}");

                newAppt.SetFollowUpFrom(originalAppointmentId);

                if (!string.IsNullOrWhiteSpace(request.FollowUpInstructions))
                    newAppt.UpdatePatientNotes(
                        $"Follow-up Instructions: {request.FollowUpInstructions}");

                await _appointmentRepository.AddAsync(newAppt, ct);

                // SaveChanges قبل الـ Commit
                await _unitOfWork.SaveChangesAsync(ct);
                await _unitOfWork.CommitTransactionAsync(ct);
                await BroadcastAppointmentCreatedAsync(newAppt, slot, ct);

                return new FollowUpResponse
                {
                    NewAppointmentId = newAppt.Id,
                    NewTimeSlotId = slot.Id,
                    AppointmentDate = slot.SlotDate,
                    StartTime = slot.StartTime,
                    Message = "Follow-up booked successfully on existing slot"
                };
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(ct);
                _logger.LogError(ex,
                    "Error booking follow-up on existing slot for appointment {AppointmentId}",
                    originalAppointmentId);
                throw;
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // 13. CREATE AND BOOK FOLLOW-UP SLOT (new slot)
        // ════════════════════════════════════════════════════════════════════

        public async Task<FollowUpResponse> CreateAndBookFollowUpSlotAsync(
             Guid originalAppointmentId,
             BookFollowUpNewRequest request,
             int doctorId,
             CancellationToken ct = default)
        {
            try
            {
                await _unitOfWork.BeginTransactionAsync(ct);

                var original = await _appointmentRepository
                    .GetByIdWithDetailsAsync(originalAppointmentId, ct);

                if (original == null)
                    throw new DomainException("Original appointment not found");

                if (original.DoctorId != doctorId)
                    throw new UnauthorizedAccessException("This appointment does not belong to you");

                if (original.Status != AppointmentStatus.Completed)
                    throw new DomainException("Original appointment must be completed to create a follow-up");

                if (!request.FollowUpDate.HasValue || !request.StartTime.HasValue)
                    throw new DomainException("FollowUpDate and StartTime are required");

                var date = request.FollowUpDate.Value.Date;
                var start = request.StartTime.Value;
                var end = start.Add(TimeSpan.FromMinutes(request.DurationMinutes));

                // Validate no overlap
                var existingSlots = await _timeSlotRepository
                    .GetSlotsInDateRangeAsync(doctorId, date, date, ct);

                if (existingSlots.Any(s => s.StartTime < end && s.EndTime > start))
                    throw new DomainException("Time overlaps with an existing slot");

                // إنشاء الـ slot الجديد
                var newSlot = TimeSlot.CreateManual(doctorId, date, start, end);
                newSlot.Book();
                await _timeSlotRepository.AddAsync(newSlot, ct);

                // SaveChanges عشان الـ slot ID يتولد قبل ما نربطه بالـ appointment
                await _unitOfWork.SaveChangesAsync(ct);

                // إنشاء الـ appointment
                var newAppt = Appointment.Create(
                    newSlot.Id,
                    doctorId,
                    original.PatientId,
                    request.PatientNotes ?? $"Follow-up from appointment {originalAppointmentId}");

                newAppt.SetFollowUpFrom(originalAppointmentId);

                if (!string.IsNullOrWhiteSpace(request.FollowUpInstructions))
                    newAppt.UpdatePatientNotes(
                        $"Follow-up Instructions: {request.FollowUpInstructions}");

                await _appointmentRepository.AddAsync(newAppt, ct);

                await _unitOfWork.SaveChangesAsync(ct);
                await _unitOfWork.CommitTransactionAsync(ct);
                await BroadcastAppointmentCreatedAsync(newAppt, newSlot, ct);

                return new FollowUpResponse
                {
                    NewAppointmentId = newAppt.Id,
                    NewTimeSlotId = newSlot.Id,
                    AppointmentDate = newSlot.SlotDate,
                    StartTime = newSlot.StartTime,
                    Message = "New follow-up slot created and booked successfully"
                };
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(ct);
                _logger.LogError(ex,
                    "Error creating follow-up slot for appointment {AppointmentId}",
                    originalAppointmentId);
                throw;
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // 14. TOGGLE MEDICAL HISTORY ACCESS  —  Manual (Post-Booking only)
        //     لا تستخدم هذه الـ method أثناء الحجز — استخدم CreateMedicalAccessGrantInternalAsync
        // ════════════════════════════════════════════════════════════════════

        public async Task ToggleMedicalHistoryAccessAsync(
            int patientId,
            Guid? appointmentId,
            ToggleMedicalAccessRequest request,
            CancellationToken ct = default)
        {
            // Guard: appointmentId مطلوب دايماً في الـ Manual Toggle
            if (!appointmentId.HasValue)
                throw new DomainException("Appointment ID is required for access management");

            // 1. Validate Appointment & ownership
            var appointment = await _appointmentRepository
                .GetByIdWithGrantsAsync(appointmentId.Value, ct)
                ?? throw new NotFoundException("Appointment", appointmentId.Value);

            if (appointment.PatientId != patientId)
                throw new UnauthorizedAccessException("This is not your appointment");

            // 2. Get existing active grant
            var existingGrant = await _accessRepository
                .GetActiveAppointmentGrantAsync(appointmentId.Value, ct);
            var medicalAccessChangeType = "Updated";
            Guid? accessGrantId = existingGrant?.Id;
            DateTime? accessGrantExpiresAt = existingGrant?.ExpiresAt;
            var canViewMedicalHistory = request.CanViewMedicalHistory;
            var canViewPrescriptions = request.CanViewPrescriptions;
            var canViewLabResults = request.CanViewLabResults;

            if (existingGrant == null)
            {
                // ── A. لا يوجد grant → إنشاء جديد
                if (request.RevokeAll)
                    throw new DomainException("Cannot revoke access that does not exist");

                if (!request.CanViewMedicalHistory
                    && !request.CanViewPrescriptions
                    && !request.CanViewLabResults)
                    throw new DomainException(
                        "At least one permission must be enabled when creating a grant");

                await CreateMedicalAccessGrantInternalAsync(
                    patientId: patientId,
                    appointmentId: appointmentId.Value,
                    doctorId: appointment.DoctorId,
                    timeSlot: appointment.TimeSlot,
                    canViewMedicalHistory: request.CanViewMedicalHistory,
                    canViewPrescriptions: request.CanViewPrescriptions,
                    canViewLabResults: request.CanViewLabResults,
                    cancellationToken: ct);
                medicalAccessChangeType = "Granted";
            }
            else
            {
                // ── B. Grant موجود
                bool shouldRevoke = request.RevokeAll
                    || (!request.CanViewMedicalHistory
                        && !request.CanViewPrescriptions
                        && !request.CanViewLabResults);

                if (shouldRevoke)
                {
                    // B1. Revoke all
                    await _accessRepository.RevokeGrantAsync(
                        existingGrant.Id,
                        "Patient revoked all permissions",
                        patientId, ct);

                    await LogAccessActionAsync(
                        existingGrant.Id, patientId, appointment.DoctorId,
                        "AccessFullyRevoked", "Patient disabled all permissions", ct);

                    await NotifyDoctorAboutMedicalAccessChangeAsync(
                        doctorId: appointment.DoctorId,
                        patientId: patientId,
                        appointmentId: appointment.Id,
                        type: NotificationType.MedicalHistoryAccessRevoked,
                        title: "Medical History Access Revoked",
                        message: "The patient revoked your access to their medical history for this appointment.",
                        accessGrantId: existingGrant.Id,
                        expiresAt: existingGrant.ExpiresAt,
                        canViewMedicalHistory: false,
                        canViewPrescriptions: false,
                        canViewLabResults: false,
                        ct: ct);

                    _logger.LogInformation(
                        "Medical access grant {GrantId} revoked for appointment {AppointmentId}",
                        existingGrant.Id, appointmentId);
                    medicalAccessChangeType = "Revoked";
                    canViewMedicalHistory = false;
                    canViewPrescriptions = false;
                    canViewLabResults = false;
                }
                else
                {
                    // B2. Update permissions
                    if (!existingGrant.IsActive())
                        throw new DomainException(
                            "Access grant is revoked or expired. " +
                            "Use the grant endpoint to create a new one.");

                    existingGrant.UpdatePermissions(
                        request.CanViewMedicalHistory,
                        request.CanViewPrescriptions,
                        request.CanViewLabResults);

                    await LogAccessActionAsync(
                        existingGrant.Id, patientId, appointment.DoctorId,
                        "PermissionsUpdated", "Medical access permissions updated", ct);

                    await NotifyDoctorAboutMedicalAccessChangeAsync(
                        doctorId: appointment.DoctorId,
                        patientId: patientId,
                        appointmentId: appointment.Id,
                        type: NotificationType.MedicalHistoryAccessUpdated,
                        title: "Medical History Access Updated",
                        message: "The patient updated your medical history access permissions.",
                        accessGrantId: existingGrant.Id,
                        expiresAt: existingGrant.ExpiresAt,
                        canViewMedicalHistory: request.CanViewMedicalHistory,
                        canViewPrescriptions: request.CanViewPrescriptions,
                        canViewLabResults: request.CanViewLabResults,
                        ct: ct);

                    _logger.LogInformation(
                        "Permissions updated for grant {GrantId}, appointment {AppointmentId}",
                        existingGrant.Id, appointmentId);
                    medicalAccessChangeType = "Updated";
                    accessGrantExpiresAt = existingGrant.ExpiresAt;
                }
            }

            await _unitOfWork.SaveChangesAsync(ct);
            await BroadcastMedicalAccessChangedAsync(
                new MedicalAccessRealtimeDto
                {
                    AppointmentId = appointment.Id,
                    DoctorId = appointment.DoctorId,
                    PatientId = patientId,
                    AccessGrantId = accessGrantId,
                    ChangeType = medicalAccessChangeType,
                    CanViewMedicalHistory = canViewMedicalHistory,
                    CanViewPrescriptions = canViewPrescriptions,
                    CanViewLabResults = canViewLabResults,
                    ExpiresAt = accessGrantExpiresAt
                },
                ct);
        }

        // ════════════════════════════════════════════════════════════════════
        // 15. EXTEND MEDICAL ACCESS EXPIRY
        // ════════════════════════════════════════════════════════════════════

        public async Task ExtendMedicalAccessExpiryAsync(
            int patientId,
            Guid appointmentId,
            ExtendAccessRequest request,
            CancellationToken ct = default)
        {
            var appointment = await _appointmentRepository
                .GetByIdWithGrantsAsync(appointmentId, ct)
                ?? throw new NotFoundException("Appointment", appointmentId);

            if (appointment.PatientId != patientId)
                throw new UnauthorizedAccessException("This is not your appointment");

            var grant = await _accessRepository
                .GetActiveAppointmentGrantAsync(appointmentId, ct);

            if (grant == null)
                throw new DomainException(
                    "No active access grant found for this appointment");

            if (!grant.IsActive())
                throw new DomainException(
                    "Cannot extend a revoked or expired grant");

            await _accessRepository
                .ExtendExpiryAsync(grant.Id, request.NewExpiryDate, patientId, ct);

            await LogAccessActionAsync(
                grant.Id, patientId, appointment.DoctorId,
                "ExpiryExtended",
                $"Expiry extended to {request.NewExpiryDate}", ct);

            await NotifyDoctorAboutMedicalAccessChangeAsync(
                doctorId: appointment.DoctorId,
                patientId: patientId,
                appointmentId: appointment.Id,
                type: NotificationType.MedicalHistoryAccessExtended,
                title: "Medical History Access Extended",
                message: "The patient extended your medical history access period.",
                accessGrantId: grant.Id,
                expiresAt: request.NewExpiryDate,
                canViewMedicalHistory: grant.CanViewMedicalHistory,
                canViewPrescriptions: grant.CanViewPrescriptions,
                canViewLabResults: grant.CanViewLabResults,
                ct: ct);

            await _unitOfWork.SaveChangesAsync(ct);
            await BroadcastMedicalAccessChangedAsync(
                new MedicalAccessRealtimeDto
                {
                    AppointmentId = appointment.Id,
                    DoctorId = appointment.DoctorId,
                    PatientId = patientId,
                    AccessGrantId = grant.Id,
                    ChangeType = "ExpiryExtended",
                    CanViewMedicalHistory = grant.CanViewMedicalHistory,
                    CanViewPrescriptions = grant.CanViewPrescriptions,
                    CanViewLabResults = grant.CanViewLabResults,
                    ExpiresAt = request.NewExpiryDate
                },
                ct);
        }

        // ════════════════════════════════════════════════════════════════════
        // PRIVATE — PROCESS CANCELLATION
        // ════════════════════════════════════════════════════════════════════

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
                        !CancellationPolicy.CanCancelWithRefund(
                            appointmentDateTime, payment.PaidAt))
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
                            .RefundPaymentAsync(
                                refundRequest,
                                cancelledBy == CancelledBy.Patient ? appointment.PatientId : appointment.DoctorId,
                                cancelledBy == CancelledBy.Patient ? "Patient" : "Doctor",
                                cancellationToken);

                        if (!refundResponse.Success)
                        {
                            _logger.LogError(
                                "Refund failed for appointment {AppointmentId}: {Message}",
                                appointment.Id, refundResponse.Message);

                            await _unitOfWork.RollbackTransactionAsync(cancellationToken);

                            return CancellationResult.Failed(
                                $"Refund processing failed: {refundResponse.Message}. " +
                                $"Please contact support.");
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
                    "Appointment {AppointmentId} cancelled by {CancelledBy}. " +
                    "Refund: {RefundProcessed}, Amount: {RefundAmount}",
                    appointment.Id, cancelledBy, refundProcessed, refundAmount);

                await SendAppointmentCancellationNotificationsAsync(
                    appointment,
                    cancelledBy,
                    reason,
                    refundAmount,
                    cancellationToken);
                await BroadcastAppointmentCancelledAsync(appointment, timeSlot, cancellationToken);

                var message = refundProcessed
                    ? $"Appointment cancelled successfully. " +
                      $"{refundPercentage}% refund ({refundAmount:F2} EGP) " +
                      $"will be processed within 3-5 business days."
                    : "Appointment cancelled successfully. No refund applicable.";

                return CancellationResult.Succeeded(
                    message, refundAmount, refundPercentage, refundTransactionId);
            }
            catch (Exception ex)
            {
                await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                _logger.LogError(ex,
                    "Error cancelling appointment {AppointmentId}", appointment.Id);
                throw;
            }
        }

        // ════════════════════════════════════════════════════════════════════
        // PRIVATE — SINGLE SOURCE OF TRUTH لإنشاء الـ Grant
        //
        //  يُستخدم من:
        //    • BookAppointmentAsync              (Free Flow)
        //    • CompleteBookingAfterPaymentAsync  (Paid Flow)
        //    • ToggleMedicalHistoryAccessAsync   (Manual Toggle — create case)
        //
        //   لا يستدعي SaveChanges — المُستدعي هو المسؤول عن الحفظ
        // ════════════════════════════════════════════════════════════════════

        private async Task CreateMedicalAccessGrantInternalAsync(
            int patientId,
            Guid appointmentId,
            int doctorId,
            TimeSlot timeSlot,
            bool canViewMedicalHistory,
            bool canViewPrescriptions,
            bool canViewLabResults,
            CancellationToken cancellationToken)
        {
            // Expiry = نهاية الموعد + 24 ساعة
            var appointmentEndDateTime = timeSlot.SlotDate.Add(timeSlot.EndTime);
            var expiresAt = appointmentEndDateTime.AddHours(24);

            var grant = MedicalHistoryAccessGrant.Create(
                patientId: patientId,
                doctorId: doctorId,
                appointmentId: appointmentId,
                grantType: GrantType.Appointment,
                expiresAt: expiresAt,
                canViewMedicalHistory: canViewMedicalHistory,
                canViewPrescriptions: canViewPrescriptions,
                canViewLabResults: canViewLabResults);

            await _accessRepository.AddAsync(grant, cancellationToken);

            await LogAccessActionAsync(
                grant.Id, patientId, doctorId,
                "AccessGranted",
                "Medical access grant created",
                cancellationToken);

            await NotifyDoctorAboutMedicalAccessChangeAsync(
                doctorId: doctorId,
                patientId: patientId,
                appointmentId: appointmentId,
                type: NotificationType.MedicalHistoryAccessGranted,
                title: "Medical History Access Granted",
                message: "The patient granted you access to their medical history for this appointment.",
                accessGrantId: grant.Id,
                expiresAt: expiresAt,
                canViewMedicalHistory: canViewMedicalHistory,
                canViewPrescriptions: canViewPrescriptions,
                canViewLabResults: canViewLabResults,
                ct: cancellationToken);

            _logger.LogInformation(
                "Medical access grant {GrantId} created for appointment {AppointmentId}, " +
                "expires {ExpiresAt}",
                grant.Id, appointmentId, expiresAt);
        }

        private async Task NotifyDoctorAboutMedicalAccessChangeAsync(
            int doctorId,
            int patientId,
            Guid appointmentId,
            NotificationType type,
            string title,
            string message,
            Guid accessGrantId,
            DateTime? expiresAt,
            bool canViewMedicalHistory,
            bool canViewPrescriptions,
            bool canViewLabResults,
            CancellationToken ct)
        {
            var data = new Dictionary<string, string>
            {
                ["appointmentId"] = appointmentId.ToString(),
                ["doctorId"] = doctorId.ToString(),
                ["patientId"] = patientId.ToString(),
                ["accessGrantId"] = accessGrantId.ToString(),
                ["canViewMedicalHistory"] = canViewMedicalHistory.ToString(),
                ["canViewPrescriptions"] = canViewPrescriptions.ToString(),
                ["canViewLabResults"] = canViewLabResults.ToString()
            };

            if (expiresAt.HasValue)
            {
                data["expiresAt"] = expiresAt.Value.ToString("O");
            }

            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = doctorId,
                Title = title,
                Message = message,
                Type = type,
                RelatedEntityType = "Appointment",
                Data = data
            }, ct);
        }

        // ════════════════════════════════════════════════════════════════════
        // PRIVATE — TRY CREATE REMINDERS  (non-critical, after commit)
        // ════════════════════════════════════════════════════════════════════

        private async Task TryCreateRemindersAsync(
            Appointment appointment,
            TimeSlot timeSlot,
            int patientId,
            int doctorId,
            CancellationToken cancellationToken)
        {
            try
            {
                await _appointmentReminderService.CreateAppointmentRemindersAsync(
                    appointment, timeSlot, patientId, doctorId, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex,
                    "Non-critical: Failed to create reminders for appointment {AppointmentId} " +
                    "— booking still succeeded",
                    appointment.Id);
            }
        }

        private async Task SendAppointmentBookedNotificationsAsync(
            Guid appointmentId,
            int patientId,
            int doctorId,
            TimeSlot timeSlot,
            CancellationToken cancellationToken)
        {
            var appointmentDateTime = timeSlot.SlotDate.Add(timeSlot.StartTime);
            var formattedDate = appointmentDateTime.ToString("yyyy-MM-dd HH:mm");

            await _notificationService.NotifyManyAsync(new[]
            {
                new NotificationDispatchRequest
                {
                    UserId = patientId,
                    Title = "Appointment Booked",
                    Message = $"Your appointment has been booked for {formattedDate}.",
                    Type = NotificationType.AppointmentBooked,
                    RelatedEntityType = "Appointment",
                    Data = new Dictionary<string, string> { ["appointmentId"] = appointmentId.ToString() }
                },
                new NotificationDispatchRequest
                {
                    UserId = doctorId,
                    Title = "New Appointment",
                    Message = $"A patient booked an appointment for {formattedDate}.",
                    Type = NotificationType.AppointmentBooked,
                    RelatedEntityType = "Appointment",
                    Data = new Dictionary<string, string> { ["appointmentId"] = appointmentId.ToString() }
                }
            }, cancellationToken);
        }

        private async Task SendAppointmentCancellationNotificationsAsync(
            Appointment appointment,
            CancelledBy cancelledBy,
            string? reason,
            decimal? refundAmount,
            CancellationToken cancellationToken)
        {
            var patientType = cancelledBy == CancelledBy.Patient
                ? NotificationType.AppointmentCancelledByPatient
                : NotificationType.AppointmentCancelledByDoctor;

            var doctorType = cancelledBy == CancelledBy.Patient
                ? NotificationType.AppointmentCancelledByPatient
                : NotificationType.AppointmentCancelledByDoctor;

            var actorLabel = cancelledBy == CancelledBy.Patient ? "patient" : "doctor";
            var refundSuffix = refundAmount.HasValue ? $" Refund amount: {refundAmount:F2} EGP." : string.Empty;
            var reasonSuffix = string.IsNullOrWhiteSpace(reason) ? string.Empty : $" Reason: {reason}.";

            await _notificationService.NotifyManyAsync(new[]
            {
                new NotificationDispatchRequest
                {
                    UserId = appointment.PatientId,
                    Title = "Appointment Cancelled",
                    Message = cancelledBy == CancelledBy.Patient
                        ? $"Your appointment has been cancelled successfully.{reasonSuffix}{refundSuffix}"
                        : $"Your doctor cancelled the appointment.{reasonSuffix}{refundSuffix}",
                    Type = patientType,
                    RelatedEntityType = "Appointment",
                    Data = new Dictionary<string, string>
                    {
                        ["appointmentId"] = appointment.Id.ToString(),
                        ["cancelledBy"] = actorLabel
                    }
                },
                new NotificationDispatchRequest
                {
                    UserId = appointment.DoctorId,
                    Title = "Appointment Cancelled",
                    Message = cancelledBy == CancelledBy.Patient
                        ? $"A patient cancelled the appointment.{reasonSuffix}"
                        : $"You cancelled the appointment successfully.{reasonSuffix}",
                    Type = doctorType,
                    RelatedEntityType = "Appointment",
                    Data = new Dictionary<string, string>
                    {
                        ["appointmentId"] = appointment.Id.ToString(),
                        ["cancelledBy"] = actorLabel
                    }
                }
            }, cancellationToken);
        }

        private async Task BroadcastAppointmentCreatedAsync(
            Appointment appointment,
            TimeSlot timeSlot,
            CancellationToken ct)
        {
            var payload = MapAppointmentRealtimeDto(appointment);
            var userIds = new[] { appointment.PatientId, appointment.DoctorId };

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "appointment",
                appointment.Id.ToString("D"),
                "AppointmentCreated",
                payload,
                ct);

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "booking",
                appointment.Id.ToString("D"),
                "BookingCreated",
                payload,
                ct);

            await BroadcastSlotUpdatedAsync(timeSlot, appointment.Id, ct);
        }

        private async Task BroadcastAppointmentUpdatedAsync(
            Appointment appointment,
            CancellationToken ct)
        {
            var payload = MapAppointmentRealtimeDto(appointment);
            var userIds = new[] { appointment.PatientId, appointment.DoctorId };

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "appointment",
                appointment.Id.ToString("D"),
                "AppointmentUpdated",
                payload,
                ct);

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "booking",
                appointment.Id.ToString("D"),
                "BookingUpdated",
                payload,
                ct);
        }

        private async Task BroadcastAppointmentCancelledAsync(
            Appointment appointment,
            TimeSlot timeSlot,
            CancellationToken ct)
        {
            var payload = MapAppointmentRealtimeDto(appointment);
            var userIds = new[] { appointment.PatientId, appointment.DoctorId };

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "appointment",
                appointment.Id.ToString("D"),
                "AppointmentCancelled",
                payload,
                ct);

            await _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                userIds,
                "booking",
                appointment.Id.ToString("D"),
                "BookingUpdated",
                payload,
                ct);

            await BroadcastSlotUpdatedAsync(timeSlot, appointment.Id, ct);
        }

        private Task BroadcastSlotUpdatedAsync(
            TimeSlot timeSlot,
            Guid? appointmentId,
            CancellationToken ct)
        {
            var payload = new SlotRealtimeDto
            {
                SlotId = timeSlot.Id,
                DoctorId = timeSlot.DoctorId,
                AppointmentId = appointmentId,
                Status = timeSlot.Status,
                SlotDate = timeSlot.SlotDate,
                StartTime = timeSlot.StartTime,
                EndTime = timeSlot.EndTime,
                IsManuallyCreated = timeSlot.IsManuallyCreated,
                UpdatedAt = timeSlot.UpdatedAt
            };

            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { timeSlot.DoctorId },
                "timeslot",
                timeSlot.Id.ToString("D"),
                "SlotUpdated",
                payload,
                ct);
        }

        private Task BroadcastMedicalAccessChangedAsync(
            MedicalAccessRealtimeDto payload,
            CancellationToken ct)
        {
            return _realtimeService.BroadcastToUsersAdminsAndEntityAsync(
                new[] { payload.PatientId, payload.DoctorId },
                "appointment",
                payload.AppointmentId.ToString("D"),
                "MedicalAccessUpdated",
                payload,
                ct);
        }

        private static AppointmentRealtimeDto MapAppointmentRealtimeDto(Appointment appointment)
        {
            return new AppointmentRealtimeDto
            {
                AppointmentId = appointment.Id,
                TimeSlotId = appointment.TimeSlotId,
                DoctorId = appointment.DoctorId,
                PatientId = appointment.PatientId,
                Status = appointment.Status,
                IsPaid = appointment.IsPaid,
                CancellationReason = appointment.CancellationReason,
                BookedAt = appointment.BookedAt,
                ConfirmedAt = appointment.ConfirmedAt,
                StartedAt = appointment.StartedAt,
                CompletedAt = appointment.CompletedAt,
                CancelledAt = appointment.CancelledAt
            };
        }

        // ════════════════════════════════════════════════════════════════════
        // PRIVATE — BUILD BOOKING RESPONSE
        // ════════════════════════════════════════════════════════════════════

        private static BookAppointmentResponse BuildBookingResponse(
            Appointment appointment,
            TimeSlot timeSlot,
            bool medicalHistoryAccessGranted) => new()
            {
                AppointmentId = appointment.Id,
                AppointmentDate = timeSlot.SlotDate,
                AppointmentTime = timeSlot.StartTime,
                DoctorName = timeSlot.Doctor?.User?.FullName ?? "Dr. (Name unavailable)",
                MedicalHistoryAccessGranted = medicalHistoryAccessGranted
            };

        // ════════════════════════════════════════════════════════════════════
        // PRIVATE — LOG ACCESS ACTION
        // ════════════════════════════════════════════════════════════════════

        private async Task LogAccessActionAsync(
            Guid grantId, int patientId, int doctorId,
            string actionType, string description,
            CancellationToken ct = default)
        {
            var log = MedicalHistoryAccessLog.Create(
                accessGrantId: grantId,
                doctorId: doctorId,
                patientId: patientId,
                accessType: actionType,
                resourceAccessed: description);

            await _accessRepository.AddLogAsync(log, ct);
        }

        private static void EnsureCanAccessAppointment(
            Appointment appointment,
            int requesterUserId,
            string requesterRole)
        {
            if (string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase))
                return;

            if (string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase)
                && appointment.DoctorId == requesterUserId)
                return;

            if (string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase)
                && appointment.PatientId == requesterUserId)
                return;

            throw new UnauthorizedAccessException("You are not allowed to access this appointment.");
        }
    }
}
