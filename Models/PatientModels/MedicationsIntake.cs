// File: Models/PatientModels/MedicationsIntake.cs
namespace HealthCare_.Models.PatientModels
{
    public class MedicationsIntake
    {
        [Key]
        [Required]
        public int IntakeID { get; set; }

        [Required]
        public int PrescriptionMedID { get; set; }
        [ForeignKey("PrescriptionMedID")]
        public PrescriptionMed PrescriptionMed { get; set; } = null!;

        [Required]
        public DateTime DateTaken { get; set; }

        public Enums.IntakeStatus Status { get; set; } = Enums.IntakeStatus.Taken;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // جديد: ربط بالـ instance
        public int? ReminderInstanceID { get; set; }
        //[ForeignKey(nameof(ReminderInstanceID))]
        //public ReminderInstance? ReminderInstance { get; set; }
    }
}