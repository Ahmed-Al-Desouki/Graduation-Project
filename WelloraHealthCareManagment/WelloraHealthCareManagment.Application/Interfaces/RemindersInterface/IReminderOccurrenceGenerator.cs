using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.RemindersInterface
{
    public interface IReminderOccurrenceGenerator
    {
        /// Generate occurrences for a specific patient
        Task GenerateForPatientAsync(int patientId);

        /// Generate occurrences for all active patients
        Task GenerateForAllPatientsAsync();
    }
}
