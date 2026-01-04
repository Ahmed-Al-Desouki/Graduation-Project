using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces.IAuth
{
    public interface IShareTokenService
    {
        string GenerateMedicalHistoryShareToken(
            int patientId,
            int medicalHistoryId);
        Task<MedicalProfileResponse> GetMedicalProfileFromShareTokenAsync(string token);
    }
}
