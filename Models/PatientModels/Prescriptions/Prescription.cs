namespace HealthCare_.Models.PatientModels.Prescriptions
{
    public class Prescription
    {
        [Key]
        [Required]
        public int PrescriptionID { get; set; }

        [Required]
        public int PatientID { get; set; }

        [ForeignKey("PatientID")]
        public Patient Patient { get; set; }

        [Required]
        public int DoctorID { get; set; }

        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }

        [Required]
        public DateTime PrescriptionDate { get; set; }

        public DateTime? EndDate { get; set; } // Applies to all medications, optional override per Medication

        [StringLength(500)]
        public string GeneralInstructions { get; set; } // Instructions for the whole prescription

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; // Added CreatedAt property

        public DateTime? UpdatedAt { get; set; } // Optional, for consistency with other models

        public ICollection<PrescriptionMed> Medications { get; set; } = new List<PrescriptionMed>();
    }
}