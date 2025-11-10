using HealthCare_.Models.sharedModels;

namespace HealthCare_.Services.Auth.Interfaces
{
    public interface IMfaService
    {
        Task GenerateAndSendOtpAsync(ApplicationUser user, IEmailService emailService);
        Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode);
        Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId, IEmailService emailService);
    }
}