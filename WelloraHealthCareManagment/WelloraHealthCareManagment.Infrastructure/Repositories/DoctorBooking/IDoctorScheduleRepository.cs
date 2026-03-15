using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public interface IDoctorScheduleRepository
    {
        Task<DoctorScheduleTemplate?> GetActiveTemplateAsync(int doctorId, CancellationToken cancellationToken = default);
        Task<DoctorScheduleTemplate?> GetByIdWithDetailsAsync(Guid templateId, CancellationToken cancellationToken = default);
        Task<List<DoctorScheduleTemplate>> GetActiveTemplatesAsync(int doctorId, CancellationToken cancellationToken = default);
        Task<List<int>> GetDoctorsWithActiveSchedulesAsync(CancellationToken cancellationToken = default);
        Task AddAsync(DoctorScheduleTemplate template, CancellationToken cancellationToken = default);
        Task UpdateAsync(DoctorScheduleTemplate template, CancellationToken cancellationToken = default);
        Task<DoctorScheduleTemplate?> GetActiveTemplateWithTimeRangesAsync(
            int doctorId,
            CancellationToken cancellationToken = default);
    }
}