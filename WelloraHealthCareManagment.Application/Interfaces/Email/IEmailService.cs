using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Email
{
    public interface IEmailService
    {

        /// Send a generic email with HTML content
        Task<bool> SendEmailAsync(string toEmail, string subject, string htmlMessage);


        /// Send OTP code email for MFA
        Task<bool> SendOtpEmailAsync(string toEmail, string otpCode, string userName);


        /// Send password reset email
        Task<bool> SendPasswordResetEmailAsync(string toEmail, string resetToken, string userName);


        /// Send welcome email after registration
        Task<bool> SendWelcomeEmailAsync(string toEmail, string userName);


        /// Send email verification
        Task<bool> SendEmailVerificationAsync(string toEmail, string verificationToken, string userName);
    }
}
