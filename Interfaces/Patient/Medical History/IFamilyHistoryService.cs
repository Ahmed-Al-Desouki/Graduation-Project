using HealthCare_.Models.DTOs.PatientDot;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface IFamilyHistoryService
    {
        Task<List<FamilyHistoryDto>> GetFamilyHistoryAsync(int historyId);
        Task<FamilyHistoryDto> UpsertFamilyHistoryAsync(CreateFamilyHistoryRequest request);
        Task SoftDeleteFamilyHistoryAsync(int familyHistoryId, int historyId);
    }
}
