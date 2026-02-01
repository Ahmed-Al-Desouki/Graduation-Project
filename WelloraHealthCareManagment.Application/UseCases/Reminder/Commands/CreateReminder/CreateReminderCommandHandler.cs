using HealthCare_.Models.V2;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.CreateReminder
{
    public class CreateReminderCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<CreateReminderCommandHandler> _logger;

        public CreateReminderCommandHandler(
            IReminderV2Service reminderService,
            ILogger<CreateReminderCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task<ReminderV2> HandleAsync(CreateReminderCommand command)
        {
            _logger.LogInformation(
                "Creating reminder for PatientId: {PatientId}",
                command.PatientId);

            var reminder = await _reminderService.CreateAsync(
                command.PatientId,
                command.Dto);

            _logger.LogInformation(
                "Reminder created successfully: ReminderId={ReminderId}",
                reminder.Id);

            return reminder;
        }
    }
}
