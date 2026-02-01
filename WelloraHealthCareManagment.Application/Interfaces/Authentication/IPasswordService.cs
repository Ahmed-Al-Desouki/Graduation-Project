using HealthCare_.Models.DTOs.AuthModels.ForgetPassword;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IPasswordService
    {

        /// Send password reset link via email
        Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string? origin = null);

        /// Reset user password with token
        Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request);
    }
}
