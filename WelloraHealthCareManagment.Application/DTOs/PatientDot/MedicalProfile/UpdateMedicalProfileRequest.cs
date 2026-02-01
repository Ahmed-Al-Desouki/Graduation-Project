namespace HealthCare_.Models.DTOs.PatientDot.MedicalProfile
{
    public class UpdateMedicalProfileCommand
    {
        public string? BloodType { get; set; }
        public List<string>? Allergies { get; set; }
        public List<string>? ChronicConditions { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CurrentLocation { get; set; }
    }
    // Requests (create / update)
    public class CreateSurgeryRequest
    {
        public int HistoryID { get; set; }
        public int? SurgeryID { get; set; } // nullable عشان Upsert
        public string Name { get; set; } = string.Empty;
        public DateTime? Date { get; set; }
        public string? Notes { get; set; }
        public string? Complications { get; set; }
    }

    public class UpsertSurgeryCommand
    {
        public int HistoryID { get; set; }
        public int? SurgeryID { get; set; }
        public string? Name { get; set; }
        public DateTime? Date { get; set; }
        public string? Notes { get; set; }
        public string? Complications { get; set; }
    }

    public class CreateFamilyHistoryRequest
    {
        public int HistoryID { get; set; }
        public int? FamilyHistoryID { get; set; }
        public string Condition { get; set; } = string.Empty;
        public string Relative { get; set; } = "Other";
        public int? OnsetAge { get; set; }
        public string? Notes { get; set; }
        public bool IsVerified { get; set; } = false;
    }

    public class UpsertFamilyHistoryCommand
    {
        public int HistoryID { get; set; }
        public int? FamilyHistoryID { get; set; }
        public string? Condition { get; set; }
        public string? Relative { get; set; }
        public int? OnsetAge { get; set; }
        public string? Notes { get; set; }
        public bool IsVerified { get; set; }
    }

    public class UpsertSocialHistoryCommand
    {
        public int HistoryID { get; set; }
        public string? SmokingStatus { get; set; }
        public string? SmokingDetails { get; set; }
        public string? AlcoholUse { get; set; }
        public string? DrugUse { get; set; }
        public string? Occupation { get; set; }
        public string? Exercise { get; set; }
        public string? Notes { get; set; }
    }

    // Responses
    public class SurgeryDto
    {
        public int SurgeryID { get; set; }
        public int HistoryID { get; set; }
        public string Name { get; set; } = string.Empty;
        public DateTime? Date { get; set; }
        public string? Notes { get; set; }
        public string? Complications { get; set; }
        public string Source { get; set; } = "User";
        public int? AppointmentID { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class FamilyHistoryDto
    {
        public int FamilyHistoryID { get; set; }
        public int HistoryID { get; set; }
        public string Condition { get; set; } = string.Empty;
        public string Relative { get; set; } = "Other";
        public int? OnsetAge { get; set; }
        public string? Notes { get; set; }
        public bool IsVerified { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class SocialHistoryDto
    {
        public int SocialHistoryID { get; set; }
        public int HistoryID { get; set; }
        public string SmokingStatus { get; set; } = "Never";
        public string? SmokingDetails { get; set; }
        public string AlcoholUse { get; set; } = "None";
        public string? DrugUse { get; set; }
        public string? Occupation { get; set; }
        public string? Exercise { get; set; }
        public string? Notes { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

    public class UpsertSelfMedicationCommand
    {
        public int HistoryID { get; set; }
        public int? SelfMedicationID { get; set; }
        public int PatientId { get; set; }
        public string? MedicationName { get; set; }
        public string? Dosage { get; set; }
        public string? Instructions { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
