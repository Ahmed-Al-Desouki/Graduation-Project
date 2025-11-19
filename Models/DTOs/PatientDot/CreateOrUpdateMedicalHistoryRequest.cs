
using HealthCare_.Models.DTOs.CloudinaryDTO;

namespace HealthCare_.Models.DTOs.PatientDot
{
    public class CreateOrUpdateMedicalHistoryRequest
    {
        // البيانات الأساسية
        public int? MedicalHistoryId { get; set; }
        public string? BloodType { get; set; }
        public string? Allergies { get; set; }
        public string? ChronicConditions { get; set; }
        public double? Height { get; set; }
        public double? Weight { get; set; }
        public List<FileWithCategory>? Files { get; set; }
    }

    public class FileWithCategory
    {
        public IFormFile File { get; set; } = null!;
        public PatientFileCategory Category { get; set; }
    }
}