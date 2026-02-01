// File: Models/V2/ReminderV2.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using HealthCare_.Models.PatientModels.Appointments;
using HealthCare_.Models.PatientModels.Prescriptions;
using WelloraHealthCareManagment.Domain.EnumForModels;

namespace HealthCare_.Models.V2
{
    public class ReminderV2
    {
        [Key]
        public int Id { get; set; }

        public int PatientId { get; set; }

        public Enums.ReminderType Type { get; set; } = Enums.ReminderType.Medication;

        [StringLength(150)]
        public string Title { get; set; } = "Taking medication";

        [StringLength(500)]
        public string? Message { get; set; }

        // جميع التواريخ الآن UTC
        public DateTime StartDateUtc { get; set; } = DateTime.UtcNow;
        public DateTime? EndDateUtc { get; set; } // null = مدى الحياة

        // RRULE / EXDATE يعتمد على UTC داخليًا
        public string? RRULE { get; set; } = "FREQ=DAILY";
        public string? EXDATE { get; set; }

        // TimeZone للمريض / التذكير
        public string TimeZoneId { get; set; } = "Africa/Cairo";

        // روابط
        public int? PrescriptionMedId { get; set; }
        public PrescriptionMed? PrescriptionMed { get; set; }

        public int? AppointmentId { get; set; }
        public Appointment? Appointment { get; set; }

        // حالة عامة
        public bool IsActive { get; set; } = true;
        public Enums.ReminderStatus Status { get; set; } = Enums.ReminderStatus.Active;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public ICollection<ReminderOccurrenceLog> Logs { get; set; } = new List<ReminderOccurrenceLog>();
        public bool IsSimpleEveryXHours { get; set; } = false;
        public TimeSpan? FirstDoseTime { get; set; }   // Local time للعرض
        public int? IntervalHours { get; set; }        // للـ EveryXHours
    }
}
