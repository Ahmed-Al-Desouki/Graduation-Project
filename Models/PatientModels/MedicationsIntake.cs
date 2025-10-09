
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
        public PrescriptionMed PrescriptionMed { get; set; }
        [Required]
        public DateTime DateTaken { get; set; } // Combines date and time
        public IntakeStatus Status { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
