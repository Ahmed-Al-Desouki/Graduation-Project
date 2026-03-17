// File: Models/V2/ReminderV2.cs
using HealthCare_.Models.DoctorModels;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace HealthCare_.Models.V2
{
    public class ReminderV2
    {
        [Key]
        public int Id { get; set; }

        public int? PatientId { get; set; }
        public int? DoctorId { get; set; }
        public Guid? PrescriptionItemId { get; set; }
        public Guid? PrescriptionId { get; set; }

        public ReminderEnums.ReminderType Type { get; set; } = ReminderEnums.ReminderType.Medication;

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
        public PrescriptionItem? PrescriptionItem { get; set; }

        public Prescription? Prescription { get; set; }

        public Guid? AppointmentId { get; set; }

        // حالة عامة
        public bool IsActive { get; set; } = true;
        public ReminderEnums.ReminderStatus Status { get; set; } = ReminderEnums.ReminderStatus.Active;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }


        // Navigation Property
        public Patient? Patient { get; set; }
        public Doctor? Doctor { get; set; }
        public Appointment? Appointment { get; set; } // ✅ New
        public ICollection<ReminderOccurrenceLog> Logs { get; set; } = new List<ReminderOccurrenceLog>();
        public bool IsSimpleEveryXHours { get; set; } = false;
        public TimeSpan? FirstDoseTime { get; set; }   // Local time للعرض
        public int? IntervalHours { get; set; }        // للـ EveryXHours
    }
}
