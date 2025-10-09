using HealthCare_.Models.shared;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using static HealthCare_.Models.Enums.Enums;

namespace HealthCare_.Models.Patient
{
    public class Reminder
    {
        [Key]
        [Required]
        public int ReminderID { get; set; }
        // Removed PatientID, inferred from PrescriptionMed or Appointment
        [Required]
        public ReminderType Type { get; set; } // Enum for reminder type
        [Required]
        public DateTime ReminderDateTime { get; set; }
        [StringLength(500)]
        public string Message { get; set; } // Defaults to medication reminder text
        public ReminderStatus Status { get; set; } // Enum for status
        public int? PrescriptionMedID { get; set; }
        [ForeignKey("PrescriptionMedID")]
        public PrescriptionMed PrescriptionMed { get; set; }
        public int? AppointmentID { get; set; }
        [ForeignKey("AppointmentID")]
        public Appointment Appointment { get; set; }
        // Removed RepeatPattern, handled by DosingSchedules
        public bool IsLocalNotification { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
