using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient
{
    public interface IMedicalProfileService
    {
        Task<MedicalProfileResponse> GetMedicalProfileAsync();
        Task<MedicalProfileResponse> GetCompleteMedicalProfileAsync(int patientId);
        Task<MedicalProfileResponse> UpdateMedicalProfileAsync(UpdateMedicalProfileRequest request);
    }
}
