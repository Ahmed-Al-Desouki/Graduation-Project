using HealthCare_.Models.Patient;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models
{
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
        public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
    }
}
