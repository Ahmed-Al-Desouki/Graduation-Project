using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models
{
    public class MedicalHistory
    {
        [Key]
        [Required]
        public int HistoryID { get; set; }
        [Required]
        public int PatientID { get; set; }
        [ForeignKey("PatientID")]
        public Patient Patient { get; set; }
        [StringLength(10)]
        public string BloodType { get; set; }
        [StringLength(500)]
        public string Allergies { get; set; }
        [StringLength(500)]
        public string ChronicConditions { get; set; }
        [Range(0, 300)]
        public double Height { get; set; }
        [Range(0, 500)]
        public double Weight { get; set; }
        [StringLength(500)]
        public string FilePath { get; set; } // General
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<Attachment> LabTests { get; set; }
        public ICollection<Attachment> Radiology { get; set; }
        public ICollection<MedicalRecord> MedicalRecords { get; set; } // Merged

    }
}
