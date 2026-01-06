using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface IFamilyHistoryService
    {
        Task<List<FamilyHistoryDto>> GetFamilyHistoryAsync(int historyId);
        Task<FamilyHistoryDto> UpsertFamilyHistoryAsync(CreateFamilyHistoryRequest request);
        Task SoftDeleteFamilyHistoryAsync(int familyHistoryId, int historyId);
        Task<List<FamilyHistoryDto>> GetFamilyHistoryForShareAsync(int medicalHistoryId);
    }
}
