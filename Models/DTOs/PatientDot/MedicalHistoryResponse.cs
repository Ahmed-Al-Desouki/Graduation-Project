namespace HealthCare_.Models.DTOs.PatientDot
{
    public class MedicalHistoryResponse
    {
        public int HistoryID { get; set; }
        public int PatientID { get; set; }
        public string? BloodType { get; set; }
        public string? Allergies { get; set; }
        public string? ChronicConditions { get; set; }
        public double? Height { get; set; }
        public double? Weight { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public List<ExternalFileResponse> Files { get; set; } = new();
    }

    public class ExternalFileResponse
    {
        public int FileID { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public string FileType { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public string Category { get; set; } = string.Empty;
        public DateTime UploadedAt { get; set; }
    }

    // لعرض كل بيانات المريض
    public class PatientProfileResponse
    {
        public int PatientID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public string Gender { get; set; } = "Unknown";
        public string? CurrentLocation { get; set; }
        public string? ProfileImageUrl { get; set; }

        public MedicalHistoryResponse? MedicalHistory { get; set; }

        // في المستقبل: سيتم إضافة الحجوزات والوصفات هنا
        // public List<AppointmentSummary> UpcomingAppointments { get; set; } = new();
        // public List<PrescriptionSummary> ActivePrescriptions { get; set; } = new();
    }
}
