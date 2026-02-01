using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.UpdateReminder
{
    public class UpdateReminderCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<UpdateReminderCommandHandler> _logger;

        public UpdateReminderCommandHandler(
            IReminderV2Service reminderService,
            ILogger<UpdateReminderCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task HandleAsync(UpdateReminderCommand command)
        {
            _logger.LogInformation(
                "Updating reminder: ReminderId={ReminderId}, PatientId={PatientId}",
                command.ReminderId, command.PatientId);

            await _reminderService.UpdateAsync(
                command.ReminderId,
                command.PatientId,
                command.Dto);

            _logger.LogInformation(
                "Reminder updated successfully: ReminderId={ReminderId}",
                command.ReminderId);
        }
    }
}
