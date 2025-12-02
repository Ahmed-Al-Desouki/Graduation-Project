namespace HealthCare_.Models.PatientModels
{
    public class PatientSelfMedication
    {
        public int ID { get; set; }
        public int PatientID { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string? Dosage { get; set; }
        public string? Instructions { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public Patient Patient { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }

    }

}
