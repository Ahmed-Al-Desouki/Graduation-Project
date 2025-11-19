using HealthCare_.Models.DTOs.PatientDot;

namespace HealthCare_.Interfaces
{
    public interface IMedicalHistoryService
    {
        Task<MedicalHistoryResponse> CreateOrUpdateMedicalHistoryAsync(CreateOrUpdateMedicalHistoryRequest request);
        Task<PatientProfileResponse> GetPatientProfileAsync();
    }
}
