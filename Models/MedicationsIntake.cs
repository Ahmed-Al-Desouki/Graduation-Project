using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using static HealthCare_.Models.Enums;

namespace HealthCare_.Models
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
        // Removed PatientID, inferred from PrescriptionMed.Prescription.Patient
        [Required]
        public DateTime DateTaken { get; set; } // Combines date and time
        public IntakeStatus Status { get; set; } // Enum for consistency
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
