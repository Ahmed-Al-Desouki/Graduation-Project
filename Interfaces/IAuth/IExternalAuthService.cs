namespace HealthCare_.Services.Auth.Interfaces
{
    public interface IExternalAuthService
    {
        Task<(string AccessToken, string RefreshToken, string Error)> ExternalLoginAsync(
            string? deviceInfo = null, string? ipAddress = null);
    }
}