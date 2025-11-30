using HealthCare_.Models.DTOs.ReminderDTO;
using HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.DTOs.V2.HealthCare_.Models.DTOs.V2;
using HealthCare_.Models.V2;

namespace HealthCare_.Interfaces.ReminderInterface
{
    public interface IReminderV2Service
    {
        Task<ReminderV2> CreateAsync(int patientId, CreateReminderV2Dto dto);
        Task<ReminderV2Dto> GetByIdAsync(int reminderId, int patientId);
        Task<List<ReminderV2Dto>> GetAllAsync(int patientId);
        Task UpdateAsync(int reminderId, int patientId, UpdateReminderV2Dto dto);
        Task SoftDeleteAsync(int reminderId, int patientId);

        Task<List<UpcomingOccurrenceDto>> GetUpcomingAsync(int patientId, int daysAhead = 30);
        Task<List<UpcomingOccurrenceDto>> GetTodayAsync(int patientId);

        Task ConfirmOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, IntakeStatus intake = IntakeStatus.Taken);
        Task SnoozeOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId, int minutes = 15);
        Task SkipOccurrenceAsync(int reminderId, DateTime dueDateTime, int patientId);
    }
}
