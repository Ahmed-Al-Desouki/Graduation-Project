namespace HealthCare_.Interfaces.IAuth.GoogleSignIn
{
    public interface IExternalAuthService
    {
        Task<(string AccessToken, string RefreshToken, string Error)> ExternalLoginAsync(
            string? deviceInfo = null, string? ipAddress = null);
    }
}