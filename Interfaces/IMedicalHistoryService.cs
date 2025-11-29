using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces
{
    public interface IMedicalProfileService
    {
        Task<MedicalProfileResponse> GetMedicalProfileAsync();
        Task<MedicalProfileResponse> UpdateMedicalProfileAsync(Models.DTOs.PatientDot.UpdateMedicalProfileRequest request);
        Task<List<CurrentMedicationDto>> GetCurrentMedicationsAsync(int historyId);
        Task<SurgeryDto> UpsertSurgeryAsync(CreateSurgeryRequest request);
        Task<FamilyHistoryDto> UpsertFamilyHistoryAsync(CreateFamilyHistoryRequest request);
        Task<SocialHistoryDto> UpsertSocialHistoryAsync(UpsertSocialHistoryRequest request);
        Task<SelfMedicationDto> UpsertSelfMedicationAsync(CreateSelfMedicationRequest request);
        Task SoftDeleteSurgeryAsync(int surgeryId, int historyId);
        Task SoftDeleteFamilyHistoryAsync(int familyHistoryId, int historyId);
        Task SoftDeleteSelfMedicationAsync(int selfMedicationId);
        Task SoftDeleteSocialHistoryAsync(int socialHistoryId, int historyId);


    }
}
