// File: Models/DTOs/CloudinaryDTO/UploadRequests.cs
using HealthCare_.Models.EnumForModels;
using Microsoft.AspNetCore.Http;

namespace HealthCare_.Models.DTOs.CloudinaryDTO
{
    public class PatientUploadRequest
    {
        public IFormFile File { get; set; } = null!;
        public int? MedicalHistoryId { get; set; }
        public PatientFileCategory Category { get; set; }
        public string? Description { get; set; }
    }

    public class DoctorUploadRequest
    {
        public IFormFile File { get; set; } = null!;
        public DoctorFileCategory Category { get; set; }
        public string? Description { get; set; }
    }

    public class UploadFileResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public ExternalFile? File { get; set; }
        public string? Error { get; set; }
        public int? UploadedById { get; set; }
        public string? UploadedByRole { get; set; }
    }
}