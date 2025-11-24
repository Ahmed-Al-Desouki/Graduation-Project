using HealthCare_.Models.DTOs.AppointmentDTO;

namespace HealthCare_.Interfaces
{
    public interface IAppointmentService
    {
        Task<List<GetAppointmentDto>> GetPatientAppointmentsAsync(int patientId);
        Task<List<GetAppointmentDto>> GetDoctorAppointmentsAsync(int doctorId);
    }
}
