using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public interface IScheduleExceptionRepository
    {
        Task<List<ScheduleException>> GetExceptionsForPeriodAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default);

        Task<ScheduleException?> GetExceptionForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default);

        Task AddAsync(ScheduleException exception, CancellationToken cancellationToken = default);
        Task DeleteAsync(ScheduleException exception, CancellationToken cancellationToken = default);
    }
}