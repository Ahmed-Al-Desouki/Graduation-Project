// File: Models/PatientModels/Reminder.cs
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

using HealthCare_.Models.SharedModels;
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.EnumForModels;

namespace HealthCare_.Models.PatientModels
{
    [Table("Reminders")]
    public class Reminder
    {
        [Key]
        [Required]
        public int ReminderID { get; set; }

        [Required]
        public int PatientID { get; set; }
        [ForeignKey(nameof(PatientID))]
        public Patient Patient { get; set; } = null!;

        [Required]
        public Enums.ReminderType Type { get; set; }

        [StringLength(100)]
        public string? Name { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        [Required]
        public Enums.RepeatFrequency Frequency { get; set; }

        public int? IntervalHours { get; set; }

        [Required]
        public TimeSpan BaseTime { get; set; }

        [StringLength(500)]
        public string? Message { get; set; }

        public Enums.ReminderStatus Status { get; set; } = Enums.ReminderStatus.Pending;

        public bool IsActive { get; set; } = true;

        public int? PrescriptionMedID { get; set; }
        [ForeignKey("PrescriptionMedID")]
        public PrescriptionMed? PrescriptionMed { get; set; }

        public int? AppointmentID { get; set; }
        [ForeignKey("AppointmentID")]
        public Appointment? Appointment { get; set; }

        public bool IsLocalNotification { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<ReminderInstance> Instances { get; set; } = new List<ReminderInstance>();
    }
}