using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ISelfMedicationService
    {
        Task<List<SelfMedicationDto>> GetSelfMedicationsAsync();
        Task<SelfMedicationDto> UpsertSelfMedicationAsync(CreateSelfMedicationRequest request);
        Task SoftDeleteSelfMedicationAsync(int selfMedicationId);
        Task<List<SelfMedicationDto>> GetSelfMedicationsForShareAsync(int PatientId);
    }
}
