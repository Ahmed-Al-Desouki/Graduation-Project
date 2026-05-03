// Domain/Enums/PaymentStatus.cs

namespace WelloraHealthCareManagement.Domain.Enums
{
    public enum PaymentStatus
    {
        Pending = 0,      // Payment created, awaiting user action
        Paid = 1,         // Successfully paid
        Failed = 2,       // Payment failed
        Refunded = 3,     // Fully refunded
        PartialRefund = 4 // Partially refunded
    }
}