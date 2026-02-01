using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetUpcomingReminders
{
    public class GetUpcomingRemindersQueryHandler
    {
        private readonly IReminderV2Service _reminderService;

        public GetUpcomingRemindersQueryHandler(IReminderV2Service reminderService)
        {
            _reminderService = reminderService;
        }

        public async Task<List<UpcomingOccurrenceDto>> HandleAsync(GetUpcomingRemindersQuery query)
        {
            return await _reminderService.GetUpcomingAsync(query.PatientId, query.DaysAhead);
        }
    }
}
