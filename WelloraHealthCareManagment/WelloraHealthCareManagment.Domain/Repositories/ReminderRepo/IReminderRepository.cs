using HealthCare_.Models.V2;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Repositories.ReminderRepo
{
    public interface IReminderRepository
    {
        Task<ReminderV2?> GetByIdAsync(int reminderId, int patientId);
        Task<List<ReminderV2>> GetAllByPatientIdAsync(int patientId);
        Task<List<ReminderV2>> GetActiveByPatientIdAsync(int patientId);
        Task<ReminderV2> AddAsync(ReminderV2 reminder);
        Task UpdateAsync(ReminderV2 reminder);
        Task DeleteAsync(ReminderV2 reminder);
        Task<List<int>> GetAllActivePatientIdsAsync();
        Task<List<ReminderV2>> GetActiveByDoctorIdAsync(int doctorId);
        Task<List<int>> GetAllActiveDoctorIdsAsync();
        Task<IList<ReminderV2>> GetAllExpiredActiveRemindersAsync(DateTime asOfUtc);
        Task<List<ReminderV2>> GetByAppointmentIdAsync(Guid appointmentId);
        Task HardDeleteAsync(int reminderId);
    }
}
