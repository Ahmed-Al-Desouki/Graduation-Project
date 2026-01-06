using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.IAuth.QrCodeToken
{
    public interface IShareTokenService
    {
        string GenerateMedicalHistoryShareToken(
            int patientId,
            int medicalHistoryId);
        Task<MedicalProfileResponse> GetMedicalProfileFromShareTokenAsync(string token);
    }
}
