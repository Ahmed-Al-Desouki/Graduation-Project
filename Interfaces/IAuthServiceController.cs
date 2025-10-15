

using HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys;

namespace HealthCare_.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(LoginRequest request, string? deviceInfo, string? ipAddress);
        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(RefreshRequest request, string? deviceInfo, string? ipAddress);
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);
        Task<(bool Succeeded, string QrCodeUrl, string[] RecoveryCodes, string Error)> EnableMfaAsync(int userId);
        Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode);
        Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, string credentialId, string publicKey);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(PasskeyLoginRequest request, string? deviceInfo, string? ipAddress);
        Task<int?> GetRoleIdFromDbAsync(string roleName);
        Task<(bool Succeeded, int? RoleId, string Error)> CreateRoleAsync(string roleName, string description);
        Task<string> GeneratePasskeyChallengeAsync(string userId);

    }

}
