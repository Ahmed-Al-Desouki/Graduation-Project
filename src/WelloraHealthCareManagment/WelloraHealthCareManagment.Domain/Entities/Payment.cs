using HealthCare_.Models.DoctorModels;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagement.Domain.Entities
{
    public class Payment : BaseEntity
    {
        public Guid? AppointmentId { get; private set; }
        public int PatientId { get; private set; }
        public int DoctorId { get; private set; }

        // Paymob Transaction Details
        public string PaymobOrderId { get; private set; } = string.Empty;
        public string PaymobTransactionId { get; private set; } = string.Empty;
        public int PaymobIntegrationId { get; private set; }

        // Payment Details
        public decimal Amount { get; private set; }
        public string Currency { get; private set; } = "EGP";
        public PaymentStatus Status { get; private set; }
        public PaymentMethod Method { get; private set; }
        public string? PatientNotes { get; private set; }


        // Timestamps
        public DateTime? PaidAt { get; private set; }
        public DateTime? RefundedAt { get; private set; }
        public DateTime? FailedAt { get; private set; }

        // Refund Details
        public decimal? RefundAmount { get; private set; }
        public string? RefundTransactionId { get; private set; }
        public RefundReason? RefundReason { get; private set; }
        public string? RefundNotes { get; private set; }
        public decimal? RefundPercentage { get; private set; }
        public CancelledBy? RefundInitiatedBy { get; private set; }

        // Failure Details
        public string? FailureReason { get; private set; }

        // Callback Data
        public string? PaymobCallbackData { get; private set; }

        // Temporary link for new flow (Payment before Appointment)
        public Guid? TimeSlotId { get; private set; }
        public bool GrantMedicalHistoryAccess { get; private set; }

        // Navigation Properties
        public Appointment? Appointment { get; private set; }
        public Patient Patient { get; private set; } = null!;
        public Doctor Doctor { get; private set; } = null!;


        private Payment() { }

        // ==================== Factory for old flow (Appointment already exists) ====================
        public static Payment CreatePending(
            Guid? appointmentId,
            int patientId,
            int doctorId,
            decimal amount,
            PaymentMethod method,
            string? patientNotes = null,
            bool grantMedicalHistoryAccess = false)
        {
            if (amount <= 0)
                throw new DomainException("Payment amount must be positive");

            return new Payment
            {
                Id = Guid.NewGuid(),
                AppointmentId = appointmentId,
                TimeSlotId = null,
                PatientId = patientId,
                DoctorId = doctorId,
                Amount = amount,
                Currency = "EGP",
                Status = PaymentStatus.Pending,
                Method = method,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
                PatientNotes = patientNotes,
                GrantMedicalHistoryAccess = grantMedicalHistoryAccess
            };
        }

        // ==================== Factory for new flow (Payment before Appointment) ====================
        public static Payment CreatePendingForSlot(
       Guid timeSlotId,
       int patientId,
       int doctorId,
       decimal amount,
       PaymentMethod method,
       string? patientNotes = null,              
       bool grantMedicalHistoryAccess = false)  
        {
            if (timeSlotId == Guid.Empty)
                throw new DomainException("TimeSlot ID cannot be empty");
            if (amount <= 0)
                throw new DomainException("Payment amount must be positive");

            return new Payment
            {
                Id = Guid.NewGuid(),
                TimeSlotId = timeSlotId,
                AppointmentId = null,
                PatientId = patientId,
                DoctorId = doctorId,
                Amount = amount,
                Currency = "EGP",
                Status = PaymentStatus.Pending,
                Method = method,
                PatientNotes = patientNotes,         
                GrantMedicalHistoryAccess = grantMedicalHistoryAccess, 
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

        // ربط الدفع بالموعد بعد نجاح الدفع (مهمة جداً)
        public void LinkToAppointment(Guid appointmentId)
        {
            if (AppointmentId.HasValue && AppointmentId.Value != Guid.Empty)
                throw new DomainException("Payment already linked to an appointment");

            if (appointmentId == Guid.Empty)
                throw new DomainException("Appointment ID cannot be empty");

            AppointmentId = appointmentId;
        }

        public bool CanBeRefunded()
        {
            if (Status != PaymentStatus.Paid) return false;
            if (Status == PaymentStatus.Refunded) return false;
            if (string.IsNullOrWhiteSpace(PaymobTransactionId)) return false;
            if (PaidAt.HasValue && DateTime.UtcNow > PaidAt.Value.AddDays(30)) return false;
            return true;
        }

        public void MarkAsRefunded(
            decimal refundAmount,
            decimal refundPercentage,
            string refundTransactionId,
            RefundReason reason,
            CancelledBy initiatedBy,
            string? notes = null)
        {
            if (!CanBeRefunded())
                throw new InvalidOperationException("Payment cannot be refunded in its current state");

            if (refundAmount <= 0 || refundAmount > Amount)
                throw new ArgumentException($"Invalid refund amount. Must be between 0 and {Amount}");

            if (refundPercentage < 0 || refundPercentage > 100)
                throw new ArgumentException("Refund percentage must be between 0 and 100");

            if (string.IsNullOrWhiteSpace(refundTransactionId))
                throw new ArgumentException("Refund transaction ID is required");

            Status = PaymentStatus.Refunded;
            RefundAmount = refundAmount;
            RefundPercentage = refundPercentage;
            RefundTransactionId = refundTransactionId;
            RefundReason = reason;
            RefundInitiatedBy = initiatedBy;
            RefundNotes = notes;
            RefundedAt = DateTime.UtcNow;
        }

        public static decimal CalculateRefundAmount(decimal paidAmount, decimal refundPercentage)
        {
            if (refundPercentage < 0 || refundPercentage > 100)
                throw new ArgumentException("Refund percentage must be between 0 and 100");
            return Math.Round(paidAmount * (refundPercentage / 100), 2);
        }

        public bool IsEligibleForRefund(DateTime appointmentDateTime, int minimumHoursBeforeAppointment = 24)
        {
            if (!CanBeRefunded()) return false;
            var hoursUntilAppointment = (appointmentDateTime - DateTime.UtcNow).TotalHours;
            return hoursUntilAppointment >= minimumHoursBeforeAppointment;
        }
    }
}