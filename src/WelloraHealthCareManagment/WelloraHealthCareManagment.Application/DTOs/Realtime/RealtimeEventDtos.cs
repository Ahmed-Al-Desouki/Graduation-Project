using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Realtime
{
    public class AppointmentRealtimeDto
    {
        public Guid AppointmentId { get; set; }
        public Guid TimeSlotId { get; set; }
        public int DoctorId { get; set; }
        public int PatientId { get; set; }
        public AppointmentStatus Status { get; set; }
        public bool IsPaid { get; set; }
        public string? CancellationReason { get; set; }
        public DateTime BookedAt { get; set; }
        public DateTime? ConfirmedAt { get; set; }
        public DateTime? StartedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime? CancelledAt { get; set; }
    }

    public class SlotRealtimeDto
    {
        public Guid SlotId { get; set; }
        public int DoctorId { get; set; }
        public Guid? AppointmentId { get; set; }
        public SlotStatus Status { get; set; }
        public DateTime SlotDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public bool IsManuallyCreated { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class PaymentRealtimeDto
    {
        public Guid PaymentId { get; set; }
        public Guid? AppointmentId { get; set; }
        public Guid? TimeSlotId { get; set; }
        public int PatientId { get; set; }
        public int DoctorId { get; set; }
        public decimal Amount { get; set; }
        public PaymentMethod Method { get; set; }
        public PaymentStatus Status { get; set; }
        public string? PaymobOrderId { get; set; }
        public string? FailureReason { get; set; }
        public decimal? RefundAmount { get; set; }
        public DateTime? PaidAt { get; set; }
        public DateTime? RefundedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class ScheduleRealtimeDto
    {
        public int DoctorId { get; set; }
        public string ChangeType { get; set; } = string.Empty;
        public string? DayOfWeek { get; set; }
        public DateTime? Date { get; set; }
        public string? Reason { get; set; }
        public DateTime OccurredAt { get; set; }
    }

    public class MedicalAccessRealtimeDto
    {
        public Guid AppointmentId { get; set; }
        public int DoctorId { get; set; }
        public int PatientId { get; set; }
        public Guid? AccessGrantId { get; set; }
        public string ChangeType { get; set; } = string.Empty;
        public bool CanViewMedicalHistory { get; set; }
        public bool CanViewPrescriptions { get; set; }
        public bool CanViewLabResults { get; set; }
        public DateTime? ExpiresAt { get; set; }
    }

    public class DoctorVerificationRealtimeDto
    {
        public int DoctorId { get; set; }
        public bool IsActive { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? RejectionReason { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class PrescriptionRealtimeDto
    {
        public Guid PrescriptionId { get; set; }
        public Guid AppointmentId { get; set; }
        public int DoctorId { get; set; }
        public int PatientId { get; set; }
        public int ItemCount { get; set; }
        public DateTime IssuedAt { get; set; }
        public DateTime? ValidUntil { get; set; }
    }

    public class MedicalRecordRealtimeDto
    {
        public Guid MedicalRecordId { get; set; }
        public Guid AppointmentId { get; set; }
        public int DoctorId { get; set; }
        public int PatientId { get; set; }
        public bool FollowUpRequired { get; set; }
        public DateTime? FollowUpDate { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
