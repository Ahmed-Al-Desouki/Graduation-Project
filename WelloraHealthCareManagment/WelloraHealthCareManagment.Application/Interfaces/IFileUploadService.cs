using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using Microsoft.AspNetCore.Http;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IFileUploadService
    {
        Task<UploadFileResponse> UploadPatientFileAsync(
            PatientUploadRequest request,
            int userId);

        Task<UploadFileResponse> UploadDoctorFileAsync(
            DoctorUploadRequest request,
            int doctorId);

        Task<List<FileDto>> GetPatientFilesAsync(int patientId);

        Task<List<FileDto>> GetDoctorFilesAsync(int doctorId);

        Task<bool> DeletePatientFileAsync(int fileId, int patientId);

        Task<bool> DeleteDoctorFileAsync(int fileId, int doctorId);

        Task<UploadFileResponse> UpdateProfileImageAsync(
            UpdateProfileImageRequest request,
            int userId,
            string userRole);

        Task<UploadFileResponse> SaveOrUpdateProfileImageAsync(
            IFormFile file,
            int userId,
            string userRole,
            string source);

        Task<UploadFileResponse> SaveOrUpdateProfileImageAsync(
            CloudinaryUploadResult uploadResult,
            int userId,
            string userRole,
            string source);

        Task<UploadFileResponse> SaveOrUpdateProfileImageFromUrlAsync(
            string fileUrl,
            int userId,
            string userRole,
            string source);
    }
}
