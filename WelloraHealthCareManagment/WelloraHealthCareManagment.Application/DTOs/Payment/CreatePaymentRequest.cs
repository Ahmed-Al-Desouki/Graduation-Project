using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class CreatePaymentRequest
    {
        public Guid AppointmentId { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
    }

    public class CreatePaymentResponse
    {
        public string PaymentUrl { get; set; } = string.Empty;
        public Guid PaymentId { get; set; }
        public string PaymobOrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }
}
