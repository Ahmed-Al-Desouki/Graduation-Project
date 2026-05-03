using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetReminderById
{
    public class GetReminderByIdQueryHandler
    {
        private readonly IReminderV2Service _reminderService;

        public GetReminderByIdQueryHandler(IReminderV2Service reminderService)
        {
            _reminderService = reminderService;
        }

        public async Task<ReminderV2Dto> HandleAsync(GetReminderByIdQuery query)
        {
            return await _reminderService.GetByIdAsync(query.ReminderId, query.PatientId);
        }
    }
}
