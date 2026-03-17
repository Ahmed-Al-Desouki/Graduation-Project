using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.ConfirmOccurrence
{
    public class ConfirmOccurrenceCommand
    {
        public int ReminderId { get; set; }
        public DateTime DueDateTime { get; set; }
        public int PatientId { get; set; }
        public ReminderEnums.IntakeStatus IntakeStatus { get; set; }

        public ConfirmOccurrenceCommand(
            int reminderId,
            DateTime dueDateTime,
            int patientId,
            ReminderEnums.IntakeStatus intakeStatus)
        {
            ReminderId = reminderId;
            DueDateTime = dueDateTime;
            PatientId = patientId;
            IntakeStatus = intakeStatus;
        }
    }
}
