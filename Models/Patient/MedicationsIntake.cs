using HealthCare_.Models.Patient;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using static HealthCare_.Models.Enums.Enums;

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
        [Required]
        public DateTime DateTaken { get; set; } // Combines date and time
        public IntakeStatus Status { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
