// This is the IMPROVED version
using HealthCare_.Models.PatientModels;
using HealthCare_.Models.V2;
using HealthCare_.Services.Notifications;
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Services.Background.Reminder
{
    public class ReminderNotificationDispatcherJob
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly FirebaseNotificationService _notificationService;
        private readonly ILogger<ReminderNotificationDispatcherJob> _logger;

        public ReminderNotificationDispatcherJob(
            IServiceProvider serviceProvider,
            FirebaseNotificationService notificationService,
            ILogger<ReminderNotificationDispatcherJob> logger)
        {
            _serviceProvider = serviceProvider;
            _notificationService = notificationService;
            _logger = logger;
        }

        /// <summary>
        /// Main job: Dispatch notifications that are due right now
        /// Run every minute via Hangfire: Cron.Minutely
        /// </summary>
        public async Task DispatchDueRemindersAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var now = DateTime.UtcNow;

            // ✅ CRITICAL: Only get notifications that are:
            // 1. Not yet sent (IsSent == false)
            // 2. Due NOW (ScheduledTime <= now)
            var dueNotifications = await context.NotificationLogs
                .Where(x => !x.IsSent && x.ScheduledTime <= now)
                .OrderBy(x => x.ScheduledTime)
                .ThenBy(x => x.PatientId)
                .ToListAsync();

            _logger.LogInformation(
                "Starting notification dispatch: {Count} notifications due",
                dueNotifications.Count);

            var sentCount = 0;
            var failedCount = 0;

            foreach (var notification in dueNotifications)
            {
                try
                {
                    await SendNotificationAsync(context, notification);
                    sentCount++;
                }
                catch (Exception ex)
                {
                    failedCount++;
                    _logger.LogError(
                        ex,
                        "Failed to send notification {NotificationId} to patient {PatientId}",
                        notification.Id,
                        notification.PatientId);
                }
            }

            await context.SaveChangesAsync();

            _logger.LogInformation(
                "Notification dispatch completed: {SentCount} sent, {FailedCount} failed",
                sentCount,
                failedCount);
        }

        /// <summary>
        /// Send a single notification and track it
        /// </summary>
        private async Task SendNotificationAsync(HealthCarePlusContext context, NotificationLog notification)
        {
            // ✅ Verify the occurrence is still relevant
            var occurrence = await context.ReminderOccurrencesCache
                .FirstOrDefaultAsync(x => x.Id == notification.OccurrenceId);

            if (occurrence == null)
            {
                _logger.LogWarning(
                    "Occurrence {OccurrenceId} not found for notification {NotificationId}",
                    notification.OccurrenceId,
                    notification.Id);
                notification.SentAt = DateTime.UtcNow;
                return;
            }

            // ✅ Only send if reminder hasn't been skipped/completed by user
            if (occurrence.Status != 0) // 0 = Pending, 1 = Completed, 2 = Skipped
            {
                _logger.LogInformation(
                    "Skipping notification {NotificationId}: Occurrence already handled (Status={Status})",
                    notification.Id,
                    occurrence.Status);
                notification.SentAt = DateTime.UtcNow;
                return;
            }

            // ✅ Send to the specific device
            await _notificationService.SendToDeviceAsync(
                notification.FcmToken,
                occurrence.Title,
                occurrence.Message ?? string.Empty,
                new Dictionary<string, string>
                {
                    ["ReminderId"] = notification.ReminderId.ToString(),
                    ["OccurrenceId"] = notification.OccurrenceId.ToString(),
                    ["Type"] = occurrence.Type.ToString(),
                    ["DueDateTime"] = occurrence.DueDateTime.ToString("O")
                });

            // ✅ Mark as sent
            notification.SentAt = DateTime.UtcNow;

            _logger.LogInformation(
                "Notification {NotificationId} sent to patient {PatientId} at {SentAt}",
                notification.Id,
                notification.PatientId,
                notification.SentAt);
        }

        /// <summary>
        /// Cleanup: Remove old sent notifications (older than 30 days)
        /// Run daily: Cron.Daily(3) — 3 AM
        /// </summary>
        public async Task CleanupOldNotificationsAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);

            var deletedCount = await context.NotificationLogs
                .Where(x => x.SentAt.HasValue && x.SentAt < thirtyDaysAgo)
                .ExecuteDeleteAsync();

            _logger.LogInformation(
                "Cleaned up {Count} old notification logs",
                deletedCount);
        }

        /// <summary>
        /// Initialize notifications for a new reminder occurrence
        /// Called after a new occurrence is generated
        /// </summary>
        public async Task InitializeNotificationsForOccurrenceAsync(
            int patientId,
            long occurrenceId,
            int reminderId,
            DateTime dueDateTimeUtc)
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            // ✅ Get all devices for this patient
            var devices = await context.PatientDevices
                .Where(d => d.PatientId == patientId)
                .ToListAsync();

            if (!devices.Any())
            {
                _logger.LogWarning(
                    "No devices registered for patient {PatientId}",
                    patientId);
                return;
            }

            // ✅ Create a notification log entry for EACH device
            var notificationLogs = devices.Select(device => new NotificationLog
            {
                PatientId = patientId,
                ReminderId = reminderId,
                OccurrenceId = occurrenceId,
                FcmToken = device.FcmToken,
                ScheduledTime = dueDateTimeUtc,
                SentAt = null // Not sent yet
            }).ToList();

            context.NotificationLogs.AddRange(notificationLogs);
            await context.SaveChangesAsync();

            _logger.LogInformation(
                "Initialized {Count} notifications for occurrence {OccurrenceId}",
                notificationLogs.Count,
                occurrenceId);
        }

        // ✅ ADD THIS METHOD to your existing generator
        private async Task InitializeNotificationsForNewOccurrencesAsync(
            HealthCarePlusContext context,
            int patientId,
            List<ReminderOccurrencesCache> newEntries)
        {
            var notificationLogs = new List<NotificationLog>();

            foreach (var entry in newEntries)
            {
                var devices = await context.PatientDevices
                    .Where(d => d.PatientId == patientId)
                    .ToListAsync();

                foreach (var device in devices)
                {
                    notificationLogs.Add(new NotificationLog
                    {
                        PatientId = patientId,
                        ReminderId = entry.ReminderId,
                        OccurrenceId = entry.Id, // The generated occurrence ID
                        FcmToken = device.FcmToken,
                        ScheduledTime = entry.DueDateTimeUtc,
                        SentAt = null
                    });
                }
            }

            if (notificationLogs.Any())
            {
                context.NotificationLogs.AddRange(notificationLogs);
                await context.SaveChangesAsync();

                _logger.LogInformation(
                    "Created {Count} notification logs for patient {PatientId}",
                    notificationLogs.Count,
                    patientId);
            }
        }

    }
}
