// Application/Interfaces/IPaymobService.cs
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Application.DTOs.Payment;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IPaymobService
    {
        Task<CreatePaymentResponse> CreatePaymentAsync(
            Guid appointmentId,
            decimal amount,
            PaymentMethod paymentMethod,
            string patientEmail,
            string patientPhone,
            string patientFirstName,
            string patientLastName,
            CancellationToken cancellationToken = default);

        Task<bool> VerifyCallbackAsync(
            PaymobCallbackRequest callback,
            string hmacFromHeader);

        Task<RefundPaymentResponse> RefundPaymentAsync(
            string transactionId,
            decimal amountCents,
            CancellationToken cancellationToken = default);
    }
}