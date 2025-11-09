using HealthCare_.Models.sharedModels;

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
        (string PlainText, string Error) DecryptAes(string cipherTextBase64, string saltBase64);

        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
            RefreshRequest request, string? deviceInfo = null, string? ipAddress = null);
        Task<(string MfaToken, string Jti, string? Error)> GenerateMfaTokenAsync(ApplicationUser user);
        ClaimsPrincipal? ValidateJwtToken(string token);
    }


}