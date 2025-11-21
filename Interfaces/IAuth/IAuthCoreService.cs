using HealthCare_.Models.DTOs.Email;
using HealthCare_.Models.sharedModels;
using static Google.Apis.Auth.OAuth2.Web.AuthorizationCodeWebApp;

namespace HealthCare_.Services.Auth.Interfaces
{
    public interface IAuthCoreService
    {
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
            LoginRequest request, string? deviceInfo = null, string? ipAddress = null, IEmailService? emailService = null);
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);
        Task<(string AccessToken, string RefreshToken, string? Error)> ExternalLoginAsync(
        ApplicationUser user,
        string? deviceInfo = null,
        string? ipAddress = null,
        IEmailService? emailService = null);

    }
}