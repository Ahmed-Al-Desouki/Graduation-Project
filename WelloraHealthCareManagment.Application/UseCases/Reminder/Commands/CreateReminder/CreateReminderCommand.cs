using HealthCare_.Models.DTOs.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.CreateReminder
{
    public class CreateReminderCommand
    {
        public int PatientId { get; set; }
        public CreateReminderV2Dto Dto { get; set; }

        public CreateReminderCommand(int patientId, CreateReminderV2Dto dto)
        {
            PatientId = patientId;
            Dto = dto;
        }
    }
}
