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

        /// Send doctor verification approval email
        Task<bool> SendDoctorVerificationApprovedEmailAsync(string toEmail, string userName, string? adminNotes = null);

        /// Send doctor verification rejection email
        Task<bool> SendDoctorVerificationRejectedEmailAsync(string toEmail, string userName, string rejectionReason, string? adminNotes = null);

        /// Send account blocked email
        Task<bool> SendAccountBlockedEmailAsync(string toEmail, string userName, string reason);

        /// Send account unblocked email
        Task<bool> SendAccountUnblockedEmailAsync(string toEmail, string userName);

        /// Send account suspended email
        Task<bool> SendAccountSuspendedEmailAsync(string toEmail, string userName, DateTime suspensionEnd, string reason);

        /// Send account unsuspended email
        Task<bool> SendAccountUnsuspendedEmailAsync(string toEmail, string userName);
    }
}
