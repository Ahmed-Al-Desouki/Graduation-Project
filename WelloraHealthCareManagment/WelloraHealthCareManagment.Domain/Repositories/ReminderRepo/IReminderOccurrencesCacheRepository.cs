using HealthCare_.Models.V2;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.Repositories.ReminderRepo
{
    public interface IReminderOccurrencesCacheRepository
    {
        Task<List<ReminderOccurrencesCache>> GetByPatientAndDateRangeAsync(
            int patientId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive);

        Task<ReminderOccurrencesCache?> GetByReminderAndDueDateAsync(
            int reminderId,
            DateTime dueDateTimeUtc);

        Task AddRangeAsync(List<ReminderOccurrencesCache> entries);
        Task DeleteByPatientAndDateRangeAsync(int patientId, DateTime fromUtc, DateTime toUtc);
        Task DeletePastOccurrencesAsync(int patientId, DateTime beforeUtc);
        Task UpdateStatusAsync(int reminderId, DateTime dueDateTimeUtc, OccurrenceStatus status);
        Task BulkInsertAsync(List<ReminderOccurrencesCache> entries);
        Task DeleteByDoctorAndDateRangeAsync(int doctorId, DateTime fromUtc, DateTime toUtc);
        Task DeleteByReminderIdAsync(int reminderId);
        Task DeleteByReminderAndDateRangeAsync(int reminderId, DateTime fromUtc, DateTime toUtc);
        Task DeletePastOccurrencesExcludingPrescriptionsAsync(int patientId, DateTime beforeUtc);
        Task DeleteAllPastOccurrencesAsync(DateTime beforeUtc);
        Task DeleteFutureNonPrescriptionByPatientAsync(int patientId, DateTime fromUtc, DateTime toUtc);


    }
}
