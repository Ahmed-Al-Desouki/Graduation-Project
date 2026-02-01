using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetReminderById
{
    public class GetReminderByIdQuery
    {
        public int ReminderId { get; set; }
        public int PatientId { get; set; }

        public GetReminderByIdQuery(int reminderId, int patientId)
        {
            ReminderId = reminderId;
            PatientId = patientId;
        }
    }
}
