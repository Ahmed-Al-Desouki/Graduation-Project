// File: Models/PatientModels/MedicalHistory.cs
using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace HealthCare_.Models.PatientModels.MedicalHistoryModels
{
    public class MedicalHistory
    {
        [Key]
        public int HistoryID { get; set; }

        [Required]
        public int PatientID { get; set; }

        [ForeignKey("PatientID")]
        public Patient Patient { get; set; } = null!;

        // === البيانات الشخصية (من Patient) ===
        public DateTime? DateOfBirth { get; set; }
        public string Gender { get; set; } = "Unknown";
        public string? CurrentLocation { get; set; }

        // === البيانات الطبية ===
        public string? BloodType { get; set; }

        // سيتم حفظها كـ JSON في الداتابيز
        [Column(TypeName = "nvarchar(max)")]
        public string? AllergiesJson { get; set; }

        [Column(TypeName = "nvarchar(max)")]
        public string? ChronicConditionsJson { get; set; }

        [JsonIgnore]
        public List<string> Allergies
        {
            get => string.IsNullOrEmpty(AllergiesJson)
                ? new List<string>()
                : JsonSerializer.Deserialize<List<string>>(AllergiesJson)!;
            set => AllergiesJson = value == null || value.Count == 0
                ? null
                : JsonSerializer.Serialize(value);
        }

        [JsonIgnore]
        public List<string> ChronicConditions
        {
            get => string.IsNullOrEmpty(ChronicConditionsJson)
                ? new List<string>()
                : JsonSerializer.Deserialize<List<string>>(ChronicConditionsJson)!;
            set => ChronicConditionsJson = value == null || value.Count == 0
                ? null
                : JsonSerializer.Serialize(value);
        }

        [Range(0, 300)]
        public double Height { get; set; } // cm

        [Range(0, 500)]
        public double Weight { get; set; } // kg

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation Properties
        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();
        public ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();
        public ICollection<Surgery> Surgeries { get; set; } = new List<Surgery>();
        public ICollection<FamilyHistoryEntry> FamilyHistories { get; set; } = new List<FamilyHistoryEntry>();
        public ICollection<SocialHistory> SocialHistories { get; set; } = new List<SocialHistory>();
        public ICollection<PatientSelfMedication> SelfMedications { get; set; } = new List<PatientSelfMedication>();
    }
}