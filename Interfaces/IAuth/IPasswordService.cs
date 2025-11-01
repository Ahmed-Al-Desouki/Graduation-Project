using HealthCare_.Models.DTOs.ForgetPassword;

namespace HealthCare_.Services.Auth.Interfaces
{
    public interface IPasswordService
    {
        Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string? origin = null);
        Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request);
    }
}