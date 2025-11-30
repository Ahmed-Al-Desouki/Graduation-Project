// File: Models/V2/ReminderV2.cs
using System.ComponentModel.DataAnnotations;
namespace HealthCare_.Models.V2
{
        public class ReminderV2
        {
            [Key]
            public int Id { get; set; }

            public int PatientId { get; set; }

            public ReminderType Type { get; set; } = ReminderType.Medication;

            [StringLength(150)]
            public string Title { get; set; } = "Taking medication";

            [StringLength(500)]
            public string? Message { get; set; }

            public DateTime StartDate { get; set; } = DateTime.Today;

            public DateTime? EndDate { get; set; } // null = مدى الحياة

            // القاعدة السحرية
            public string RRULE { get; set; } = "FREQ=DAILY"; // iCal RFC-5545

            public string? EXDATE { get; set; } // استثناءات: 2025-04-01T00:00:00Z,2025-04-01T00:00:00Z

            public TimeSpan? BaseTime { get; set; } // للـ Simple cases (كل يوم 8 الصبح)

            public string TimeZoneId { get; set; } = "Africa/Cairo";

            // روابط
            public int? PrescriptionMedId { get; set; }
            public PrescriptionMed? PrescriptionMed { get; set; }  // مهم جدًا

            public int? AppointmentId { get; set; }
            public Appointment? Appointment { get; set; }

            // حالة عامة
            public bool IsActive { get; set; } = true;
            public ReminderStatus Status { get; set; } = ReminderStatus.Active;

            public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
            public DateTime? UpdatedAt { get; set; }

            // Navigation
            public ICollection<ReminderOccurrenceLog> Logs { get; set; } = new List<ReminderOccurrenceLog>();
        }
    
}
