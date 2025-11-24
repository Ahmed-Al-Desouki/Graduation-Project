using HealthCare_.Interfaces;
using HealthCare_.Models.DTOs.AppointmentDTO;

namespace HealthCare_.Services.SharedService
{
    public class AppointmentService : IAppointmentService
    {
        private readonly HealthCarePlusContext _context;

        public AppointmentService(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<GetAppointmentDto>> GetPatientAppointmentsAsync(int patientId)
        {
            return await _context.Appointments
                .Where(a => a.PatientID == patientId)
                .Include(a => a.Doctor).ThenInclude(d => d!.User)
                .Select(a => new GetAppointmentDto
                {
                    AppointmentID = a.AppointmentID,
                    AppointmentDate = a.AppointmentDate,
                    Status = a.Status,
                    Type = a.Type ?? string.Empty,
                    Symptoms = a.Symptoms,
                    DoctorName = a.Doctor!.User.FullName,
                    DoctorSpecialization = a.Doctor.Specialization
                })
                .OrderByDescending(a => a.AppointmentDate)
                .ToListAsync();
        }

        public async Task<List<GetAppointmentDto>> GetDoctorAppointmentsAsync(int doctorId)
        {
            return await _context.Appointments
                .Where(a => a.DoctorID == doctorId)
                .Include(a => a.Patient).ThenInclude(p => p!.User)
                .Select(a => new GetAppointmentDto
                {
                    AppointmentID = a.AppointmentID,
                    AppointmentDate = a.AppointmentDate,
                    Status = a.Status,
                    Type = a.Type ?? string.Empty,
                    Symptoms = a.Symptoms,
                    PatientName = a.Patient!.User.FullName,
                    PatientPhone = a.Patient.User.PhoneNumber
                })
                .OrderBy(a => a.AppointmentDate)
                .ToListAsync();
        }
    }
}
