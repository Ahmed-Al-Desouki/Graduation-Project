namespace HealthCare_.Services.Auth.Interfaces
{
    public interface IPasskeyService
    {
        Task<(bool Succeeded, string Error, string? AccessToken)> RegisterPasskeyAsync(
            int userId, string credentialId, string publicKey);
        Task<string> GeneratePasskeyChallengeAsync(string userId);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(
            PasskeyLoginRequest request, string? deviceInfo = null, string? ipAddress = null);
    }
}