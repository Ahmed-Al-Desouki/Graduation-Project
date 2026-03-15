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
            CancellationToken cancellationToken = default);

        // Refund
        Task<RefundPaymentResponse> RefundPaymentAsync(
            RefundPaymentRequest request,
            CancellationToken cancellationToken = default);

        // Queries
        Task<Payment?> GetPaymentByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        Task<List<PaymentHistoryDto>> GetPatientPaymentHistoryAsync(
            int patientId,
            CancellationToken cancellationToken = default);
    }
}