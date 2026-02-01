using HealthCare_.Models.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Repositories.ReminderRepo
{
    public interface IReminderOccurrenceLogRepository
    {
        Task<ReminderOccurrenceLog?> GetByReminderAndDueDateAsync(
            int reminderId,
            DateTime dueDateTimeUtc);

        Task<int> CountTakenByReminderIdAsync(int reminderId);
        Task<int> CountTotalByReminderIdAsync(int reminderId);
        Task AddAsync(ReminderOccurrenceLog log);
        Task UpdateAsync(ReminderOccurrenceLog log);
    }
}
