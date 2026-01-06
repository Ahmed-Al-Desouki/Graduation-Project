using HealthCare_.Models.DTOs.AuthModels.ForgetPassword;

namespace HealthCare_.Interfaces.IAuth.PKeyAndPassowrd
{
    public interface IPasswordService
    {
        Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string? origin = null);
        Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request);
    }
}