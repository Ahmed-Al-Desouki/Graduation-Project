using HealthCare_.Models.V2;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.ReminderRepo
{
    public class ReminderOccurrenceLogRepository : IReminderOccurrenceLogRepository
    {
        private readonly HealthCarePlusContext _context;

        public ReminderOccurrenceLogRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<ReminderOccurrenceLog?> GetByReminderAndDueDateAsync(
            int reminderId,
            DateTime dueDateTimeUtc)
        {
            return await _context.ReminderOccurrenceLogs
                .FirstOrDefaultAsync(l => l.ReminderId == reminderId
                                       && l.DueDateTimeUtc == dueDateTimeUtc);
        }

        public async Task<int> CountTakenByReminderIdAsync(int reminderId)
        {
            return await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == reminderId
                              && l.Status == Enums.OccurrenceStatus.Taken);
        }

        public async Task<int> CountTotalByReminderIdAsync(int reminderId)
        {
            return await _context.ReminderOccurrenceLogs
                .CountAsync(l => l.ReminderId == reminderId);
        }

        public async Task AddAsync(ReminderOccurrenceLog log)
        {
            _context.ReminderOccurrenceLogs.Add(log);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(ReminderOccurrenceLog log)
        {
            _context.ReminderOccurrenceLogs.Update(log);
            await _context.SaveChangesAsync();
        }
    }
}
