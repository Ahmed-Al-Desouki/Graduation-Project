using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces
{
    public interface IMedicalProfileService
    {
        Task<MedicalProfileResponse> GetMedicalProfileAsync();
        Task<MedicalProfileResponse> UpdateMedicalProfileAsync(Models.DTOs.PatientDot.UpdateMedicalProfileRequest request);
    }
}
