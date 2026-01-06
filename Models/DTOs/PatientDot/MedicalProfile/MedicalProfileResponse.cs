// Models/DTOs/PatientDTO/MedicalProfileDtos.cs


// Models/DTOs/PatientDTO/MedicalProfileDtos.cs

namespace HealthCare_.Models.DTOs.PatientDot.MedicalProfile
{
    public class MedicalProfileResponse
    {
        public int PatientID { get; set; }
        public int MedicalHistoryID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }

        public DateTime? DateOfBirth { get; set; }
        public int Age
        {
            get
            {
                if (!DateOfBirth.HasValue) return 0;

                var today = DateTime.Today;
                var age = today.Year - DateOfBirth.Value.Year;

                if (DateOfBirth.Value > today.AddYears(-age)) age--;

                return age;
            }
        }


        public string Gender { get; set; } = "Unknown";
        public string? CurrentLocation { get; set; }

        public string? BloodType { get; set; }
        public List<string>? Allergies { get; set; } = new();
        public List<string>? ChronicConditions { get; set; } = new();
        public double Height { get; set; }
        public double Weight { get; set; }

        public List<FileDto>? LabTests { get; set; } = new();
        public List<FileDto>? RadiologyFiles { get; set; } = new();

        public List<PastAppointmentDto>? PastAppointments { get; set; } = new();
        public List<MedicalRecordDto>? MedicalRecords { get; set; } = new();
        public List<SurgeryDto>? Surgeries { get; set; } = new();
        public List<FamilyHistoryDto>? FamilyHistory { get; set; } = new();
        public List<SocialHistoryDto>? SocialHistory { get; set; } = new();
        public List<CurrentMedicationDto>? CurrentMedications { get; set; } = new();
        public List<SelfMedicationDto>? PatientSelfMedications { get; set; } = new();

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
        public List<CurrentMedicationDto> Medications { get; set; } = new();
    }

    public class CurrentMedicationDto
    {
        public int CurrentMedicationID { get; set; } // PrescriptionMed.ID
        public int HistoryID { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string? Dosage { get; set; } // dosage field
        public string? Doseinstruction { get; set; } // specific dose instruction
        public string? Frequency { get; set; } // readable frequency / schedule summary
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Notes { get; set; }
        public bool IsOverTheCounter { get; set; } = false; // optional
    }

    public class SelfMedicationDto
    {
        public int ID { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string? Dosage { get; set; }
        public string? Instructions { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

}