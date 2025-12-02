//namespace HealthCare_.Interfaces.IAuth
//{
//    public interface IAuthService
//    {
//        Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string origin);
//        Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request);
//        Task<(bool Succeeded, string[] Errors)> RegisterAsync(RegisterRequest request);

//        Task<(string AccessToken, string RefreshToken, string Error)> LoginAsync(
//            LoginRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null,
//            IEmailService? emailService = null);

//        Task<(string AccessToken, string RefreshToken, string Error)> ExternalLoginAsync(
//            string? deviceInfo = null,
//            string? ipAddress = null);

//        Task<(bool Succeeded, string Error)> LogoutAsync(LogoutRequest request);

//        Task<int?> GetRoleIdFromDbAsync(string roleName);

//        Task<(bool Succeeded, int? RoleId, string Error)> CreateRoleAsync(string roleName, string description);

//        Task<(string AccessToken, string RefreshToken, string Error)> RefreshTokenAsync(
//            RefreshRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null);

//        Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId, IEmailService emailService);

//        Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode);

//        Task<string> GeneratePasskeyChallengeAsync(string userId);

//        Task<(bool Succeeded, string Error)> RegisterPasskeyAsync(int userId, string credentialId, string publicKey);

//        Task<(string AccessToken, string RefreshToken, string Error)> LoginWithPasskeyAsync(
//            PasskeyLoginRequest request,
//            string? deviceInfo = null,
//            string? ipAddress = null);


//        Task GenerateAndSendOtpAsync(ApplicationUser user, IEmailService emailService);
//    }
//}