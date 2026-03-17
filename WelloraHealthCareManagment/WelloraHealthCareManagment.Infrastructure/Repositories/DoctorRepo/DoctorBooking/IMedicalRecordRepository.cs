using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    public interface IMedicalRecordRepository
    {
        Task<AppointmentMedicalRecord?> GetByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        Task AddAsync(
            AppointmentMedicalRecord record,
            CancellationToken cancellationToken = default);

        Task UpdateAsync(
            AppointmentMedicalRecord record,
            CancellationToken cancellationToken = default);
    }
}