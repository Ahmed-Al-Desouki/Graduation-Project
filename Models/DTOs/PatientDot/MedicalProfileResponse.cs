// Models/DTOs/PatientDTO/MedicalProfileDtos.cs

using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.EnumForModels;

namespace HealthCare_.Models.DTOs.PatientDTO
{
    public class MedicalProfileResponse
    {
        public int PatientID { get; set; }
        public int MedicalHistoryID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }

        public DateTime DateOfBirth { get; set; }
        public int Age
        {
            get
            {
                if (DateOfBirth == default) return 0;

                var today = DateTime.Today;
                var age = today.Year - DateOfBirth.Year;

                if (DateOfBirth > today.AddYears(-age)) age--;

                return age;
            }
        }

        public string Gender { get; set; } = "Unknown";
        public string? CurrentLocation { get; set; }

        public string? BloodType { get; set; }
        public List<string> Allergies { get; set; } = new();
        public List<string> ChronicConditions { get; set; } = new();
        public double Height { get; set; }
        public double Weight { get; set; }

        public List<FileDto> LabTests { get; set; } = new();
        public List<FileDto> RadiologyFiles { get; set; } = new();

        public List<PastAppointmentDto> PastAppointments { get; set; } = new();
        public List<MedicalRecordDto> MedicalRecords { get; set; } = new();
    }

    public class FileDto
    {
        public int FileID { get; set; }
        public string FileUrl { get; set; } = string.Empty;
        public string FileType { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public DateTime UploadedAt { get; set; }
        public string? Description { get; set; }
    }

    public class PastAppointmentDto
    {
        public int AppointmentID { get; set; }
        public DateTime AppointmentDate { get; set; }
        public string DoctorName { get; set; } = string.Empty;
        public string Specialty { get; set; } = string.Empty;
        public string Symptoms { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public PrescriptionSummaryDto? Prescription { get; set; }
    }

    public class PrescriptionSummaryDto
    {
        public int PrescriptionID { get; set; }
        public DateTime PrescriptionDate { get; set; }
        public string GeneralInstructions { get; set; } = string.Empty;
        public List<MedicationDto> Medications { get; set; } = new();
    }

    public class MedicationDto
    {
        public string MedicationName { get; set; } = string.Empty;
        public string Dosage { get; set; } = string.Empty;
        public string Instructions { get; set; } = string.Empty;
    }


    // Request
    public class UpdateMedicalProfileRequest
    {
        public string? BloodType { get; set; }
        public List<string>? Allergies { get; set; }
        public List<string>? ChronicConditions { get; set; }
        public double? Height { get; set; }
        public double? Weight { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? CurrentLocation { get; set; }
    }
}