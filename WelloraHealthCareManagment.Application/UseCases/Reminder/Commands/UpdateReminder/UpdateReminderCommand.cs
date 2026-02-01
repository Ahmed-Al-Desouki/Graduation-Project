using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.UpdateReminder
{
    public class UpdateReminderCommand
    {
        public int ReminderId { get; set; }
        public int PatientId { get; set; }
        public UpdateReminderV2Dto Dto { get; set; }

        public UpdateReminderCommand(int reminderId, int patientId, UpdateReminderV2Dto dto)
        {
            ReminderId = reminderId;
            PatientId = patientId;
            Dto = dto;
        }
    }
}
