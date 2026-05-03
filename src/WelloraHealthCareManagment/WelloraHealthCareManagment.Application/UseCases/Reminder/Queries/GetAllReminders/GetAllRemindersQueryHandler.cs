using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetAllReminders
{
    public class GetAllRemindersQueryHandler
    {
        private readonly IReminderV2Service _reminderService;

        public GetAllRemindersQueryHandler(IReminderV2Service reminderService)
        {
            _reminderService = reminderService;
        }

        public async Task<List<ReminderV2Dto>> HandleAsync(GetAllRemindersQuery query)
        {
            return await _reminderService.GetAllAsync(query.PatientId);
        }
    }
}
