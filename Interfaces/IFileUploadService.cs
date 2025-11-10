

using HealthCare_.Models.DTOs.CloudinaryDTO;

namespace HealthCare_.Interfaces
{
    public interface IFileUploadService
    {
        Task<UploadFileResponse> UploadPatientFileAsync(IFormFile file, int userId, PatientUploadRequest request);
        Task<UploadFileResponse> UploadDoctorFileAsync(IFormFile file, int doctorId, DoctorUploadRequest request);
    }

}

