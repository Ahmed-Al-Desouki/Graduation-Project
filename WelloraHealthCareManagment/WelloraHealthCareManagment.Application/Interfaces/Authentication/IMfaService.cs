using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IMfaService
    {
        // Generate OTP and send it via email
        Task<bool> GenerateAndSendOtpAsync(ApplicationUser user);

        // Verify OTP code provided by user
        Task<(bool Succeeded, string Error)> VerifyOtpAsync(int userId, string otpCode);

        // Resend OTP using user ID
        Task<(bool Succeeded, string Error)> ResendOtpAsync(int userId);

        // Enable MFA for a user
        Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId);

        // Disable MFA for a user
        Task<(bool Succeeded, string Error)> DisableMfaAsync(int userId);

        // Check if user has MFA enabled
        Task<bool> IsMfaEnabledAsync(int userId);
    }
}
