using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetTodayReminders
{
    public class GetTodayRemindersQueryHandler
    {
        private readonly IReminderV2Service _reminderService;

        public GetTodayRemindersQueryHandler(IReminderV2Service reminderService)
        {
            _reminderService = reminderService;
        }

        public async Task<List<UpcomingOccurrenceDto>> HandleAsync(GetTodayRemindersQuery query)
        {
            return await _reminderService.GetTodayAsync(query.PatientId);
        }
    }
}
