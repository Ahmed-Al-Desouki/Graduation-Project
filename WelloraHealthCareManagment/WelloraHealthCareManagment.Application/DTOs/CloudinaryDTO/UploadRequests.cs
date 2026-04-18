// File: Models/DTOs/CloudinaryDTO/UploadRequests.cs
using Microsoft.AspNetCore.Http;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
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

    public class UpdateProfileImageRequest
    {
        public IFormFile File { get; set; } = null!;
    }

    public class UploadFileResponse
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public string? Error { get; set; }
        public FileDto? File { get; set; }
        public int? UploadedById { get; set; }
        public string? UploadedByRole { get; set; }

        public static UploadFileResponse Successful(ExternalFile file, int uploadedById, string role)
        {
            return new UploadFileResponse
            {
                Success = true,
                Message = "File uploaded successfully",
                File = ToFileDto(file),
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

        public static FileDto ToFileDto(ExternalFile file)
        {
            return new FileDto
            {
                FileID = file.FileID,
                FileUrl = file.FileUrl,
                FileType = file.FileType,
                FileSize = file.FileSize,
                UploadedAt = file.UploadedAt,
                Description = file.Description,
                Category = file.CategoryValue ?? "Other"
            };
        }
    }
}
