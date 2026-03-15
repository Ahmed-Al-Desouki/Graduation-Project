// Domain/Entities/Payment.cs

using HealthCare_.Models.DoctorModels;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class Payment : BaseEntity
    {
        public Guid AppointmentId { get; private set; }
        public int PatientId { get; private set; }
        public int DoctorId { get; private set; }

        // Paymob Transaction Details
        public string PaymobOrderId { get; private set; } = string.Empty; // Paymob order ID
        public string PaymobTransactionId { get; private set; } = string.Empty; // Transaction ID
        public int PaymobIntegrationId { get; private set; } // Which payment method used

        // Payment Details
        public decimal Amount { get; private set; }
        public string Currency { get; private set; } = "EGP";
        public PaymentStatus Status { get; private set; }
        public PaymentMethod Method { get; private set; }

        // Timestamps
        public DateTime? PaidAt { get; private set; }
        public DateTime? RefundedAt { get; private set; }
        public DateTime? FailedAt { get; private set; }

        // Refund Details
        public decimal? RefundAmount { get; private set; }
        public string? RefundTransactionId { get; private set; }
        public RefundReason? RefundReason { get; private set; }
        public string? RefundNotes { get; private set; }

        // Failure Details
        public string? FailureReason { get; private set; }

        // Callback Data (for debugging)
        public string? PaymobCallbackData { get; private set; }

        // Navigation Properties
        public Appointment Appointment { get; private set; } = null!;
        public Patient Patient { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;

        private Payment() { }

        public static Payment CreatePending(
            Guid appointmentId,
            int patientId,
            int doctorId,
            decimal amount,
            PaymentMethod method)
        {
            if (amount <= 0)
                throw new DomainException("Payment amount must be positive");

            return new Payment
            {
                Id = Guid.NewGuid(),
                AppointmentId = appointmentId,
                PatientId = patientId,
                DoctorId = doctorId,
                Amount = amount,
                Currency = "EGP",
                Status = PaymentStatus.Pending,
                Method = method,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        public void SetPaymobOrderId(string orderId)
        {
            if (string.IsNullOrWhiteSpace(orderId))
                throw new DomainException("Order ID cannot be empty");

            PaymobOrderId = orderId;
        }

        public void MarkAsPaid(string transactionId, int integrationId, string? callbackData = null)
        {
            if (Status == PaymentStatus.Paid)
                throw new DomainException("Payment already marked as paid");

            Status = PaymentStatus.Paid;
            PaymobTransactionId = transactionId;
            PaymobIntegrationId = integrationId;
            PaidAt = DateTime.UtcNow;
            PaymobCallbackData = callbackData;
        }

        public void MarkAsFailed(string reason, string? callbackData = null)
        {
            Status = PaymentStatus.Failed;
            FailureReason = reason;
            FailedAt = DateTime.UtcNow;
            PaymobCallbackData = callbackData;
        }

        public void MarkAsRefunded(
            decimal refundAmount,
            string refundTransactionId,
            RefundReason reason,
            string? notes = null)
        {
            if (Status != PaymentStatus.Paid)
                throw new DomainException("Can only refund paid payments");

            if (refundAmount > Amount)
                throw new DomainException("Refund amount cannot exceed payment amount");

            Status = PaymentStatus.Refunded;
            RefundAmount = refundAmount;
            RefundTransactionId = refundTransactionId;
            RefundReason = reason;
            RefundNotes = notes;
            RefundedAt = DateTime.UtcNow;
        }

        public bool CanBeRefunded()
        {
            return Status == PaymentStatus.Paid
                && !RefundedAt.HasValue
                && PaidAt.HasValue
                && PaidAt.Value.AddDays(30) > DateTime.UtcNow; // 30-day refund window
        }
    }
}