using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SoftDeleteReminder
{
    public class SoftDeleteReminderCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<SoftDeleteReminderCommandHandler> _logger;

        public SoftDeleteReminderCommandHandler(
            IReminderV2Service reminderService,
            ILogger<SoftDeleteReminderCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task HandleAsync(SoftDeleteReminderCommand command)
        {
            _logger.LogInformation(
                "Soft deleting reminder: ReminderId={ReminderId}, PatientId={PatientId}",
                command.ReminderId, command.PatientId);

            await _reminderService.SoftDeleteAsync(
                command.ReminderId,
                command.PatientId);

            _logger.LogInformation(
                "Reminder soft deleted successfully: ReminderId={ReminderId}",
                command.ReminderId);
        }
    }
}
