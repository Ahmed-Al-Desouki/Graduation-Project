namespace HealthCare_.Models.DTOs.PatientDot
{
    public class MedicalRecordDto
    {
        public int RecordID { get; set; }
        public DateTime VisitDate { get; set; }
        public string DoctorName { get; set; } = string.Empty;
        public string Diagnosis { get; set; } = string.Empty;
        public string Symptoms { get; set; } = string.Empty;

        public string Notes { get; set; } = string.Empty;
        public string CurrentStatus { get; set; } = string.Empty;

        public List<PrescriptionMedDto> Medications { get; set; } = new();
    }

    public class PrescriptionMedDto
    {
        public string MedicationName { get; set; } = string.Empty;
        public string Dosage { get; set; } = string.Empty;
        public string? Instructions { get; set; }
    }
}
