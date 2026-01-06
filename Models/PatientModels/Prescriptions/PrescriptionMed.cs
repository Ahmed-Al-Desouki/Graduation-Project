using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using HealthCare_.Models.V2;

namespace HealthCare_.Models.PatientModels.Prescriptions
{
    [Table("PrescriptionMeds")]
    public class PrescriptionMed
    {
        [Key]
        [Required]
        public int ID { get; set; }
        [Required]
        public int PrescriptionID { get; set; }
        [ForeignKey("PrescriptionID")]
        public Prescription Prescription { get; set; }
        [Required, StringLength(100)]
        public string MedicationName { get; set; }
        [StringLength(50)]
        public string Dosage { get; set; } // e.g., "500mg"
        public ICollection<DosingSchedule> DosingSchedules { get; set; } = new List<DosingSchedule>();
        public DateTime? StartDate { get; set; } // Optional, defaults to PrescriptionDate if null
        public DateTime? EndDate { get; set; } // Optional override per medication
        [StringLength(500)]
        public string Instructions { get; set; } // Specific instructions for this medication
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<MedicationsIntake> MedicationsIntakes { get; set; }
        public ICollection<ReminderV2> Reminders { get; set; } = new List<ReminderV2>();
    }
}
