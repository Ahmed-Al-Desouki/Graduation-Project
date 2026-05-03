using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetUpcomingReminders
{
    public class GetUpcomingRemindersQuery
    {
        public int PatientId { get; set; }
        public int DaysAhead { get; set; }

        public GetUpcomingRemindersQuery(int patientId, int daysAhead = 30)
        {
            PatientId = patientId;
            DaysAhead = daysAhead;
        }
    }
}
