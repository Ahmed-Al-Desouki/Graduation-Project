

using HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys;

namespace HealthCare_.Interfaces
{
    public interface IAuthService
    {
        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);
        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(LoginRequest request, string? deviceInfo = null, string? ipAddress = null);
        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);
        Task<int?> GetRoleIdFromDbAsync(string roleName);
        Task<(bool Succeeded, int? RoleId, string Error)> CreateRoleAsync(string roleName, string description);
        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(RefreshRequest request, string? deviceInfo = null, string? ipAddress = null);
        Task<(bool Succeeded, string QrCodeUrl, string[] RecoveryCodes, string Error)> EnableMfaAsync(int userId);
        Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode);
        Task<string> GeneratePasskeyChallengeAsync(string userId);
        Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, string credentialId, string publicKey); // التوقيع القديم
       // Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, PasskeyRegisterRequest request); // التوقيع الجديد
        Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(PasskeyLoginRequest request, string? deviceInfo = null, string? ipAddress = null);

    }

}
