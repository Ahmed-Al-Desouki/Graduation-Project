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
        // واحد من الاتنين لازم ييجي (مش الاتنين مع بعض)
        public Guid? AppointmentId { get; set; }     // للحالات القديمة أو المتابعة
        public Guid? TimeSlotId { get; set; }        // ← الجديد: للحجز العادي (الأساسي دلوقتي)

        public int PatientId { get; set; }           // مهم جداً للتدفق الجديد
        public PaymentMethod PaymentMethod { get; set; }

        // اختياري: لو عايز المريض يبعت ملاحظات مع الدفع
        public string? PatientNotes { get; set; }
        public bool GrantMedicalHistoryAccess { get; set; } = false;
    }

    public class CreatePaymentResponse
    {
        public string PaymentUrl { get; set; } = string.Empty;
        public Guid PaymentId { get; set; }
        public string PaymobOrderId { get; set; } = string.Empty;
        public decimal Amount { get; set; }
    }
}
