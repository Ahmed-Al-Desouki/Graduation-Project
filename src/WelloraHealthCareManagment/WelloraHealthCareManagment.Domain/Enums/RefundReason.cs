// Domain/Enums/RefundReason.cs

namespace WelloraHealthCareManagement.Domain.Enums
{
    public enum RefundReason
    {
        PatientCancellation = 0,  // Patient cancelled
        DoctorCancellation = 1,   // Doctor cancelled
        DoctorDayOff = 2,         // Doctor took day off
        SystemError = 3,          // Technical issue
        DuplicatePayment = 4,     // Paid twice by mistake
        Other = 5
    }
}