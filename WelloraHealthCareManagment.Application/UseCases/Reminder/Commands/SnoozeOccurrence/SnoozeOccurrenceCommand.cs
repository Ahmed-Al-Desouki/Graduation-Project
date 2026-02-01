using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SnoozeOccurrence
{
    public class SnoozeOccurrenceCommand
    {
        public int ReminderId { get; set; }
        public DateTime OriginalDueDateTime { get; set; }
        public int PatientId { get; set; }
        public int Minutes { get; set; }

        public SnoozeOccurrenceCommand(
            int reminderId,
            DateTime originalDueDateTime,
            int patientId,
            int minutes = 15)
        {
            ReminderId = reminderId;
            OriginalDueDateTime = originalDueDateTime;
            PatientId = patientId;
            Minutes = minutes;
        }
    }
}
