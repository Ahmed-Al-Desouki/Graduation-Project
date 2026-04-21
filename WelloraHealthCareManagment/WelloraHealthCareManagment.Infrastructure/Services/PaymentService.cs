// Infrastructure/Services/PaymentService.cs

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.DTOs.Payment;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly IPaymentRepository _paymentRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IDoctorRepository _doctorRepository;
        private readonly IPatientRepository _patientRepository;
        private readonly IPaymobService _paymobService;
        private readonly ITimeSlotRepository _timeSlotRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly IMedicalHistoryAccessRepository _accessRepository;
        private readonly IAppointmentReminderService _appointmentReminderService;
        private readonly INotificationService _notificationService;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(
            IPaymentRepository paymentRepository,
            IAppointmentRepository appointmentRepository,
            IDoctorRepository doctorRepository,
            IPatientRepository patientRepository,
            IPaymobService paymobService,
            ITimeSlotRepository timeSlotRepository,
            IUnitOfWork unitOfWork,
            IConfiguration configuration,
            IMedicalHistoryAccessRepository accessRepository,
            IAppointmentReminderService appointmentReminderService,
            INotificationService notificationService,
            ILogger<PaymentService> logger)
        {
            _paymentRepository = paymentRepository;
            _appointmentRepository = appointmentRepository;
            _doctorRepository = doctorRepository;
            _patientRepository = patientRepository;
            _paymobService = paymobService;
            _timeSlotRepository = timeSlotRepository;
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _accessRepository = accessRepository;
            _appointmentReminderService = appointmentReminderService;
            _notificationService = notificationService;
            _logger = logger;
        }

        #region Callback Processing

        public async Task<ProcessCallbackResult> ProcessPaymobCallbackAsync(
            PaymobCallbackRequest callback,
            string hmacHeader,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Processing Paymob callback for order {OrderId}, Transaction {TransactionId}",
                    callback.obj.order.id, callback.obj.id);

                // 1. Verify HMAC
                if (string.IsNullOrEmpty(hmacHeader))
                {
                    _logger.LogWarning("Callback received without HMAC header");
                    return new ProcessCallbackResult { Success = false, Message = "HMAC header missing" };
                }

                var isValid = await _paymobService.VerifyCallbackAsync(callback, hmacHeader);
                if (!isValid)
                {
                    _logger.LogError("HMAC verification failed");
                    return new ProcessCallbackResult { Success = false, Message = "Invalid HMAC signature" };
                }

                // 2. Find payment
                var orderId = callback.obj.order.id.ToString();
                var paymentCheck = await _paymentRepository.GetByPaymobOrderIdAsync(orderId, cancellationToken);

                if (paymentCheck == null)
                {
                    _logger.LogWarning("Payment not found for order {OrderId}", orderId);
                    return new ProcessCallbackResult { Success = false, Message = "Payment not found" };
                }

                var callbackJson = JsonConvert.SerializeObject(callback);

                // 3. Process based on status
                if (callback.obj.success && !callback.obj.pending)
                {
                    _logger.LogInformation("→ Success callback → HandleSuccessfulPaymentAsync");
                    return await HandleSuccessfulPaymentAsync(orderId, callback, callbackJson, cancellationToken);
                }
                else if (callback.obj.pending)
                {
                    _logger.LogInformation("→ Payment is still Pending");
                    // في التدفق الجديد AppointmentId ممكن يكون null، فهنعدل الـ HandlePending
                    return await HandlePendingPaymentAsync(paymentCheck.Id, cancellationToken); // غيرنا لـ PaymentId
                }
                else
                {
                    _logger.LogWarning("→ Payment Failed");
                    return await HandleFailedPaymentAsync(orderId, callback, callbackJson, cancellationToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing Paymob callback");
                return new ProcessCallbackResult { Success = false, Message = $"Error: {ex.Message}" };
            }
        }

        private async Task<ProcessCallbackResult> HandleSuccessfulPaymentAsync(
                    string paymobOrderId,
                    PaymobCallbackRequest callback,
                    string callbackJson,
                    CancellationToken cancellationToken)
        {
            var payment = await _paymentRepository.GetByPaymobOrderIdForUpdateAsync(
                paymobOrderId, cancellationToken);

            if (payment == null)
            {
                _logger.LogError("Payment not found for order {OrderId}", paymobOrderId);
                return new ProcessCallbackResult { Success = false, Message = "Payment not found" };
            }

            _logger.LogInformation(
                "Payment successful for PaymentId: {PaymentId}, TimeSlotId: {TimeSlotId}",
                payment.Id, payment.TimeSlotId);

            Guid? finalAppointmentId = null;
            Appointment? reminderAppointment = null;
            TimeSlot? reminderTimeSlot = null;

            // التدفق القديم: لو فيه AppointmentId بالفعل
            if (payment.AppointmentId.HasValue && payment.AppointmentId.Value != Guid.Empty)
            {
                // MarkAsPaid + Update في التدفق القديم
                payment.MarkAsPaid(
                    callback.obj.id.ToString(),
                    callback.obj.integration_id,
                    callbackJson);

                await _paymentRepository.UpdateAsync(payment, cancellationToken);

                var appointment = await _appointmentRepository.GetByIdForUpdateAsync(
                    payment.AppointmentId.Value, cancellationToken);

                if (appointment != null)
                {
                    appointment.MarkAsPaid(payment.Id);
                    await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
                    finalAppointmentId = appointment.Id;
                    reminderAppointment = appointment;

                    reminderTimeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                        appointment.TimeSlotId,
                        cancellationToken);
                }

                await _unitOfWork.SaveChangesAsync(cancellationToken);
            }

            // التدفق الجديد: إنشاء Appointment بعد نجاح الدفع
            // كل العمليات جوا Transaction واحدة atomically
            else if (payment.TimeSlotId.HasValue)
            {
                await _unitOfWork.BeginTransactionAsync(cancellationToken);

                try
                {
                    // 1. جلب السلوت والتحقق منه
                    var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                        payment.TimeSlotId.Value, cancellationToken);

                    if (timeSlot == null)
                        throw new NotFoundException("TimeSlot", payment.TimeSlotId.Value);

                    if (timeSlot.Status != SlotStatus.Available)
                        throw new DomainException("Time slot is no longer available");

                    // 2. MarkAsPaid جوا الـ Transaction
                    //    (لو حصل Rollback كل حاجة بترجع معاه)
                    payment.MarkAsPaid(
                        callback.obj.id.ToString(),
                        callback.obj.integration_id,
                        callbackJson);

                    // 3. إنشاء الموعد
                    var appointment = Appointment.Create(
                        timeSlot.Id,
                        timeSlot.DoctorId,
                        payment.PatientId,
                        patientNotes: payment.PatientNotes);

                    appointment.SetConsultationFee(payment.Amount);

                    // 4. ربط الدفع بالموعد
                    payment.LinkToAppointment(appointment.Id);
                    appointment.MarkAsPaid(payment.Id);

                    // 5. حجز السلوت
                    timeSlot.Book();

                    await _appointmentRepository.AddAsync(appointment, cancellationToken);
                    await _timeSlotRepository.UpdateAsync(timeSlot, cancellationToken);
                    await _paymentRepository.UpdateAsync(payment, cancellationToken);

                    // ★ CRITICAL: SaveChanges هنا عشان appointment.Id يتولد في الـ DB
                    //             قبل ما نحاول نربط الـ Grant بيه
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation(
                        "Appointment {AppointmentId} created after payment. Creating Grant if requested.",
                        appointment.Id);

                    // 6. Create Medical History Access Grant (بعد ما الـ ID اتولد فعلاً)
                    if (payment.GrantMedicalHistoryAccess)
                    {
                        var expiresAt = timeSlot.SlotDate.Add(timeSlot.EndTime).AddHours(24);

                        var grant = MedicalHistoryAccessGrant.Create(
                            patientId: payment.PatientId,
                            doctorId: timeSlot.DoctorId,
                            appointmentId: appointment.Id,
                            grantType: GrantType.Appointment,
                            expiresAt: expiresAt,
                            canViewMedicalHistory: true,
                            canViewPrescriptions: true,
                            canViewLabResults: false);

                        await _accessRepository.AddAsync(grant, cancellationToken);

                        // Audit Log
                        var log = MedicalHistoryAccessLog.Create(
                            accessGrantId: grant.Id,
                            doctorId: timeSlot.DoctorId,
                            patientId: payment.PatientId,
                            accessType: "AccessGranted",
                            resourceAccessed: "Medical access grant created after payment confirmation");

                        await _accessRepository.AddLogAsync(log, cancellationToken);

                        await _unitOfWork.SaveChangesAsync(cancellationToken);

                        _logger.LogInformation(
                            "Grant {GrantId} created for appointment {AppointmentId}, expires {ExpiresAt}",
                            grant.Id, appointment.Id, expiresAt);
                    }

                    // 7. Commit كل حاجة atomically
                    await _unitOfWork.CommitTransactionAsync(cancellationToken);

                    finalAppointmentId = appointment.Id;
                    reminderAppointment = appointment;
                    reminderTimeSlot = timeSlot;

                    _logger.LogInformation(
                        "Appointment {AppointmentId} completed successfully after payment confirmation.",
                        appointment.Id);
                }
                catch (Exception ex)
                {
                    await _unitOfWork.RollbackTransactionAsync(cancellationToken);
                    _logger.LogError(ex,
                        "Failed to complete booking after payment {PaymentId}", payment.Id);
                    throw;
                }
            }

            _logger.LogInformation("Payment {PaymentId} marked as paid successfully", payment.Id);

            if (reminderAppointment != null && reminderTimeSlot != null)
            {
                try
                {
                    await _appointmentReminderService.CreateAppointmentRemindersAsync(
                        reminderAppointment,
                        reminderTimeSlot,
                        reminderAppointment.PatientId,
                        reminderAppointment.DoctorId,
                        cancellationToken);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(
                        ex,
                        "Non-critical: payment succeeded for Appointment {AppointmentId} but reminder creation failed",
                        reminderAppointment.Id);
                }
            }

            await _notificationService.NotifyManyAsync(new[]
            {
                new NotificationDispatchRequest
                {
                    UserId = payment.PatientId,
                    Title = "Payment Confirmed",
                    Message = $"Your payment of {payment.Amount:F2} EGP has been confirmed.",
                    Type = NotificationType.PaymentSucceeded,
                    RelatedEntityType = "Payment",
                    Data = new Dictionary<string, string> { ["paymentId"] = payment.Id.ToString() }
                },
                new NotificationDispatchRequest
                {
                    UserId = payment.DoctorId,
                    Title = "Appointment Payment Received",
                    Message = $"A patient's payment of {payment.Amount:F2} EGP has been confirmed for an appointment.",
                    Type = NotificationType.PaymentSucceeded,
                    RelatedEntityType = "Payment",
                    Data = new Dictionary<string, string> { ["paymentId"] = payment.Id.ToString() }
                }
            }, cancellationToken);

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment confirmed",
                AppointmentId = finalAppointmentId
            };
        }

        private async Task<ProcessCallbackResult> HandlePendingPaymentAsync(
            Guid paymentId,                   
            CancellationToken cancellationToken)
        {
            _logger.LogInformation("Payment pending for PaymentId: {PaymentId}", paymentId);
            var payment = await _paymentRepository.GetByIdAsync(paymentId, cancellationToken);
            if (payment != null)
            {
                await _notificationService.NotifyAsync(new NotificationDispatchRequest
                {
                    UserId = payment.PatientId,
                    Title = "Payment Pending",
                    Message = $"Your payment of {payment.Amount:F2} EGP is still pending confirmation.",
                    Type = NotificationType.PaymentPending,
                    RelatedEntityType = "Payment",
                    Data = new Dictionary<string, string> { ["paymentId"] = payment.Id.ToString() }
                }, cancellationToken);
            }

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment pending",
                AppointmentId = null
            };
        }
        private async Task<ProcessCallbackResult> HandleFailedPaymentAsync(
            string paymobOrderId,
            PaymobCallbackRequest callback,
            string callbackJson,
            CancellationToken cancellationToken)
        {
            var payment = await _paymentRepository.GetByPaymobOrderIdForUpdateAsync(
                paymobOrderId, cancellationToken);

            if (payment == null)
            {
                _logger.LogError("Payment not found for order {OrderId}", paymobOrderId);
                return new ProcessCallbackResult
                {
                    Success = false,
                    Message = "Payment not found"
                };
            }

            var reason = callback.obj.source_data?.type ?? "Payment declined by gateway";

            _logger.LogWarning(
                "Payment failed for PaymentId: {PaymentId}, TimeSlotId: {TimeSlotId}, Reason: {Reason}",
                payment.Id, payment.TimeSlotId, reason);

            payment.MarkAsFailed(reason, callbackJson);
            await _paymentRepository.UpdateAsync(payment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            await _notificationService.NotifyAsync(new NotificationDispatchRequest
            {
                UserId = payment.PatientId,
                Title = "Payment Failed",
                Message = $"Your payment could not be completed. Reason: {reason}.",
                Type = NotificationType.PaymentFailed,
                RelatedEntityType = "Payment",
                Data = new Dictionary<string, string>
                {
                    ["paymentId"] = payment.Id.ToString(),
                    ["reason"] = reason
                }
            }, cancellationToken);

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment failure recorded",
                AppointmentId = payment.AppointmentId ?? null
            };
        }

        public async Task<string> HandlePaymentResultRedirectAsync(
            string? merchantOrderId,
            bool success)
        {
            try
            {
                _logger.LogInformation("Payment result redirect received. MerchantOrderId: {MerchantOrderId}, Success: {Success}",
                    merchantOrderId, success);

                if (string.IsNullOrEmpty(merchantOrderId))
                {
                    return GetFailureRedirectUrl(null, "Invalid order ID");
                }

                // محاولة تحويل merchantOrderId إلى Guid (ده PaymentId في التدفق الجديد)
                if (!Guid.TryParse(merchantOrderId, out Guid paymentOrAppointmentId))
                {
                    return GetFailureRedirectUrl(null, "Invalid order ID format");
                }

                // أولاً: نبحث عن الـ Payment باستخدام PaymentId (التدفق الجديد)
                var payment = await _paymentRepository.GetByIdAsync(paymentOrAppointmentId);

                // لو مش لاقيها، نبحث بـ AppointmentId (التدفق القديم)
                if (payment == null)
                {
                    payment = await _paymentRepository.GetByAppointmentIdAsync(paymentOrAppointmentId);
                }

                if (payment == null)
                {
                    _logger.LogWarning("Payment not found for ID: {Id}", paymentOrAppointmentId);
                    return GetFailureRedirectUrl(null, "Payment not found");
                }

                // التحقق من حالة الدفع
                if (success && payment.Status == PaymentStatus.Paid)
                {
                    _logger.LogInformation("Payment successful redirect for PaymentId: {PaymentId}, AppointmentId: {AppointmentId}",
                        payment.Id, payment.AppointmentId);

                    return GetSuccessRedirectUrl(payment.AppointmentId ?? Guid.Empty, payment.Amount);
                }
                else
                {
                    _logger.LogWarning("Payment failed or not paid. Status: {Status}", payment.Status);
                    return GetFailureRedirectUrl(payment.AppointmentId, payment.FailureReason ?? "Payment was not completed");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling payment result redirect for MerchantOrderId: {MerchantOrderId}", merchantOrderId);
                return "/payment-error.html";
            }
        }

        //private string GetSuccessRedirectUrl(Guid appointmentId, decimal amount)
        //{
        //    var baseUrl = _configuration["App:BaseUrl"] ?? "https://wellorahealthcare.com";
        //    return $"{baseUrl}/payment-success.html?appointmentId={appointmentId}&amount={amount}";
        //}
        private string GetSuccessRedirectUrl(Guid? appointmentId, decimal amount)
        {
            var baseUrl = _configuration["App:BaseUrl"] ?? "https://wellorahealthcare.com";
            var url = $"{baseUrl}/payment-success.html?amount={amount}";

            if (appointmentId.HasValue && appointmentId.Value != Guid.Empty)
                url += $"&appointmentId={appointmentId}";

            return url;
        }

        private string GetFailureRedirectUrl(Guid? appointmentId, string? reason)
        {
            var baseUrl = _configuration["App:BaseUrl"] ?? "https://wellorahealthcare.com";
            var url = $"{baseUrl}/payment-failed.html";
            var separator = "?";  // نبدأ بـ ? دايماً

            if (appointmentId.HasValue)
            {
                url += $"{separator}appointmentId={appointmentId}";
                separator = "&";
            }

            if (!string.IsNullOrEmpty(reason))
                url += $"{separator}reason={Uri.EscapeDataString(reason)}";

            return url;
        }

        #endregion

        #region Payment Creation


        #region Payment Creation
        public async Task<CreatePaymentResponse> CreatePaymentAsync(
            CreatePaymentRequest request,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            try
            {
                var effectivePatientId = GetEffectivePatientId(
                    request.PatientId,
                    requesterUserId,
                    requesterRole);

                _logger.LogInformation(
                    "Creating payment. AppointmentId: {AppointmentId}, TimeSlotId: {TimeSlotId}, PatientId: {PatientId}",
                    request.AppointmentId, request.TimeSlotId, effectivePatientId);

                // ====================== التدفق الجديد: الدفع باستخدام TimeSlotId ======================
                if (request.TimeSlotId.HasValue && request.TimeSlotId.Value != Guid.Empty)
                {
                    // 1. التحقق من السلوت وتوفره
                    var timeSlot = await _timeSlotRepository.GetByIdWithDoctorAsync(
                        request.TimeSlotId.Value, cancellationToken);

                    if (timeSlot == null)
                        throw new NotFoundException("TimeSlot", request.TimeSlotId.Value);

                    if (timeSlot.IsExpired())
                        throw new DomainException("This time slot has already passed and cannot be booked");

                    if (timeSlot.Status != SlotStatus.Available)
                        throw new DomainException("This time slot is no longer available");

                    if (timeSlot.Doctor == null)
                        throw new DomainException("Doctor information is missing from time slot");

                    // 2. التحقق من عدم وجود حجز سابق على هذا السلوت
                    var existingAppointment = await _appointmentRepository
                        .GetByTimeSlotIdAsync(request.TimeSlotId.Value, cancellationToken);

                    if (existingAppointment != null)
                        throw new DomainException("This time slot is already booked");

                    // 3. جلب بيانات المريض
                    var patient = await _patientRepository.GetByIdWithUserAsync(
                        effectivePatientId, cancellationToken);

                    if (patient == null)
                        throw new NotFoundException("Patient", effectivePatientId);

                    if (patient.User == null)
                        throw new DomainException("Patient account data not found");

                    if (string.IsNullOrEmpty(patient.User.Email))
                        throw new DomainException("Patient email is required for payment");

                    if (string.IsNullOrEmpty(patient.User.FullName))
                        throw new DomainException("Patient name is required for payment");

                    // 4. حساب المبلغ
                    var amount = timeSlot.Doctor?.ConsultationFee ?? 0m;
                    if (amount <= 0)
                        throw new DomainException("Consultation fee is not set for this doctor");

                    // 5. إنشاء Payment مرتبط بالسلوت فقط (قبل إنشاء الموعد)
                    var payment = Payment.CreatePendingForSlot(
                        timeSlot.Id,
                        effectivePatientId,
                        timeSlot.DoctorId,
                        amount,
                        request.PaymentMethod,
                        request.PatientNotes,             
                        request.GrantMedicalHistoryAccess);

                    await _paymentRepository.AddAsync(payment, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    // 6. Parse patient name safely
                    string firstName;
                    string lastName;
                    var nameParts = patient.User.FullName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (nameParts.Length == 0)
                    {
                        firstName = "Patient";
                        lastName = patient.PatientID.ToString();
                    }
                    else if (nameParts.Length == 1)
                    {
                        firstName = nameParts[0];
                        lastName = "User";
                    }
                    else
                    {
                        firstName = nameParts[0];
                        lastName = string.Join(" ", nameParts.Skip(1));
                    }

                    // 7. إنشاء الدفع في Paymob (نستخدم Payment.Id كـ merchant_order_id)
                    var paymobResponse = await _paymobService.CreatePaymentAsync(
                        payment.Id,                    // Payment ID بدل Appointment ID
                        amount,
                        request.PaymentMethod,
                        patient.User.Email,
                        patient.User.PhoneNumber ?? "01000000000",
                        firstName,
                        lastName,
                        cancellationToken);

                    if (paymobResponse == null)
                        throw new DomainException("Failed to create Paymob payment");

                    // 8. تحديث Paymob Order ID
                    payment.SetPaymobOrderId(paymobResponse.PaymobOrderId);
                    await _paymentRepository.UpdateAsync(payment, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation(
                        "Payment created successfully for TimeSlot {TimeSlotId}, PaymentId: {PaymentId}, URL: {Url}",
                        request.TimeSlotId, payment.Id, paymobResponse.PaymentUrl);

                    return new CreatePaymentResponse
                    {
                        PaymentUrl = paymobResponse.PaymentUrl,
                        PaymentId = payment.Id,
                        PaymobOrderId = paymobResponse.PaymobOrderId,
                        Amount = amount
                    };
                }

                // ====================== التدفق القديم: لما يكون AppointmentId موجود (للتوافق) ======================
                else if (request.AppointmentId.HasValue && request.AppointmentId.Value != Guid.Empty)
                {
                    // نفس الكود القديم تقريباً (مع بعض التحسينات البسيطة)
                    var existingPayment = await _paymentRepository.GetByAppointmentIdAsync(
                        request.AppointmentId.Value, cancellationToken);

                    if (existingPayment != null)
                    {
                        if (existingPayment.Status == PaymentStatus.Pending &&
                            !string.IsNullOrEmpty(existingPayment.PaymobOrderId))
                        {
                            throw new DomainException(
                                $"A pending payment already exists for this appointment. " +
                                $"Please complete or cancel the existing payment first. " +
                                $"Payment ID: {existingPayment.Id}");
                        }

                        if (existingPayment.Status == PaymentStatus.Paid)
                            throw new DomainException("This appointment has already been paid");

                        if (existingPayment.Status == PaymentStatus.Failed)
                        {
                            await _paymentRepository.DeleteAsync(existingPayment, cancellationToken);
                            await _unitOfWork.SaveChangesAsync(cancellationToken);
                        }
                    }

                    var appointment = await _appointmentRepository.GetByIdAsync(
                        request.AppointmentId.Value, cancellationToken);

                    if (appointment == null)
                        throw new NotFoundException("Appointment", request.AppointmentId.Value);

                    if (appointment.IsPaid)
                        throw new DomainException("Appointment already paid");

                    EnsurePaymentAccess(
                        appointment.PatientId,
                        appointment.DoctorId,
                        requesterUserId,
                        requesterRole);

                    var doctor = await _doctorRepository.GetByIdWithUserAsync(
                        appointment.DoctorId, cancellationToken);

                    if (doctor == null)
                        throw new NotFoundException("Doctor", appointment.DoctorId);

                    var patient = await _patientRepository.GetByIdWithUserAsync(
                        appointment.PatientId, cancellationToken);

                    if (patient == null)
                        throw new NotFoundException("Patient", appointment.PatientId);

                    if (patient.User == null || string.IsNullOrEmpty(patient.User.Email) || string.IsNullOrEmpty(patient.User.FullName))
                        throw new DomainException("Patient billing information is incomplete");

                    // تأكد من السطر دا
                    var amount = (appointment.ConsultationFee.HasValue ? appointment.ConsultationFee.Value : (doctor.ConsultationFee != 0m ? doctor.ConsultationFee : 0m));
                    if (amount <= 0)
                        throw new DomainException("Consultation fee is not set");

                    var payment = Payment.CreatePending(
                        appointment.Id,
                        appointment.PatientId,
                        appointment.DoctorId,
                        amount,
                        request.PaymentMethod);

                    await _paymentRepository.AddAsync(payment, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    // Parse name + Paymob call (نفس المنطق)
                    string firstName;
                    string lastName;
                    var nameParts = patient.User.FullName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
                    if (nameParts.Length == 0)
                    {
                        firstName = "Patient";
                        lastName = patient.PatientID.ToString();
                    }
                    else if (nameParts.Length == 1)
                    {
                        firstName = nameParts[0];
                        lastName = "User";
                    }
                    else
                    {
                        firstName = nameParts[0];
                        lastName = string.Join(" ", nameParts.Skip(1));
                    }

                    var paymobResponse = await _paymobService.CreatePaymentAsync(
                        appointment.Id,
                        amount,
                        request.PaymentMethod,
                        patient.User.Email,
                        patient.User.PhoneNumber ?? "01000000000",
                        firstName,
                        lastName,
                        cancellationToken);

                    if (paymobResponse == null)
                        throw new DomainException("Failed to create Paymob payment");

                    payment.SetPaymobOrderId(paymobResponse.PaymobOrderId);
                    await _paymentRepository.UpdateAsync(payment, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    return new CreatePaymentResponse
                    {
                        PaymentUrl = paymobResponse.PaymentUrl,
                        PaymentId = payment.Id,
                        PaymobOrderId = paymobResponse.PaymobOrderId,
                        Amount = amount
                    };
                }
                else
                {
                    throw new DomainException("Either TimeSlotId or AppointmentId must be provided");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error creating payment for AppointmentId: {AppointmentId}, TimeSlotId: {TimeSlotId}",
                    request.AppointmentId, request.TimeSlotId);
                throw;
            }
        }
        #endregion

        //  Helper method
        private string GetIframeIdForMethod(PaymentMethod method)
        {
            return _configuration[$"Paymob:IframeId:{method}"]
                ?? _configuration["Paymob:IframeId:Card"]
                ?? "";
        }

        #endregion

        #region Refund

        public async Task<RefundPaymentResponse> RefundPaymentAsync(
            RefundPaymentRequest request,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Processing refund for payment {PaymentId}, Amount: {Amount} EGP",
                    request.PaymentId, request.Amount);

                
                // 1. GET AND VALIDATE PAYMENT
                // الحصول على الدفع والتحقق منه
                

                var payment = await _paymentRepository.GetByIdAsync(
                    request.PaymentId,
                    cancellationToken);

                if (payment == null)
                {
                    _logger.LogWarning("Payment {PaymentId} not found", request.PaymentId);
                    throw new NotFoundException("Payment", request.PaymentId);
                }

                EnsurePaymentAccess(
                    payment.PatientId,
                    payment.DoctorId,
                    requesterUserId,
                    requesterRole);

                
                // 2. VALIDATE REFUND ELIGIBILITY
                // التحقق من أهلية الاسترجاع
                

                // 2.1 Check if can be refunded
                if (!payment.CanBeRefunded())
                {
                    _logger.LogWarning(
                        "Payment {PaymentId} cannot be refunded. Status: {Status}",
                        request.PaymentId, payment.Status);

                    return new RefundPaymentResponse
                    {
                        Success = false,
                        Message = $"Payment cannot be refunded. Current status: {payment.Status}"
                    };
                }

                // 2.2 Validate refund amount
                if (request.Amount <= 0 || request.Amount > payment.Amount)
                {
                    _logger.LogWarning(
                        "Invalid refund amount {Amount} for payment {PaymentId} (original: {OriginalAmount})",
                        request.Amount, request.PaymentId, payment.Amount);

                    return new RefundPaymentResponse
                    {
                        Success = false,
                        Message = $"Invalid refund amount. Must be between 0 and {payment.Amount} EGP"
                    };
                }

                // 2.3 Check if already refunded (Idempotency check)
                if (payment.Status == PaymentStatus.Refunded)
                {
                    _logger.LogWarning(
                        "Payment {PaymentId} is already refunded. Transaction ID: {TransactionId}",
                        request.PaymentId, payment.RefundTransactionId);

                    // Return existing refund details (Idempotent response)
                    return new RefundPaymentResponse
                    {
                        Success = true,
                        Message = "Payment was already refunded",
                        RefundTransactionId = payment.RefundTransactionId,
                        RefundedAmount = payment.RefundAmount ?? request.Amount,
                        IsAlreadyRefunded = true  // New flag to indicate this was already done
                    };
                }

                
                // 3. PROCESS REFUND WITH PAYMOB
                // معالجة الاسترجاع عبر Paymob مع Retry Logic
                

                var amountCents = request.Amount * 100;
                RefundPaymentResponse? paymobRefund = null;
                Exception? lastException = null;

                // Retry logic: 3 attempts
                for (int attempt = 1; attempt <= 3; attempt++)
                {
                    try
                    {
                        _logger.LogInformation(
                            "Paymob refund attempt {Attempt}/3 for payment {PaymentId}",
                            attempt, request.PaymentId);

                        paymobRefund = await _paymobService.RefundPaymentAsync(
                            payment.PaymobTransactionId,
                            amountCents,
                            cancellationToken);

                        if (paymobRefund != null && paymobRefund.Success)
                        {
                            _logger.LogInformation(
                                "Paymob refund successful on attempt {Attempt}. Transaction ID: {TransactionId}",
                                attempt, paymobRefund.RefundTransactionId);
                            break; // Success, exit retry loop
                        }

                        _logger.LogWarning(
                            "Paymob refund attempt {Attempt} failed: {Message}",
                            attempt, paymobRefund?.Message ?? "Unknown error");

                        // Wait before retry (exponential backoff)
                        if (attempt < 3)
                        {
                            var delayMs = attempt * 1000; // 1s, 2s
                            _logger.LogInformation("Retrying after {Delay}ms...", delayMs);
                            await Task.Delay(delayMs, cancellationToken);
                        }
                    }
                    catch (Exception ex)
                    {
                        lastException = ex;
                        _logger.LogError(ex,
                            "Exception during Paymob refund attempt {Attempt} for payment {PaymentId}",
                            attempt, request.PaymentId);

                        if (attempt < 3)
                        {
                            var delayMs = attempt * 1000;
                            await Task.Delay(delayMs, cancellationToken);
                        }
                    }
                }

                
                // 4. HANDLE REFUND RESULT
                // معالجة نتيجة الاسترجاع
                

                if (paymobRefund == null || !paymobRefund.Success)
                {
                    _logger.LogError(
                        "Paymob refund failed after 3 attempts for payment {PaymentId}. Last error: {Error}",
                        request.PaymentId,
                        lastException?.Message ?? paymobRefund?.Message ?? "Unknown error");

                    // Mark payment as "Refund Pending" for manual processing
                    // You might want to add a new status for this: PaymentStatus.RefundPending

                    return new RefundPaymentResponse
                    {
                        Success = false,
                        Message = $"Refund processing failed after multiple attempts: " +
                                  $"{paymobRefund?.Message ?? lastException?.Message ?? "Unknown error"}. " +
                                  "Your refund will be processed manually within 24 hours."
                    };
                }

                
                // 5. UPDATE PAYMENT ENTITY
                // تحديث كيان الدفع
                

                // Determine who initiated the cancellation from the RefundReason enum
                CancelledBy initiatedBy = request.Reason switch
                {
                    RefundReason.PatientCancellation => CancelledBy.Patient,
                    RefundReason.DoctorCancellation => CancelledBy.Doctor,
                    RefundReason.DoctorDayOff => CancelledBy.Doctor,
                    RefundReason.SystemError => CancelledBy.System,
                    _ => CancelledBy.System
                };

                // Calculate percentage
                var refundPercentage = request.RefundPercentage
                    ?? (request.Amount / payment.Amount) * 100;

                payment.MarkAsRefunded(
                    refundAmount: request.Amount,
                    refundPercentage: refundPercentage,
                    refundTransactionId: paymobRefund.RefundTransactionId ?? "",
                    reason: request.Reason,
                    initiatedBy: initiatedBy,
                    notes: request.Notes);

                await _paymentRepository.UpdateAsync(payment, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);
                await _notificationService.NotifyManyAsync(new[]
                {
                    new NotificationDispatchRequest
                    {
                        UserId = payment.PatientId,
                        Title = "Refund Processed",
                        Message = $"A refund of {request.Amount:F2} EGP has been processed for your payment.",
                        Type = NotificationType.RefundProcessed,
                        RelatedEntityType = "Payment",
                        Data = new Dictionary<string, string> { ["paymentId"] = payment.Id.ToString() }
                    },
                    new NotificationDispatchRequest
                    {
                        UserId = payment.DoctorId,
                        Title = "Appointment Refund Processed",
                        Message = $"A refund of {request.Amount:F2} EGP was processed for an appointment payment.",
                        Type = NotificationType.RefundProcessed,
                        RelatedEntityType = "Payment",
                        Data = new Dictionary<string, string> { ["paymentId"] = payment.Id.ToString() }
                    }
                }, cancellationToken);

                _logger.LogInformation(
                    "Refund completed successfully for payment {PaymentId}. " +
                    "Amount: {Amount} EGP ({Percentage}%), Transaction ID: {TransactionId}",
                    request.PaymentId,
                    request.Amount,
                    refundPercentage,
                    paymobRefund.RefundTransactionId);

                
                // 6. RETURN SUCCESS RESPONSE
                // إرجاع الاستجابة
                

                return new RefundPaymentResponse
                {
                    Success = true,
                    Message = $"Refund processed successfully. {request.Amount:F2} EGP will be " +
                              "returned to your payment method within 3-5 business days.",
                    RefundTransactionId = paymobRefund.RefundTransactionId,
                    RefundedAmount = request.Amount,
                    RefundPercentage = refundPercentage
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Unexpected error processing refund for payment {PaymentId}",
                    request.PaymentId);

                return new RefundPaymentResponse
                {
                    Success = false,
                    Message = $"Unexpected error during refund: {ex.Message}. Please contact support."
                };
            }
        }

        #endregion

        #region Queries

        public async Task<Payment?> GetPaymentByAppointmentIdAsync(
            Guid appointmentId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            var payment = await _paymentRepository.GetByAppointmentIdAsync(
                appointmentId,
                cancellationToken);

            if (payment != null)
            {
                EnsurePaymentAccess(
                    payment.PatientId,
                    payment.DoctorId,
                    requesterUserId,
                    requesterRole);
            }

            return payment;
        }

        public async Task<List<PaymentHistoryDto>> GetPatientPaymentHistoryAsync(
            int patientId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default)
        {
            if (!string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase) &&
                patientId != requesterUserId)
            {
                throw new UnauthorizedAccessException("You can only access your own payment history.");
            }

            var payments = await _paymentRepository.GetPatientPaymentsAsync(
                patientId,
                cancellationToken);

            return payments.Select(p => new PaymentHistoryDto
            {
                PaymentId = p.Id,
                AppointmentId = p.AppointmentId.Value,
                Amount = p.Amount,
                Status = p.Status,
                Method = p.Method,
                PaidAt = p.PaidAt,
                CreatedAt = p.CreatedAt,
                // بنستخدم بس FullName — مش محتاجين كل Doctor object
                DoctorName = p.Doctor?.User?.FullName ?? "Unknown"
            }).ToList();
        }

        private int GetEffectivePatientId(int requestedPatientId, int requesterUserId, string requesterRole)
        {
            if (string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return requestedPatientId;
            }

            if (string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase))
            {
                if (requestedPatientId != 0 && requestedPatientId != requesterUserId)
                {
                    throw new UnauthorizedAccessException("You can only create payments for your own account.");
                }

                return requesterUserId;
            }

            throw new UnauthorizedAccessException("Only patients or administrators can create payments.");
        }

        private static void EnsurePaymentAccess(
            int patientId,
            int doctorId,
            int requesterUserId,
            string requesterRole)
        {
            if (string.Equals(requesterRole, "Admin", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (string.Equals(requesterRole, "Patient", StringComparison.OrdinalIgnoreCase) &&
                patientId == requesterUserId)
            {
                return;
            }

            if (string.Equals(requesterRole, "Doctor", StringComparison.OrdinalIgnoreCase) &&
                doctorId == requesterUserId)
            {
                return;
            }

            throw new UnauthorizedAccessException("You are not allowed to access this payment.");
        }

        #endregion
    }
}
