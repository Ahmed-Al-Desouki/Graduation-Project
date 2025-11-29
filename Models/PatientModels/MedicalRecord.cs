namespace HealthCare_.Models.PatientModels
{
    public class MedicalRecord
    {
        [Key]
        [Required]
        public int RecordID { get; set; }
        [Required]
        public int HistoryID { get; set; } // Now under MedicalHistory
        [ForeignKey("HistoryID")]
        public MedicalHistory MedicalHistory { get; set; }
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }
        [Required]
        public DateTime VisitDate { get; set; }
        [StringLength(500)]
        public string Diagnosis { get; set; }
        [StringLength(500)]
        public string Symptoms { get; set; }
        [StringLength(1000)]
        public string Notes { get; set; }
        public DateTime? NextVisitDate { get; set; }
        [StringLength(100)]
        public string CurrentStatus { get; set; }
        [StringLength(500)]
        public string FilePath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
