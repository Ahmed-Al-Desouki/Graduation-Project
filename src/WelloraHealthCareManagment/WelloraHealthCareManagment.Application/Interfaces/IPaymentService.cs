// Application/Interfaces/IPaymentService.cs

using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Application.DTOs.Payment;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IPaymentService
    {
        // Callback Processing
        Task<ProcessCallbackResult> ProcessPaymobCallbackAsync(
            PaymobCallbackRequest callback,
            string hmacHeader,
            CancellationToken cancellationToken = default);

        Task<string> HandlePaymentResultRedirectAsync(
            string? merchantOrderId,
            bool success);

        // Payment Creation
        Task<CreatePaymentResponse> CreatePaymentAsync(
            CreatePaymentRequest request,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default);

        // Refund
        Task<RefundPaymentResponse> RefundPaymentAsync(
            RefundPaymentRequest request,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default);

        // Queries
        Task<Payment?> GetPaymentByAppointmentIdAsync(
            Guid appointmentId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default);

        Task<List<PaymentHistoryDto>> GetPatientPaymentHistoryAsync(
            int patientId,
            int requesterUserId,
            string requesterRole,
            CancellationToken cancellationToken = default);
    }
}
