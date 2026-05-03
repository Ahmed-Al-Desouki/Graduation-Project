using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetTodayReminders
{
    public class GetTodayRemindersQuery
    {
        public int PatientId { get; set; }

        public GetTodayRemindersQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}
