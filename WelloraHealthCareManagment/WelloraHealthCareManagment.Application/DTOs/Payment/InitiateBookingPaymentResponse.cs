using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Payment
{
    public class InitiateBookingPaymentResponse
    {
        public Guid PaymentId { get; set; }
        public string PaymentUrl { get; set; } = string.Empty;
        public string PaymobOrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
        public Guid TimeSlotId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan AppointmentTime { get; set; }
        public string DoctorName { get; set; } = string.Empty;
    }
}
