using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.Medical_History
{
    public interface ISurgeryService
    {
        Task<List<SurgeryDto>> GetSurgeriesAsync(int historyId);
        Task<SurgeryDto> UpsertSurgeryAsync(CreateSurgeryRequest request);
        Task SoftDeleteSurgeryAsync(int surgeryId, int historyId);
        Task<List<SurgeryDto>> GetSurgeriesForShareAsync(int patientId);
    }
}
