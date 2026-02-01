using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.ConfirmOccurrence
{
    public class ConfirmOccurrenceCommandHandler
    {
        private readonly IReminderV2Service _reminderService;
        private readonly ILogger<ConfirmOccurrenceCommandHandler> _logger;

        public ConfirmOccurrenceCommandHandler(
            IReminderV2Service reminderService,
            ILogger<ConfirmOccurrenceCommandHandler> logger)
        {
            _reminderService = reminderService;
            _logger = logger;
        }

        public async Task HandleAsync(ConfirmOccurrenceCommand command)
        {
            _logger.LogInformation(
                "Confirming occurrence: ReminderId={ReminderId}, DueDateTime={DueDateTime}, PatientId={PatientId}",
                command.ReminderId, command.DueDateTime, command.PatientId);

            await _reminderService.ConfirmOccurrenceAsync(
                command.ReminderId,
                command.DueDateTime,
                command.PatientId,
                command.IntakeStatus);

            _logger.LogInformation(
                "Occurrence confirmed successfully: ReminderId={ReminderId}",
                command.ReminderId);
        }
    }
}
