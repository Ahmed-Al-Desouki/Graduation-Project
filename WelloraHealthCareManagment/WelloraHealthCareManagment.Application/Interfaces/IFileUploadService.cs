using HealthCare_.Models.DTOs.CloudinaryDTO;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

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
    }
}