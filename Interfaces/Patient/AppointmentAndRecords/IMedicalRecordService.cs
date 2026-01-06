using HealthCare_.Models.DTOs.AppointmentDTO;

namespace HealthCare_.Interfaces.Patient.AppointmentAndRecords
{
    public interface IMedicalRecordService
    {
        Task<List<GetMedicalRecordDto>> GetPatientMedicalRecordsAsync(int patientId);
        Task<bool> CreateMedicalRecordAsync(int doctorId, CreateMedicalRecordDto request);
    }
}
