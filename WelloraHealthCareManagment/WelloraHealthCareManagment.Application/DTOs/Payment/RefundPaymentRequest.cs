using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class RefundPaymentRequest
    {
        public Guid PaymentId { get; set; }
        public decimal Amount { get; set; }
        public RefundReason Reason { get; set; }
        public string? Notes { get; set; }
    }

    public class RefundPaymentResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string? RefundTransactionId { get; set; }
        public decimal RefundedAmount { get; set; }
    }
}
