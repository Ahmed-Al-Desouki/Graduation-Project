using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SkipOccurrence
{
    public class SkipOccurrenceCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<SkipOccurrenceCommandHandler> _logger;

        public SkipOccurrenceCommandHandler(
            IReminderV2Service reminderService,
            ILogger<SkipOccurrenceCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task HandleAsync(SkipOccurrenceCommand command)
        {
            _logger.LogInformation(
                "Skipping occurrence: ReminderId={ReminderId}, DueDateTime={DueDateTime}",
                command.ReminderId, command.DueDateTime);

            await _reminderService.SkipOccurrenceAsync(
                command.ReminderId,
                command.DueDateTime,
                command.PatientId);

            _logger.LogInformation(
                "Occurrence skipped successfully: ReminderId={ReminderId}",
                command.ReminderId);
        }
    }
}
