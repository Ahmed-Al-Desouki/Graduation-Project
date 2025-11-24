namespace HealthCare_.Models.DTOs.PatientDot
{
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
