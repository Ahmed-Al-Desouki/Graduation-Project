using Microsoft.AspNetCore.Http;
using static HealthCare_.Models.Enums.Enums;
namespace HealthCare_.Models.DTOs.Cloudinary
{
    public class UploadFileRequest
    {
        public IFormFile File { get; set; }
        public int? DoctorId { get; set; }
        public int? PatientId { get; set; }
        public int? MedicalHistoryId { get; set; }
        public ExternalFileCategory Category { get; set; } = ExternalFileCategory.Other;
    }
}
