using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Text.Json;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagement.Infrastructure.Services;

public class FirebaseNotificationService : IFirebaseNotificationService, IDisposable
{
    private readonly FirebaseMessaging? _firebaseMessaging;
    private readonly ILogger<FirebaseNotificationService> _logger;
    private readonly bool _isInitialized;
    private readonly HashSet<string> _suppressedInvalidTokens = new(StringComparer.Ordinal);
    private DateTimeOffset? _authFailureMuteUntilUtc;
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
                    Credential = BuildGoogleCredential(settings.ServiceAccountPath)
                });
            }

            _firebaseMessaging = FirebaseMessaging.DefaultInstance;
            _isInitialized = true;
            _logger.LogInformation("Firebase Messaging initialized successfully");
        }
        catch (Exception ex)
        {
            _isInitialized = false;
            _logger.LogError(ex, "Failed to initialize Firebase Messaging. Push notifications are disabled.");
        }
    }

    public async Task SendPushAsync(
        string fcmToken,
        string title,
        string body,
        string? data = null,
        CancellationToken ct = default)
    {
        if (_suppressedInvalidTokens.Contains(fcmToken))
        {
            return;
        }

        if (!_isInitialized || _firebaseMessaging is null)
        {
            return;
        }

        if (IsAuthFailureMuted())
        {
            return;
        }

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
            HandleAuthFailure(ex);
            HandleInvalidTokenFailure(fcmToken, ex);
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
        if (!_isInitialized || _firebaseMessaging is null)
        {
            return;
        }

        if (IsAuthFailureMuted())
        {
            return;
        }

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
            HandleAuthFailure(ex);
            _logger.LogError(ex, "Failed to send multicast push notification");
        }
    }

    private GoogleCredential BuildGoogleCredential(string serviceAccountPath)
    {
        if (string.IsNullOrWhiteSpace(serviceAccountPath))
        {
            throw new InvalidOperationException("Firebase:ServiceAccountPath is empty.");
        }

        if (!File.Exists(serviceAccountPath))
        {
            throw new FileNotFoundException(
                $"Firebase service account file was not found at: {serviceAccountPath}",
                serviceAccountPath);
        }

        var rawContent = File.ReadAllText(serviceAccountPath).TrimStart();

        if (!rawContent.StartsWith("{", StringComparison.Ordinal))
        {
            return GoogleCredential.FromFile(serviceAccountPath);
        }

        var normalizedJson = NormalizePrivateKey(rawContent);
        return GoogleCredential.FromJson(normalizedJson);
    }

    private static string NormalizePrivateKey(string serviceAccountJson)
    {
        try
        {
            using var document = JsonDocument.Parse(serviceAccountJson);
            if (!document.RootElement.TryGetProperty("private_key", out var privateKeyElement))
            {
                return serviceAccountJson;
            }

            var privateKey = privateKeyElement.GetString();
            if (string.IsNullOrEmpty(privateKey) || !privateKey.Contains("\\n"))
            {
                return serviceAccountJson;
            }

            var normalizedPrivateKey = privateKey.Replace("\\n", "\n");
            return serviceAccountJson.Replace(privateKey, normalizedPrivateKey);
        }
        catch (JsonException)
        {
            return serviceAccountJson;
        }
    }

    private bool IsAuthFailureMuted()
    {
        if (_authFailureMuteUntilUtc is null)
        {
            return false;
        }

        if (DateTimeOffset.UtcNow < _authFailureMuteUntilUtc.Value)
        {
            return true;
        }

        _authFailureMuteUntilUtc = null;
        return false;
    }

    private void HandleAuthFailure(Exception ex)
    {
        if (!IsFirebaseAuthFailure(ex))
        {
            return;
        }

        if (_authFailureMuteUntilUtc is not null && DateTimeOffset.UtcNow < _authFailureMuteUntilUtc.Value)
        {
            return;
        }

        _authFailureMuteUntilUtc = DateTimeOffset.UtcNow.AddMinutes(15);
        _logger.LogWarning(
            "Firebase authentication is failing (invalid_grant / invalid JWT signature). " +
            "Push sending will be muted until {MuteUntilUtc:u}. Verify Firebase service-account JSON, " +
            "rotate the key, and check server UTC clock.",
            _authFailureMuteUntilUtc.Value);
    }

    private static bool IsFirebaseAuthFailure(Exception ex)
    {
        return ex.ToString().Contains("invalid_grant", StringComparison.OrdinalIgnoreCase)
               || ex.ToString().Contains("Invalid JWT Signature", StringComparison.OrdinalIgnoreCase);
    }

    private void HandleInvalidTokenFailure(string fcmToken, Exception ex)
    {
        var message = ex.ToString();
        var isTokenOrProjectMismatch = message.Contains("Requested entity was not found", StringComparison.OrdinalIgnoreCase)
                                       || message.Contains("SenderId mismatch", StringComparison.OrdinalIgnoreCase)
                                       || message.Contains("registration token is not a valid FCM registration token", StringComparison.OrdinalIgnoreCase);

        if (!isTokenOrProjectMismatch)
        {
            return;
        }

        if (_suppressedInvalidTokens.Add(fcmToken))
        {
            _logger.LogWarning(
                "Suppressing future push attempts for invalid/mismatched FCM token. " +
                "TokenPrefix: {TokenPrefix}. Ask client to refresh token and ensure same Firebase project is used.",
                fcmToken.Length >= 12 ? fcmToken[..12] : fcmToken);
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