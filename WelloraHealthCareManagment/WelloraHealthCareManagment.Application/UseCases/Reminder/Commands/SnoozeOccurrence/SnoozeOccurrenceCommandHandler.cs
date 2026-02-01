using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SnoozeOccurrence
{
    public class SnoozeOccurrenceCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<SnoozeOccurrenceCommandHandler> _logger;

        public SnoozeOccurrenceCommandHandler(
            IReminderV2Service reminderService,
            ILogger<SnoozeOccurrenceCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task HandleAsync(SnoozeOccurrenceCommand command)
        {
            _logger.LogInformation(
                "Snoozing occurrence: ReminderId={ReminderId}, OriginalDue={OriginalDue}, Minutes={Minutes}",
                command.ReminderId, command.OriginalDueDateTime, command.Minutes);

            await _reminderService.SnoozeOccurrenceAsync(
                command.ReminderId,
                command.OriginalDueDateTime,
                command.PatientId,
                command.Minutes);

            _logger.LogInformation(
                "Occurrence snoozed successfully: ReminderId={ReminderId}",
                command.ReminderId);
        }
    }
}
