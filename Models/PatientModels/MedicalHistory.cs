



namespace HealthCare_.Models.PatientModels
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
        public string? BloodType { get; set; }
        [StringLength(500)]
        public string? Allergies { get; set; }
        [StringLength(500)]
        public string? ChronicConditions { get; set; }
        [Range(0, 300)]
        public double Height { get; set; }
        [Range(0, 500)]
        public double Weight { get; set; }
        [StringLength(500)]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // External files (Lab tests, Radiology...) stored externally; use FileCategory to differentiate.
        public ICollection<ExternalFile>? Files { get; set; } = new List<ExternalFile>();

        public ICollection<MedicalRecord>? MedicalRecords { get; set; }
    }
}
