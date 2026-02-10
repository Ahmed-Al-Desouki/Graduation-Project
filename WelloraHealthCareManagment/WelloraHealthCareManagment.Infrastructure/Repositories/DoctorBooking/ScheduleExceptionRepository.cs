using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class ScheduleExceptionRepository : IScheduleExceptionRepository
    {
        private readonly HealthCarePlusContext _context;

        public ScheduleExceptionRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<ScheduleException>> GetExceptionsForPeriodAsync(
            int doctorId,
            DateTime startDate,
            DateTime endDate,
            CancellationToken cancellationToken = default)
        {
            return await _context.ScheduleExceptions
                .Where(e => e.DoctorId == doctorId
                    && e.ExceptionDate >= startDate.Date
                    && e.ExceptionDate <= endDate.Date)
                .OrderBy(e => e.ExceptionDate)
                .ToListAsync(cancellationToken);
        }

        public async Task<ScheduleException?> GetExceptionForDateAsync(
            int doctorId,
            DateTime date,
            CancellationToken cancellationToken = default)
        {
            return await _context.ScheduleExceptions
                .FirstOrDefaultAsync(
                    e => e.DoctorId == doctorId && e.ExceptionDate == date.Date,
                    cancellationToken);
        }

        public async Task AddAsync(
            ScheduleException exception,
            CancellationToken cancellationToken = default)
        {
            await _context.ScheduleExceptions.AddAsync(exception, cancellationToken);
        }

        public async Task DeleteAsync(
            ScheduleException exception,
            CancellationToken cancellationToken = default)
        {
            _context.ScheduleExceptions.Remove(exception);
            await Task.CompletedTask;
        }
    }
}