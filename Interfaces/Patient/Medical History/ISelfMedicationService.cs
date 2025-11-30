using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ISelfMedicationService
    {
        Task<List<SelfMedicationDto>> GetSelfMedicationsAsync();
        Task<SelfMedicationDto> UpsertSelfMedicationAsync(CreateSelfMedicationRequest request);
        Task SoftDeleteSelfMedicationAsync(int selfMedicationId);
    }
}
