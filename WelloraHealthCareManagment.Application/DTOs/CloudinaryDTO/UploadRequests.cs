// File: Models/DTOs/CloudinaryDTO/UploadRequests.cs
using Microsoft.AspNetCore.Http;
using WelloraHealthCareManagment.Domain.EnumForModels;

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
        public string? Message { get; set; }
        public string? Error { get; set; }
        public ExternalFile? File { get; set; }
        public int? UploadedById { get; set; }
        public string? UploadedByRole { get; set; }

        public static UploadFileResponse Successful(ExternalFile file, int uploadedById, string role)
        {
            return new UploadFileResponse
            {
                Success = true,
                Message = "File uploaded successfully",
                File = file,
                UploadedById = uploadedById,
                UploadedByRole = role
            };
        }

        public static UploadFileResponse Failed(string error)
        {
            return new UploadFileResponse
            {
                Success = false,
                Error = error
            };
        }
    }
}