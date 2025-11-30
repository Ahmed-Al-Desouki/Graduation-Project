using HealthCare_.Models.DTOs.PatientDot;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ISocialHistoryService
    {
        Task<List<SocialHistoryDto>> GetSocialHistoryAsync(int historyId);
        Task<SocialHistoryDto> UpsertSocialHistoryAsync(UpsertSocialHistoryRequest request);
        Task SoftDeleteSocialHistoryAsync(int socialHistoryId, int historyId);
    }
}
