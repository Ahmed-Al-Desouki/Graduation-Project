using FirebaseAdmin.Messaging;

namespace HealthCare_.Services.Notifications
{
    public class FirebaseNotificationService
    {
        private readonly ILogger<FirebaseNotificationService> _logger;

        public FirebaseNotificationService(ILogger<FirebaseNotificationService> logger)
        {
            _logger = logger;
        }

        // 📌 إرسال إشعار لجهاز واحد
        public async Task SendToDeviceAsync(
            string fcmToken,
            string title,
            string body,
            Dictionary<string, string>? data = null)
        {
            var message = new Message
            {
                Token = fcmToken,
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                },
                Data = data ?? new Dictionary<string, string>()
            };

            try
            {
                var response = await FirebaseMessaging.DefaultInstance.SendAsync(message);

                _logger.LogInformation("FCM sent successfully: {Response}", response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending FCM notification");
            }
        }

        // 📌 إرسال إشعار لأكثر من جهاز (Batch)
        public async Task SendToMultipleDevicesAsync(
            IEnumerable<string> tokens,
            string title,
            string body,
            Dictionary<string, string>? data = null)
        {
            var message = new MulticastMessage
            {
                Tokens = tokens.ToList(),
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                },
                Data = data ?? new Dictionary<string, string>()
            };

            try
            {
                var response = await FirebaseMessaging.DefaultInstance.SendMulticastAsync(message);

                _logger.LogInformation(
                    "FCM Batch Sent: Success={Success}, Failed={Failed}",
                    response.SuccessCount,
                    response.FailureCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending batch FCM notification");
            }
        }
    }
}
