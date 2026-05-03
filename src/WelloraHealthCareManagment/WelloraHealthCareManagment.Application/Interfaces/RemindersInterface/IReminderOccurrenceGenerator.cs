using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.RemindersInterface
{
    public interface IReminderOccurrenceGenerator
    {
        Task GenerateForAllPatientsAsync();

        Task GenerateForAllDoctorsAsync();

        /// Generate occurrences for a specific patient
        Task GenerateForPatientAsync(int patientId);

        /// Generate occurrences for all active Doctor
        Task GenerateForDoctorAsync(int doctorId);
        Task GenerateForReminderAsync(int reminderId);
    }
}
