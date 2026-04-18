using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IMedicalHistoryAccessRepository
    {
        Task<MedicalHistoryAccessGrant?> GetActiveGrantAsync(
            int patientId,
            int doctorId,
            Guid? appointmentId = null,
            CancellationToken cancellationToken = default);

        Task<List<MedicalHistoryAccessGrant>> GetPatientGrantsAsync(
            int patientId,
            bool activeOnly = true,
            CancellationToken cancellationToken = default);

        Task AddAsync(MedicalHistoryAccessGrant grant, CancellationToken cancellationToken = default);
        Task AddLogAsync(MedicalHistoryAccessLog log, CancellationToken cancellationToken = default);
        Task<MedicalHistoryAccessGrant?> GetActiveAppointmentGrantAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);
        Task<MedicalHistoryAccessGrant?> GetByIdAsync(Guid grantId, CancellationToken ct = default);
        Task ExtendExpiryAsync(Guid grantId, DateTime newExpiryDate, int patientId, CancellationToken ct = default);
        Task RevokeGrantAsync(Guid grantId, string reason, int patientId, CancellationToken ct = default);
        Task<bool> HasActiveGrantForAppointmentAsync(Guid appointmentId, CancellationToken ct = default);
    }
}