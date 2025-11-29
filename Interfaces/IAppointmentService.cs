using HealthCare_.Models.DTOs.AppointmentDTO;
using HealthCare_.Models.DTOs.PatientDTO;

namespace HealthCare_.Interfaces
{
    public interface IAppointmentService
    {
        Task<List<GetAppointmentDto>> GetPatientAppointmentsAsync(int patientId);
        Task<List<GetAppointmentDto>> GetDoctorAppointmentsAsync(int doctorId);
        Task<CurrentMedicationDto> UpsertMedicationAsync(int prescriptionId, CurrentMedicationDto request);
    }
}
