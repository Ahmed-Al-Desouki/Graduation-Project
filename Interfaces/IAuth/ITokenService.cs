namespace HealthCare_.Services.Auth.Interfaces
{
    public interface ITokenService
    {
        Task<(string AccessToken, string Jti, string? Error)> GenerateJwtToken(
            ApplicationUser user,
            TimeSpan? expiry = null);
        string GenerateRandomToken();
        string ComputeHmacSha256Base64(string input);
        (string EncryptedText, string Salt) EncryptAes(string plainText);
        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
            RefreshRequest request, string? deviceInfo = null, string? ipAddress = null);
    }
}