using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public interface IPrescriptionRepository
    {
        Task<Prescription?> GetByIdAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default);

        Task<Prescription?> GetByIdWithItemsAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default);

        Task<List<Prescription>> GetByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

        Task<List<Prescription>> GetByPatientIdAsync(
            int patientId,
            CancellationToken cancellationToken = default);

        Task AddAsync(
            Prescription prescription,
            CancellationToken cancellationToken = default);

        Task UpdateAsync(
            Prescription prescription,
            CancellationToken cancellationToken = default);
    }
}