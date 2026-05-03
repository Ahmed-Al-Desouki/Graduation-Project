using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetAllReminders
{
    public class GetAllRemindersQuery
    {
        public int PatientId { get; set; }

        public GetAllRemindersQuery(int patientId)
        {
            PatientId = patientId;
        }
    }
}
