using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ICurrentMedicationService
    {
        Task<List<CurrentMedicationDto>> GetCurrentMedicationsAsync(int historyId);
        Task<List<CurrentMedicationDto>> GetCurrentMedicationsForShareAsync(int medicalHistoryId);
    }
}
