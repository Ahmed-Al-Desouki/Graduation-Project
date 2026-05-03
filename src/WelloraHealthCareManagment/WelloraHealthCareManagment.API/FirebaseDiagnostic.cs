using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using WelloraHealthCareManagment.Application.Common;

namespace WelloraHealthCareManagment.API;

public class FirebaseDiagnostic
{
    private readonly ILogger<FirebaseDiagnostic> _logger;
    private readonly IOptions<FirebaseSettings> _firebaseSettings;

    public FirebaseDiagnostic(ILogger<FirebaseDiagnostic> logger, IOptions<FirebaseSettings> firebaseSettings)
    {
        _logger = logger;
        _firebaseSettings = firebaseSettings;
    }

    public async Task<bool> TestFirebaseConnectionAsync()
    {
        try
        {
            var settings = _firebaseSettings.Value;
            _logger.LogInformation("Testing Firebase connection with service account: {ServiceAccountPath}", settings.ServiceAccountPath);

            // Check if file exists
            if (!File.Exists(settings.ServiceAccountPath))
            {
                _logger.LogError("Service account file not found: {ServiceAccountPath}", settings.ServiceAccountPath);
                return false;
            }

            // Try to load the credential
            var credential = GoogleCredential.FromFile(settings.ServiceAccountPath);
            _logger.LogInformation("Service account loaded successfully");

            // Check if it's the correct project
            var serviceAccountJson = File.ReadAllText(settings.ServiceAccountPath);
            var serviceAccount = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(serviceAccountJson);
            
            if (serviceAccount.TryGetValue("project_id", out var projectId))
            {
                _logger.LogInformation("Firebase Project ID: {ProjectId}", projectId);
            }

            // Try to initialize Firebase app
            var app = FirebaseApp.Create(new AppOptions()
            {
                Credential = credential,
                ProjectId = serviceAccount?.ContainsKey("project_id") == true ? serviceAccount["project_id"].ToString() : null
            });

            var messaging = FirebaseMessaging.GetMessaging(app);
            
            // Try to send a test message to a dummy token (this will fail but should authenticate)
            var testMessage = new Message
            {
                Token = "test_token",
                Notification = new Notification
                {
                    Title = "Test",
                    Body = "Test Message"
                }
            };

            try
            {
                await messaging.SendAsync(testMessage);
            }
            catch (FirebaseMessagingException ex)
            {
                // We expect this to fail with "invalid-registration-token" but authentication should succeed
                if (ex.Message.Contains("registration-token-not-registered") || ex.Message.Contains("Unregistered"))
                {
                    _logger.LogInformation("Firebase authentication successful - test message failed as expected (invalid token)");
                    app.Delete();
                    return true;
                }
                else
                {
                    _logger.LogError(ex, "Firebase authentication failed: {ErrorMessage}", ex.Message);
                    app.Delete();
                    return false;
                }
            }

            app.Delete();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Firebase diagnostic failed: {ErrorMessage}", ex.Message);
            return false;
        }
    }
}
