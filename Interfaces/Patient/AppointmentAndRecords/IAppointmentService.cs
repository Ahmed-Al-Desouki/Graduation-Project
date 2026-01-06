using HealthCare_.Models.DTOs.AppointmentDTO;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;

namespace HealthCare_.Interfaces.Patient.AppointmentAndRecords
{
    public interface IAppointmentService
    {
        Task<List<GetAppointmentDto>> GetPatientAppointmentsAsync(int patientId);
        Task<List<GetAppointmentDto>> GetDoctorAppointmentsAsync(int doctorId);
        Task<CurrentMedicationDto> UpsertMedicationAsync(int prescriptionId, CurrentMedicationDto request);
    }
}
