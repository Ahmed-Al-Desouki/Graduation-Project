using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ICurrentMedicationService
    {
        Task<List<CurrentMedicationDto>> GetCurrentMedicationsAsync(int historyId);
    }
}
