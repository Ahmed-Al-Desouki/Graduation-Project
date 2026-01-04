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

        /// CRITICAL FIX: Sync notifications for devices that don't have them
        /// Run every 5 minutes: Cron.MinuteInterval(5)
        /// This ensures ANY device (new or old) gets notifications for all future occurrences
        public async Task SyncMissingNotificationsAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var now = DateTime.UtcNow;

            _logger.LogDebug("Starting notification sync at {Time}", now);

            try
            {
                //  Get all active patients with devices
                var patientsWithDevices = await context.PatientDevices
                    .Select(d => d.PatientId)
                    .Distinct()
                    .ToListAsync();

                if (!patientsWithDevices.Any())
                {
                    _logger.LogDebug("No patients with devices found");
                    return;
                }

                var syncedCount = 0;
                var totalCreated = 0;

                foreach (var patientId in patientsWithDevices)
                {
                    try
                    {
                        var created = await SyncNotificationsForPatientAsync(context, patientId, now);
                        if (created > 0)
                        {
                            syncedCount++;
                            totalCreated += created;
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error syncing notifications for patient {PatientId}", patientId);
                    }
                }

                if (totalCreated > 0)
                {
                    _logger.LogInformation(
                        "Notification sync completed: {TotalCreated} notifications created for {PatientCount} patients",
                        totalCreated,
                        syncedCount);
                }
                else
                {
                    _logger.LogDebug("Notification sync completed: All notifications up to date");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Critical error in notification sync job");
            }
        }

        ///  Sync notifications for a single patient
        /// Creates missing notification logs for all devices × future occurrences
        private async Task<int> SyncNotificationsForPatientAsync(
            HealthCarePlusContext context,
            int patientId,
            DateTime now)
        {
            //  Get all devices for this patient
            var devices = await context.PatientDevices
                .Where(d => d.PatientId == patientId)
                .ToListAsync();

            if (!devices.Any())
                return 0;

            //  Get all future occurrences for this patient (not yet due + pending status)
            var futureOccurrences = await context.ReminderOccurrencesCache
                .Where(o => o.PatientId == patientId &&
                           o.DueDateTimeUtc >= now &&
                           o.Status == 0) // Only pending
                .ToListAsync();

            if (!futureOccurrences.Any())
                return 0;

            //  Get existing notification logs (to avoid duplicates)
            var existingNotificationKeys = await context.NotificationLogs
                .Where(n => n.PatientId == patientId)
                .Select(n => new { n.OccurrenceId, n.FcmToken })
                .ToHashSetAsync();

            //  Create missing notifications
            var missingNotifications = new List<NotificationLog>();

            foreach (var occurrence in futureOccurrences)
            {
                foreach (var device in devices)
                {
                    //  Check if notification already exists
                    if (!existingNotificationKeys.Contains(new { OccurrenceId = occurrence.Id, FcmToken = device.FcmToken }))
                    {
                        missingNotifications.Add(new NotificationLog
                        {
                            PatientId = patientId,
                            ReminderId = occurrence.ReminderId,
                            OccurrenceId = occurrence.Id,
                            FcmToken = device.FcmToken,
                            TimeZoneId = occurrence.TimeZoneId,
                            ScheduledTime = occurrence.DueDateTimeUtc,
                            SentAt = null
                        });
                    }
                }
            }

            if (missingNotifications.Any())
            {
                context.NotificationLogs.AddRange(missingNotifications);
                await context.SaveChangesAsync();

                _logger.LogInformation(
                    "Created {Count} missing notifications for patient {PatientId}: {Devices} devices × {Occurrences} occurrences",
                    missingNotifications.Count,
                    patientId,
                    devices.Count,
                    futureOccurrences.Count);
            }

            return missingNotifications.Count;
        }

        ///  NEW: Sync notifications when a new device is registered
        /// Call this from your device registration endpoint
        public async Task SyncNotificationsForNewDeviceAsync(int patientId, string fcmToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var now = DateTime.UtcNow;

            try
            {
                //  Get all future occurrences for this patient
                var futureOccurrences = await context.ReminderOccurrencesCache
                    .Where(o => o.PatientId == patientId &&
                               o.DueDateTimeUtc >= now &&
                               o.Status == 0)
                    .ToListAsync();

                if (!futureOccurrences.Any())
                {
                    _logger.LogInformation(
                        "No future occurrences found for patient {PatientId}. No notifications created.",
                        patientId);
                    return;
                }

                //  Create notifications for this device
                var newNotifications = futureOccurrences.Select(occurrence => new NotificationLog
                {
                    PatientId = patientId,
                    ReminderId = occurrence.ReminderId,
                    OccurrenceId = occurrence.Id,
                    FcmToken = fcmToken,
                    TimeZoneId = occurrence.TimeZoneId,
                    ScheduledTime = occurrence.DueDateTimeUtc,
                    SentAt = null
                }).ToList();

                context.NotificationLogs.AddRange(newNotifications);
                await context.SaveChangesAsync();

                _logger.LogInformation(
                    "Created {Count} notifications for new device (Patient {PatientId}, Token {Token})",
                    newNotifications.Count,
                    patientId,
                    fcmToken.Substring(0, Math.Min(20, fcmToken.Length)) + "...");
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Error syncing notifications for new device (Patient {PatientId})",
                    patientId);
            }
        }

        /// Main job: Dispatch notifications that are due right now
        /// Run every minute via Hangfire: Cron.Minutely
        public async Task DispatchDueRemindersAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var now = DateTime.UtcNow;

            _logger.LogDebug("Notification dispatch starting at {Time}", now);

            try
            {
                var dueNotifications = await context.NotificationLogs
                    .Where(x => x.SentAt == null && x.ScheduledTime <= now)
                    .OrderBy(x => x.ScheduledTime)
                    .ThenBy(x => x.PatientId)
                    .ToListAsync();

                if (!dueNotifications.Any())
                {
                    _logger.LogDebug("No notifications due at {Time}", now);
                    return;
                }

                _logger.LogInformation(
                    "Starting notification dispatch: {Count} notifications due at {Time}",
                    dueNotifications.Count,
                    now);

                var sentCount = 0;
                var failedCount = 0;

                foreach (var notification in dueNotifications)
                {
                    try
                    {
                        await SendNotificationAsync(context, notification, now);
                        sentCount++;
                    }
                    catch (Exception ex)
                    {
                        failedCount++;
                        _logger.LogError(
                            ex,
                            "Failed to send notification {NotificationId} for reminder {ReminderId} to patient {PatientId}",
                            notification.Id,
                            notification.ReminderId,
                            notification.PatientId);
                    }
                }

                try
                {
                    await context.SaveChangesAsync();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error saving notification status changes");
                    throw;
                }

                _logger.LogInformation(
                    "Notification dispatch completed: {SentCount} sent, {FailedCount} failed, at {Time}",
                    sentCount,
                    failedCount,
                    now);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Critical error in notification dispatch job");
                throw;
            }
        }

        private async Task SendNotificationAsync(
            HealthCarePlusContext context,
            NotificationLog notification,
            DateTime sendTime)
        {
            var occurrence = await context.ReminderOccurrencesCache
                .FirstOrDefaultAsync(x => x.Id == notification.OccurrenceId);

            if (occurrence == null)
            {
                _logger.LogWarning(
                    "Occurrence {OccurrenceId} not found for notification {NotificationId}. Marking as sent.",
                    notification.OccurrenceId,
                    notification.Id);
                notification.SentAt = sendTime;
                return;
            }

            if (occurrence.Status != 0)
            {
                _logger.LogInformation(
                    "Skipping notification {NotificationId}: Occurrence already handled (Status={Status}). Marking as sent.",
                    notification.Id,
                    occurrence.Status);
                notification.SentAt = sendTime;
                return;
            }

            try
            {
                var notificationData = new Dictionary<string, string>
                {
                    ["ReminderId"] = notification.ReminderId.ToString(),
                    ["OccurrenceId"] = notification.OccurrenceId.ToString(),
                    ["Type"] = occurrence.Type.ToString(),
                    ["DueDateTime"] = occurrence.DueDateTime.ToString("O"),
                    ["Title"] = occurrence.Title,
                    ["Message"] = occurrence.Message ?? ""
                };

                await _notificationService.SendToDeviceAsync(
                    notification.FcmToken,
                    occurrence.Title,
                    occurrence.Message ?? occurrence.Title,
                    notificationData);

                _logger.LogDebug(
                    "Firebase notification sent for notification {NotificationId}, occurrence {OccurrenceId}",
                    notification.Id,
                    notification.OccurrenceId);
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Firebase send failed for notification {NotificationId}. Will retry.",
                    notification.Id);
                throw;
            }

            notification.SentAt = sendTime;

            _logger.LogInformation(
                "Notification {NotificationId} sent to patient {PatientId}, FCM token {Token}, at {SentAt}",
                notification.Id,
                notification.PatientId,
                notification.FcmToken,
                notification.SentAt);
        }

        public async Task CleanupOldNotificationsAsync()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);

            try
            {
                var deletedCount = await context.NotificationLogs
                    .Where(x => x.SentAt.HasValue && x.SentAt < thirtyDaysAgo)
                    .ExecuteDeleteAsync();

                _logger.LogInformation(
                    "Cleanup: Removed {Count} notification logs older than 30 days",
                    deletedCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cleaning up old notification logs");
            }
        }

        public async Task<NotificationStats> GetNotificationStatsAsync(int reminderId)
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

            var now = DateTime.UtcNow;

            var stats = await context.NotificationLogs
                .Where(x => x.ReminderId == reminderId)
                .GroupBy(x => 1)
                .Select(g => new NotificationStats
                {
                    Total = g.Count(),
                    Sent = g.Count(x => x.SentAt.HasValue),
                    Pending = g.Count(x => x.SentAt == null),
                    Overdue = g.Count(x => x.SentAt == null && x.ScheduledTime < now),
                    DueSoon = g.Count(x => x.SentAt == null && x.ScheduledTime >= now && x.ScheduledTime <= now.AddHours(1))
                })
                .FirstOrDefaultAsync() ?? new NotificationStats();

            return stats;
        }
    }

    public class NotificationStats
    {
        public int Total { get; set; }
        public int Sent { get; set; }
        public int Pending { get; set; }
        public int Overdue { get; set; }
        public int DueSoon { get; set; }
    }
}