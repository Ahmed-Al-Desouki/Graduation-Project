// Infrastructure/Services/FirebaseNotificationService.cs
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagement.Infrastructure.Services;

public class FirebaseNotificationService : IFirebaseNotificationService, IDisposable
{
    private readonly FirebaseMessaging _firebaseMessaging;
    private readonly ILogger<FirebaseNotificationService> _logger;
    private bool _disposed = false;

    public FirebaseNotificationService(IOptions<FirebaseSettings> firebaseSettings, ILogger<FirebaseNotificationService> logger)
    {
        _logger = logger;

        try
        {
            var settings = firebaseSettings.Value;

            if (FirebaseApp.DefaultInstance == null)
            {
                FirebaseApp.Create(new AppOptions()
                {
                    Credential = GoogleCredential.FromFile(settings.ServiceAccountPath)
                });
            }

            _firebaseMessaging = FirebaseMessaging.DefaultInstance;
            _logger.LogInformation("Firebase Messaging initialized successfully");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initialize Firebase Messaging");
            throw;
        }
    }

    public async Task SendPushAsync(
        string fcmToken,
        string title,
        string body,
        string? data = null,
        CancellationToken ct = default)
    {
        try
        {
            var message = new Message
            {
                Token = fcmToken,
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                },
                Data = string.IsNullOrEmpty(data) ? null :
                       System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, string>>(data),
                Android = new AndroidConfig
                {
                    Priority = Priority.High
                },
                Apns = new ApnsConfig
                {
                    Headers = new Dictionary<string, string>
                    {
                        { "apns-priority", "10" }
                    }
                }
            };

            var response = await _firebaseMessaging.SendAsync(message, ct);
            _logger.LogInformation("Push notification sent successfully. MessageId: {MessageId}", response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send push notification to token");
        }
    }

    public async Task SendMulticastAsync(
        List<string> fcmTokens,
        string title,
        string body,
        string? data = null,
        CancellationToken ct = default)
    {
        if (fcmTokens == null || fcmTokens.Count == 0) return;

        try
        {
            var message = new MulticastMessage
            {
                Tokens = fcmTokens,
                Notification = new Notification
                {
                    Title = title,
                    Body = body
                },
                Data = string.IsNullOrEmpty(data) ? null :
                       System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, string>>(data)
            };

            var response = await _firebaseMessaging.SendMulticastAsync(message, ct);
            _logger.LogInformation("Multicast push sent. Success: {Success}, Failure: {Failure}",
                response.SuccessCount, response.FailureCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send multicast push notification");
        }
    }

    public void Dispose()
    {
        if (!_disposed)
        {
            FirebaseApp.DefaultInstance?.Delete();
            _disposed = true;
        }
    }
}