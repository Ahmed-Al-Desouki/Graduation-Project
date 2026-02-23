using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public interface IAppointmentRepository
    {
        Task<Appointment?> GetByIdAsync(Guid appointmentId, CancellationToken cancellationToken = default);
        Task<Appointment?> GetByIdWithDetailsAsync(Guid appointmentId, CancellationToken cancellationToken = default);
        Task<Appointment?> GetByTimeSlotIdAsync(Guid timeSlotId, CancellationToken cancellationToken = default);

        Task<List<Appointment>> GetPatientAppointmentsAsync(
            int patientId,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default);

        Task<List<Appointment>> GetDoctorAppointmentsAsync(
            int doctorId,
            DateTime? date = null,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default);

        Task<List<Appointment>> GetUpcomingAppointmentsAsync(
            int doctorId,
            int count = 10,
            CancellationToken cancellationToken = default);

        Task AddAsync(Appointment appointment, CancellationToken cancellationToken = default);
        Task UpdateAsync(Appointment appointment, CancellationToken cancellationToken = default);
        Task<List<Appointment>> GetCompletedByPatientIdAsync(
            int patientId,
            CancellationToken ct = default);
        Task<Appointment?> GetByIdWithGrantsAsync(Guid appointmentId, CancellationToken ct = default);
    }
}