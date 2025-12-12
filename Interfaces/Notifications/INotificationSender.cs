namespace HealthCare_.Interfaces.Notifications
{
    public interface INotificationSender
    {
        Task SendAsync(int patientId, string title, string body, long reminderOccurrenceId, CancellationToken ct = default);
    }

}
