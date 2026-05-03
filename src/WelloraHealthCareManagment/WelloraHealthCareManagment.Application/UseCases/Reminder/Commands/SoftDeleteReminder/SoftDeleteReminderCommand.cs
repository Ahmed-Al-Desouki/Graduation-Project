using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SoftDeleteReminder
{
    public class SoftDeleteReminderCommand
    {
        public int ReminderId { get; set; }
        public int PatientId { get; set; }

        public SoftDeleteReminderCommand(int reminderId, int patientId)
        {
            ReminderId = reminderId;
            PatientId = patientId;
        }
    }
}
