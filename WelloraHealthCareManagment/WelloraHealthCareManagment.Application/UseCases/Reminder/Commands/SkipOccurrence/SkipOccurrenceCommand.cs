using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SkipOccurrence
{
    public class SkipOccurrenceCommand
    {
        public int ReminderId { get; set; }
        public DateTime DueDateTime { get; set; }
        public int PatientId { get; set; }

        public SkipOccurrenceCommand(int reminderId, DateTime dueDateTime, int patientId)
        {
            ReminderId = reminderId;
            DueDateTime = dueDateTime;
            PatientId = patientId;
        }
    }
}
