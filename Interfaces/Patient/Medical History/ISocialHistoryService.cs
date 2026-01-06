using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ISocialHistoryService
    {
        Task<List<SocialHistoryDto>> GetSocialHistoryAsync(int historyId);
        Task<SocialHistoryDto> UpsertSocialHistoryAsync(UpsertSocialHistoryRequest request);
        Task SoftDeleteSocialHistoryAsync(int socialHistoryId, int historyId);
        Task<List<SocialHistoryDto>> GetSocialHistoryForShareAsync(int patientId);
    }
}
