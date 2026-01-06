using HealthCare_.Interfaces.Email;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace HealthCare_.Interfaces.IAuth.MFA
{
    public interface IMfaService
    {
        Task GenerateAndSendOtpAsync(ApplicationUser user, IEmailService emailService);
        Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode);
        Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId, IEmailService emailService);
    }
}