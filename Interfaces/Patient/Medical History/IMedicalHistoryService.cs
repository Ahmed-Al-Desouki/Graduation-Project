using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces.Patient
{
    public interface IMedicalProfileService
    {
        Task<MedicalProfileResponse> GetMedicalProfileAsync();
        Task<MedicalProfileResponse> GetMedicalProfileByPatientIdAsync(int patientId);
        Task<MedicalProfileResponse> UpdateMedicalProfileAsync(UpdateMedicalProfileRequest request);
    }
}
