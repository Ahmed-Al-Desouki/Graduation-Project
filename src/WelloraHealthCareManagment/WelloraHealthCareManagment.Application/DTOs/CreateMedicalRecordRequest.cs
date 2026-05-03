namespace WelloraHealthCareManagment.Application.DTOs
{
    public class CreateMedicalRecordRequest
    {
        public string? ChiefComplaint { get; set; }
        public string? VitalSigns { get; set; } // JSON format: {"bp":"120/80","temp":"37","pulse":"72"}
        public string? PhysicalExamination { get; set; }
        public string Diagnosis { get; set; } = string.Empty;
        public string? DiagnosisCode { get; set; } // ICD-10 code
        public string? TreatmentPlan { get; set; }
        public string? DoctorNotes { get; set; }
        public bool FollowUpRequired { get; set; }
        public DateTime? FollowUpDate { get; set; }
        public string? FollowUpInstructions { get; set; }
    }

    public class UpdateMedicalRecordRequest : CreateMedicalRecordRequest
    {
        // Same fields, but all optional for partial updates
    }
}