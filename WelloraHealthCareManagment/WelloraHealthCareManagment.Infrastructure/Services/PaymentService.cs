// Infrastructure/Services/PaymentService.cs

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Application.DTOs.Payment;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
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
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConfiguration _configuration;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(
            IPaymentRepository paymentRepository,
            IAppointmentRepository appointmentRepository,
            IDoctorRepository doctorRepository,
            IPatientRepository patientRepository,
            IPaymobService paymobService,
            IUnitOfWork unitOfWork,
            IConfiguration configuration,
            ILogger<PaymentService> logger)
        {
            _paymentRepository = paymentRepository;
            _appointmentRepository = appointmentRepository;
            _doctorRepository = doctorRepository;
            _patientRepository = patientRepository;
            _paymobService = paymobService;
            _unitOfWork = unitOfWork;
            _configuration = configuration;
            _logger = logger;
        }

        #region Callback Processing

        //public async Task<ProcessCallbackResult> ProcessPaymobCallbackAsync(
        //    PaymobCallbackRequest callback,
        //    string hmacHeader,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        _logger.LogInformation(
        //            "Processing Paymob callback for order {OrderId}, Transaction {TransactionId}",
        //            callback.obj.order.id,
        //            callback.obj.id);

        //        // 1. Verify HMAC
        //        if (string.IsNullOrEmpty(hmacHeader))
        //        {
        //            _logger.LogWarning("Callback received without HMAC header");
        //            return new ProcessCallbackResult
        //            {
        //                Success = false,
        //                Message = "HMAC header missing"
        //            };
        //        }

        //        var isValid = await _paymobService.VerifyCallbackAsync(callback, hmacHeader);

        //        if (!isValid)
        //        {
        //            _logger.LogError("HMAC verification failed");
        //            return new ProcessCallbackResult
        //            {
        //                Success = false,
        //                Message = "Invalid HMAC signature"
        //            };
        //        }

        //        // 2. Find payment
        //        var orderId = callback.obj.order.id.ToString();
        //        var payment = await _paymentRepository.GetByPaymobOrderIdAsync(
        //            orderId,
        //            cancellationToken);

        //        if (payment == null)
        //        {
        //            _logger.LogWarning("Payment not found for order {OrderId}", orderId);
        //            return new ProcessCallbackResult
        //            {
        //                Success = false,
        //                Message = "Payment not found"
        //            };
        //        }

        //        // 3. Serialize callback for debugging
        //        var callbackJson = JsonConvert.SerializeObject(callback);

        //        // 4. Process based on status
        //        if (callback.obj.success && !callback.obj.pending)
        //        {
        //            return await HandleSuccessfulPaymentAsync(
        //                payment,
        //                callback,
        //                callbackJson,
        //                cancellationToken);
        //        }
        //        else if (callback.obj.pending)
        //        {
        //            return await HandlePendingPaymentAsync(
        //                payment,
        //                cancellationToken);
        //        }
        //        else
        //        {
        //            return await HandleFailedPaymentAsync(
        //                payment,
        //                callback,
        //                callbackJson,
        //                cancellationToken);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error processing Paymob callback");
        //        return new ProcessCallbackResult
        //        {
        //            Success = false,
        //            Message = $"Error: {ex.Message}"
        //        };
        //    }
        //}
        public async Task<ProcessCallbackResult> ProcessPaymobCallbackAsync(
            PaymobCallbackRequest callback,
            string hmacHeader,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Processing Paymob callback for order {OrderId}, Transaction {TransactionId}",
                    callback.obj.order.id,
                    callback.obj.id);

                // 1. Verify HMAC
                if (string.IsNullOrEmpty(hmacHeader))
                {
                    _logger.LogWarning("Callback received without HMAC header");
                    return new ProcessCallbackResult
                    {
                        Success = false,
                        Message = "HMAC header missing"
                    };
                }

                var isValid = await _paymobService.VerifyCallbackAsync(callback, hmacHeader);

                if (!isValid)
                {
                    _logger.LogError("HMAC verification failed");
                    return new ProcessCallbackResult
                    {
                        Success = false,
                        Message = "Invalid HMAC signature"
                    };
                }

                // 2. Find payment (read-only for verification)
                var orderId = callback.obj.order.id.ToString();
                var paymentCheck = await _paymentRepository.GetByPaymobOrderIdAsync(
                    orderId,
                    cancellationToken);

                if (paymentCheck == null)
                {
                    _logger.LogWarning("Payment not found for order {OrderId}", orderId);
                    return new ProcessCallbackResult
                    {
                        Success = false,
                        Message = "Payment not found"
                    };
                }

                // 3. Serialize callback for debugging
                var callbackJson = JsonConvert.SerializeObject(callback);

                // 4. Process based on status
                if (callback.obj.success && !callback.obj.pending)
                {
                    return await HandleSuccessfulPaymentAsync(
                        orderId,
                        callback,
                        callbackJson,
                        cancellationToken);
                }
                else if (callback.obj.pending)
                {
                    return await HandlePendingPaymentAsync(
                        paymentCheck.AppointmentId,
                        cancellationToken);
                }
                else
                {
                    return await HandleFailedPaymentAsync(
                        orderId,
                        callback,
                        callbackJson,
                        cancellationToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing Paymob callback");
                return new ProcessCallbackResult
                {
                    Success = false,
                    Message = $"Error: {ex.Message}"
                };
            }
        }

        //private async Task<ProcessCallbackResult> HandleSuccessfulPaymentAsync(
        //    Payment payment,
        //    PaymobCallbackRequest callback,
        //    string callbackJson,
        //    CancellationToken cancellationToken)
        //{
        //    _logger.LogInformation(
        //        "Payment successful for appointment {AppointmentId}",
        //        payment.AppointmentId);

        //    // Update payment
        //    payment.MarkAsPaid(
        //        callback.obj.id.ToString(),
        //        callback.obj.integration_id,
        //        callbackJson);

        //    await _paymentRepository.UpdateAsync(payment, cancellationToken);

        //    // Update appointment
        //    var appointment = await _appointmentRepository.GetByIdAsync(
        //        payment.AppointmentId,
        //        cancellationToken);

        //    if (appointment != null)
        //    {
        //        appointment.MarkAsPaid(payment.Id);
        //        await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
        //    }

        //    await _unitOfWork.SaveChangesAsync(cancellationToken);

        //    return new ProcessCallbackResult
        //    {
        //        Success = true,
        //        Message = "Payment confirmed",
        //        AppointmentId = payment.AppointmentId
        //    };
        //}
        private async Task<ProcessCallbackResult> HandleSuccessfulPaymentAsync(
    string paymobOrderId,
    PaymobCallbackRequest callback,
    string callbackJson,
    CancellationToken cancellationToken)
        {
            //  Get payment WITH TRACKING for update
            var payment = await _paymentRepository.GetByPaymobOrderIdForUpdateAsync(
                paymobOrderId,
                cancellationToken);

            if (payment == null)
            {
                _logger.LogError("Payment not found for order {OrderId}", paymobOrderId);
                return new ProcessCallbackResult
                {
                    Success = false,
                    Message = "Payment not found"
                };
            }

            _logger.LogInformation(
                "Payment successful for appointment {AppointmentId}",
                payment.AppointmentId);

            // Update payment
            payment.MarkAsPaid(
                callback.obj.id.ToString(),
                callback.obj.integration_id,
                callbackJson);

            await _paymentRepository.UpdateAsync(payment, cancellationToken);

            // Update appointment
            var appointment = await _appointmentRepository.GetByIdForUpdateAsync(
                payment.AppointmentId,
                cancellationToken);

            if (appointment != null)
            {
                appointment.MarkAsPaid(payment.Id);
                await _appointmentRepository.UpdateAsync(appointment, cancellationToken);
            }
            else
            {
                _logger.LogWarning(
                    "Appointment {AppointmentId} not found for payment update",
                    payment.AppointmentId);
            }

            await _unitOfWork.SaveChangesAsync(cancellationToken);

            _logger.LogInformation(
                "Payment {PaymentId} marked as paid successfully",
                payment.Id);

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment confirmed",
                AppointmentId = payment.AppointmentId
            };
        }

        //private async Task<ProcessCallbackResult> HandlePendingPaymentAsync(
        //    Payment payment,
        //    CancellationToken cancellationToken)
        //{
        //    _logger.LogInformation(
        //        "Payment pending for appointment {AppointmentId}",
        //        payment.AppointmentId);

        //    return new ProcessCallbackResult
        //    {
        //        Success = true,
        //        Message = "Payment pending",
        //        AppointmentId = payment.AppointmentId
        //    };
        //}

        //private async Task<ProcessCallbackResult> HandleFailedPaymentAsync(
        //    Payment payment,
        //    PaymobCallbackRequest callback,
        //    string callbackJson,
        //    CancellationToken cancellationToken)
        //{
        //    _logger.LogWarning(
        //        "Payment failed for appointment {AppointmentId}: {Reason}",
        //        payment.AppointmentId,
        //        callback.obj.data.message);

        //    payment.MarkAsFailed(
        //        callback.obj.data.message ?? "Payment declined",
        //        callbackJson);

        //    await _paymentRepository.UpdateAsync(payment, cancellationToken);
        //    await _unitOfWork.SaveChangesAsync(cancellationToken);

        //    return new ProcessCallbackResult
        //    {
        //        Success = true,
        //        Message = "Payment failure recorded",
        //        AppointmentId = payment.AppointmentId
        //    };
        //}
        private async Task<ProcessCallbackResult> HandlePendingPaymentAsync(
            Guid appointmentId,
            CancellationToken cancellationToken)
        {
            _logger.LogInformation(
                "Payment pending for appointment {AppointmentId}",
                appointmentId);

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment pending",
                AppointmentId = appointmentId
            };
        }
        //private async Task<ProcessCallbackResult> HandleFailedPaymentAsync(
        //    Payment payment,
        //    PaymobCallbackRequest callback,
        //    string callbackJson,
        //    CancellationToken cancellationToken)
        //{
        //    var reason = "Payment declined by gateway";

        //    _logger.LogWarning(
        //        "Payment failed for appointment {AppointmentId}: {Reason}",
        //        payment.AppointmentId,
        //        reason);

        //    payment.MarkAsFailed(
        //        reason,
        //        callbackJson);

        //    await _paymentRepository.UpdateAsync(payment, cancellationToken);
        //    await _unitOfWork.SaveChangesAsync(cancellationToken);

        //    return new ProcessCallbackResult
        //    {
        //        Success = true,
        //        Message = "Payment failure recorded",
        //        AppointmentId = payment.AppointmentId
        //    };
        //}
        private async Task<ProcessCallbackResult> HandleFailedPaymentAsync(
            string paymobOrderId,
            PaymobCallbackRequest callback,
            string callbackJson,
            CancellationToken cancellationToken)
        {
            //  Get payment WITH TRACKING for update
            var payment = await _paymentRepository.GetByPaymobOrderIdForUpdateAsync(
                paymobOrderId,
                cancellationToken);

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
                "Payment failed for appointment {AppointmentId}: {Reason}",
                payment.AppointmentId,
                reason);

            payment.MarkAsFailed(reason, callbackJson);

            await _paymentRepository.UpdateAsync(payment, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);

            return new ProcessCallbackResult
            {
                Success = true,
                Message = "Payment failure recorded",
                AppointmentId = payment.AppointmentId
            };
        }

        public async Task<string> HandlePaymentResultRedirectAsync(
            string? merchantOrderId,
            bool success)
        {
            try
            {
                // Validate appointment ID
                if (string.IsNullOrEmpty(merchantOrderId) ||
                    !Guid.TryParse(merchantOrderId, out var appointmentId))
                {
                    return GetFailureRedirectUrl(null, "Invalid order ID");
                }

                // Get payment
                var payment = await _paymentRepository.GetByAppointmentIdAsync(
                    appointmentId,
                    CancellationToken.None);

                if (payment == null)
                {
                    return GetFailureRedirectUrl(appointmentId, "Payment not found");
                }

                // Check status
                if (success && payment.Status == PaymentStatus.Paid)
                {
                    return GetSuccessRedirectUrl(appointmentId, payment.Amount);
                }
                else
                {
                    return GetFailureRedirectUrl(appointmentId, payment.FailureReason);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error handling payment result redirect");
                return "/payment-error.html";
            }
        }

        private string GetSuccessRedirectUrl(Guid appointmentId, decimal amount)
        {
            var baseUrl = _configuration["App:BaseUrl"] ?? "https://wellorahealthcare.com";
            return $"{baseUrl}/payment-success.html?appointmentId={appointmentId}&amount={amount}";
        }

        //private string GetFailureRedirectUrl(Guid? appointmentId, string? reason)
        //{
        //    var baseUrl = _configuration["App:BaseUrl"] ?? "https://wellorahealthcare.com";
        //    var url = $"{baseUrl}/payment-failed.html";

        //    if (appointmentId.HasValue)
        //        url += $"?appointmentId={appointmentId}";

        //    if (!string.IsNullOrEmpty(reason))
        //        url += $"&reason={Uri.EscapeDataString(reason)}";

        //    return url;
        //}
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

        //public async Task<CreatePaymentResponse> CreatePaymentAsync(
        //    CreatePaymentRequest request,
        //    CancellationToken cancellationToken = default)
        //{
        //    try
        //    {
        //        _logger.LogInformation(
        //            "Creating payment for appointment {AppointmentId}",
        //            request.AppointmentId);

        //        // 1. Get appointment
        //        var appointment = await _appointmentRepository.GetByIdAsync(
        //            request.AppointmentId,
        //            cancellationToken);

        //        if (appointment == null)
        //            throw new NotFoundException("Appointment", request.AppointmentId);

        //        if (appointment.IsPaid)
        //            throw new DomainException("Appointment already paid");

        //        // 2. Get doctor (for consultation fee)
        //        var doctor = await _doctorRepository.GetByIdAsync(
        //            appointment.DoctorId,
        //            cancellationToken);

        //        if (doctor == null)
        //            throw new NotFoundException("Doctor", appointment.DoctorId);

        //        // 3. Get patient (for billing info)
        //        var patient = await _patientRepository.GetByIdAsync(
        //            appointment.PatientId,
        //            cancellationToken);

        //        if (patient == null)
        //            throw new NotFoundException("Patient", appointment.PatientId);

        //        // 4. Create payment entity
        //        var amount = appointment.ConsultationFee ?? doctor.ConsultationFee;

        //        var payment = Payment.CreatePending(
        //            appointment.Id,
        //            appointment.PatientId,
        //            appointment.DoctorId,
        //            amount,
        //            request.PaymentMethod);

        //        await _paymentRepository.AddAsync(payment, cancellationToken);
        //        await _unitOfWork.SaveChangesAsync(cancellationToken);

        //        // 5. Create Paymob payment
        //        //var paymobResponse = await _paymobService.CreatePaymentAsync(
        //        //    appointment.Id,
        //        //    amount,
        //        //    request.PaymentMethod,
        //        //    patient.User.Email,
        //        //    patient.User.PhoneNumber ?? "",
        //        //    patient.User.FullName.Split(' ')[0],
        //        //    patient.User.FullName.Contains(' ')
        //        //        ? patient.User.FullName.Split(' ')[1]
        //        //        : "",
        //        //    cancellationToken);
        //        var paymobResponse = await _paymobService.CreatePaymentAsync(
        //            appointment.Id,
        //            amount,
        //            request.PaymentMethod,
        //            patient.User.Email ?? "no-email@domain.com",  // fallback مهم
        //            patient.User.PhoneNumber ?? "0123456789",
        //            string.IsNullOrEmpty(patient.User.FullName) ? "Patient" : patient.User.FullName.Split(' ')[0],
        //            patient.User.FullName?.Split(' ').Length > 1 ? patient.User.FullName.Split(' ')[1] : "",
        //            cancellationToken);

        //        if (paymobResponse == null)
        //        {
        //            _logger.LogError("Paymob CreatePaymentAsync returned null for appointment {AppointmentId}", request.AppointmentId);
        //            throw new DomainException("Failed to initialize payment gateway session. Please try again later.");
        //        }

        //        _logger.LogInformation("Paymob response received - OrderId: {OrderId}, PaymentUrl: {Url}",
        //            paymobResponse.PaymobOrderId, paymobResponse.PaymentUrl);


        //        // 6. Update payment with Paymob order ID
        //        //payment.SetPaymobOrderId(paymobResponse.PaymobOrderId);
        //        payment.SetPaymobOrderId(paymobResponse.PaymobOrderId ?? throw new InvalidOperationException("Paymob Order ID is null"));

        //        await _paymentRepository.UpdateAsync(payment, cancellationToken);
        //        await _unitOfWork.SaveChangesAsync(cancellationToken);


        //        // 7. Return response
        //        return new CreatePaymentResponse
        //        {
        //            PaymentUrl = paymobResponse.PaymentUrl,
        //            PaymentId = payment.Id,
        //            PaymobOrderId = paymobResponse.PaymobOrderId,
        //            Amount = amount
        //        };
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex,
        //            "Error creating payment for appointment {AppointmentId}",
        //            request.AppointmentId);
        //        throw;
        //    }
        //}
        // Infrastructure/Services/PaymentService.cs

        public async Task<CreatePaymentResponse> CreatePaymentAsync(
            CreatePaymentRequest request,
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Creating payment for appointment {AppointmentId}",
                    request.AppointmentId);

                //  0. Check if payment already exists for this appointment
                var existingPayment = await _paymentRepository.GetByAppointmentIdAsync(
                    request.AppointmentId,
                    cancellationToken);

                if (existingPayment != null)
                {
                    _logger.LogWarning(
                        "Payment already exists for appointment {AppointmentId}, Status: {Status}",
                        request.AppointmentId, existingPayment.Status);

                    //  If payment is pending, return existing payment URL
                    if (existingPayment.Status == PaymentStatus.Pending &&
                        !string.IsNullOrEmpty(existingPayment.PaymobOrderId))
                    {
                        // Recreate payment URL from existing order
                        var existingIframeId = GetIframeIdForMethod(existingPayment.Method);

                        // Note: We can't recreate the exact payment_token, but we can redirect to a status page
                        // OR throw exception to force user to cancel old payment first
                        throw new DomainException(
                            $"A pending payment already exists for this appointment. " +
                            $"Please complete or cancel the existing payment first. " +
                            $"Payment ID: {existingPayment.Id}");
                    }

                    //  If payment is paid, cannot create new one
                    if (existingPayment.Status == PaymentStatus.Paid)
                    {
                        throw new DomainException("This appointment has already been paid");
                    }

                    //  If payment failed, allow creating a new one by returning existing payment
                    if (existingPayment.Status == PaymentStatus.Failed)
                    {
                        _logger.LogInformation(
                            "Previous payment failed, creating new payment attempt for appointment {AppointmentId}",
                            request.AppointmentId);

                        // Delete failed payment to allow new one
                        await _paymentRepository.DeleteAsync(existingPayment, cancellationToken);
                        await _unitOfWork.SaveChangesAsync(cancellationToken);
                    }
                }

                // 1. Get appointment
                var appointment = await _appointmentRepository.GetByIdAsync(
                    request.AppointmentId,
                    cancellationToken);

                if (appointment == null)
                    throw new NotFoundException("Appointment", request.AppointmentId);

                if (appointment.IsPaid)
                    throw new DomainException("Appointment already paid");

                // 2. Get doctor (for consultation fee)
                var doctor = await _doctorRepository.GetByIdWithUserAsync(
                    appointment.DoctorId,
                    cancellationToken);

                if (doctor == null)
                    throw new NotFoundException("Doctor", appointment.DoctorId);

                // 3. Get patient (for billing info)
                var patient = await _patientRepository.GetByIdWithUserAsync(
                    appointment.PatientId,
                    cancellationToken);

                if (patient == null)
                    throw new NotFoundException("Patient", appointment.PatientId);

                // 3.1 Validate User is loaded
                if (patient.User == null)
                {
                    _logger.LogError(
                        "Patient {PatientId} has no associated User account",
                        appointment.PatientId);
                    throw new DomainException("Patient account data not found");
                }

                // 3.2 Validate required fields
                if (string.IsNullOrEmpty(patient.User.Email))
                {
                    _logger.LogError(
                        "Patient {PatientId} has no email",
                        appointment.PatientId);
                    throw new DomainException("Patient email is required for payment");
                }

                if (string.IsNullOrEmpty(patient.User.FullName))
                {
                    _logger.LogError(
                        "Patient {PatientId} has no full name",
                        appointment.PatientId);
                    throw new DomainException("Patient name is required for payment");
                }

                // 4. Create payment entity
                var amount = appointment.ConsultationFee ?? doctor.ConsultationFee;

                var payment = Payment.CreatePending(
                    appointment.Id,
                    appointment.PatientId,
                    appointment.DoctorId,
                    amount,
                    request.PaymentMethod);

                await _paymentRepository.AddAsync(payment, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                // 5. Parse patient name safely
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

                // 6. Create Paymob payment
                var paymobResponse = await _paymobService.CreatePaymentAsync(
                    appointment.Id,
                    amount,
                    request.PaymentMethod,
                    patient.User.Email,
                    patient.User.PhoneNumber ?? "01000000000",
                    firstName,
                    lastName,
                    cancellationToken);

                // 7. Update payment with Paymob order ID
                payment.SetPaymobOrderId(paymobResponse.PaymobOrderId);
                await _paymentRepository.UpdateAsync(payment, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                _logger.LogInformation(
                    "Payment created successfully for appointment {AppointmentId}, Payment URL: {Url}",
                    appointment.Id, paymobResponse.PaymentUrl);

                // 8. Return response
                return new CreatePaymentResponse
                {
                    PaymentUrl = paymobResponse.PaymentUrl,
                    PaymentId = payment.Id,
                    PaymobOrderId = paymobResponse.PaymobOrderId,
                    Amount = amount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error creating payment for appointment {AppointmentId}",
                    request.AppointmentId);
                throw;
            }
        }

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
            CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation(
                    "Processing refund for payment {PaymentId}",
                    request.PaymentId);

                // 1. Get payment
                var payment = await _paymentRepository.GetByIdAsync(
                    request.PaymentId,
                    cancellationToken);

                if (payment == null)
                    throw new NotFoundException("Payment", request.PaymentId);

                // 2. Validate refund eligibility
                if (!payment.CanBeRefunded())
                    throw new DomainException("Payment cannot be refunded");

                // 3. Process refund with Paymob
                var amountCents = request.Amount * 100;

                var paymobRefund = await _paymobService.RefundPaymentAsync(
                    payment.PaymobTransactionId,
                    amountCents,
                    cancellationToken);

                if (!paymobRefund.Success)
                {
                    return new RefundPaymentResponse
                    {
                        Success = false,
                        Message = paymobRefund.Message
                    };
                }

                // 4. Update payment
                payment.MarkAsRefunded(
                    request.Amount,
                    paymobRefund.RefundTransactionId ?? "",
                    request.Reason,
                    request.Notes);

                await _paymentRepository.UpdateAsync(payment, cancellationToken);
                await _unitOfWork.SaveChangesAsync(cancellationToken);

                return new RefundPaymentResponse
                {
                    Success = true,
                    Message = "Refund processed successfully",
                    RefundTransactionId = paymobRefund.RefundTransactionId,
                    RefundedAmount = request.Amount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing refund for payment {PaymentId}", request.PaymentId);
                throw;
            }
        }

        #endregion

        #region Queries

        public async Task<Payment?> GetPaymentByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            return await _paymentRepository.GetByAppointmentIdAsync(
                appointmentId,
                cancellationToken);
        }

        public async Task<List<PaymentHistoryDto>> GetPatientPaymentHistoryAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            var payments = await _paymentRepository.GetPatientPaymentsAsync(
                patientId,
                cancellationToken);

            return payments.Select(p => new PaymentHistoryDto
            {
                PaymentId = p.Id,
                AppointmentId = p.AppointmentId,
                Amount = p.Amount,
                Status = p.Status,
                Method = p.Method,
                PaidAt = p.PaidAt,
                CreatedAt = p.CreatedAt,
                DoctorName = p.Doctor?.User?.FullName ?? "Unknown"
            }).ToList();
        }

        #endregion
    }
}