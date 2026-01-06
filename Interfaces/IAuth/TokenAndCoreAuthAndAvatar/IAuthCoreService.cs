using HealthCare_.Interfaces.Email;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace HealthCare_.Interfaces.IAuth.TokenAndCoreAuth
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