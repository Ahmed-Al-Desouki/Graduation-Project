using HealthCare_.Models.DTOs.AuthModels.ForgetPassword;
using Microsoft.AspNetCore.WebUtilities;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Text;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class PasswordService : IPasswordService
    {
        private readonly IUserRepository _userRepository;
        private readonly IUserSessionRepository _sessionRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IEmailService _emailService;
        private readonly INotificationService _notificationService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<PasswordService> _logger;

        public PasswordService(
            IUserRepository userRepository,
            IUserSessionRepository sessionRepository,
            IRefreshTokenRepository refreshTokenRepository,
            IEmailService emailService,
            INotificationService notificationService,
            IConfiguration configuration,
            ILogger<PasswordService> logger)
        {
            _userRepository = userRepository;
            _sessionRepository = sessionRepository;
            _refreshTokenRepository = refreshTokenRepository;
            _emailService = emailService;
            _notificationService = notificationService;
            _configuration = configuration;
            _logger = logger;
        }

        //public async Task<(bool Succeeded, string Error)> ForgotPasswordAsync(
        //    string email,
        //    string? origin = null)
        //{
        //    try
        //    {
        //        // 1. Find user by email
        //        var user = await _userRepository.GetByEmailAsync(email);

        //        // Security: Always return success even if user not found (prevent email enumeration)
        //        if (user == null || !await _userRepository.IsEmailConfirmedAsync(user))
        //        {
        //            _logger.LogWarning("Password reset attempted for non-existent or unconfirmed email: {Email}", email);
        //            return (true, string.Empty); // Return success to prevent email enumeration
        //        }

        //        // 2. Generate password reset token
        //        var token = await _userRepository.GeneratePasswordResetTokenAsync(user);
        //        var encodedToken = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(token));

        //        // 3. Build reset link
        //        var appUrl = origin ?? _configuration["AppUrl"] ?? "http://localhost:3000";
        //        var resetLink = $"{appUrl}/reset-password?email={Uri.EscapeDataString(email)}&token={encodedToken}";

        //        // 4. Send email
        //        var emailSent = await _emailService.SendPasswordResetEmailAsync(
        //            email,
        //            resetLink,
        //            user.FullName);

        //        if (!emailSent)
        //        {
        //            _logger.LogError("Failed to send password reset email to {Email}", email);
        //            return (false, "Failed to send email. Please try again.");
        //        }

        //        _logger.LogInformation("Password reset link sent to {Email}", email);
        //        return (true, string.Empty);
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex, "Error in ForgotPasswordAsync for email: {Email}", email);
        //        return (false, "An error occurred. Please try again.");
        //    }
        //}
        public async Task<(bool Succeeded, string Error)> ForgotPasswordAsync(
    string email,
    string? origin = null)
        {
            try
            {
                // 1. Find user by email
                var user = await _userRepository.GetByEmailAsync(email);

                // Security: Always return success even if user not found
                if (user == null || !await _userRepository.IsEmailConfirmedAsync(user))
                {
                    _logger.LogWarning("Password reset attempted for non-existent or unconfirmed email: {Email}", email);
                    return (true, string.Empty);
                }

                // 2. Generate password reset token
                var token = await _userRepository.GeneratePasswordResetTokenAsync(user);
                var encodedToken = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(token));

                // 3. Build reset link
                // Use origin from parameter, fallback to AppUrl from config
                var appUrl = origin ?? _configuration["AppUrl"] ?? "https://medicare-plus.runasp.net";

                // Remove trailing slash if exists
                appUrl = appUrl.TrimEnd('/');

                var resetLink = $"{appUrl}/reset-password?email={Uri.EscapeDataString(email)}&token={encodedToken}";

                _logger.LogInformation("Reset link generated: {ResetLink}", resetLink);

                // 4. Send email
                var emailSent = await _emailService.SendPasswordResetEmailAsync(
                    email,
                    resetLink,  // ✅ Pass complete link
                    user.FullName);

                if (!emailSent)
                {
                    _logger.LogError("Failed to send password reset email to {Email}", email);
                    return (false, "Failed to send email. Please try again.");
                }

                _logger.LogInformation("Password reset link sent to {Email}", email);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in ForgotPasswordAsync for email: {Email}", email);
                return (false, "An error occurred. Please try again.");
            }
        }
        public async Task<(bool Succeeded, string Error)> ResetPasswordAsync(
            ResetPasswordRequest request)
        {
            try
            {
                // 1. Validate passwords match
                if (request.NewPassword != request.ConfirmPassword)
                {
                    return (false, "Passwords do not match");
                }

                // 2. Find user
                var user = await _userRepository.GetByEmailAsync(request.Email);
                if (user == null)
                {
                    _logger.LogWarning("Password reset attempted for non-existent user: {Email}", request.Email);
                    return (false, "Invalid reset request");
                }

                // 3. Decode token
                byte[] tokenBytes;
                try
                {
                    tokenBytes = WebEncoders.Base64UrlDecode(request.Token);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Invalid token format for email: {Email}", request.Email);
                    return (false, "Invalid or corrupted token");
                }

                var token = Encoding.UTF8.GetString(tokenBytes);

                // 4. Reset password
                var result = await _userRepository.ResetPasswordAsync(user, token, request.NewPassword);
                if (!result.Succeeded)
                {
                    var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                    _logger.LogWarning("Password reset failed for {Email}: {Errors}", request.Email, errors);
                    return (false, errors);
                }

                // 5. Revoke all active sessions (security measure)
                await _sessionRepository.RevokeAllUserSessionsAsync(
                    user.Id,
                    "Password reset - security measure");

                // 6. Revoke all refresh tokens (security measure)
                await _refreshTokenRepository.RevokeAllUserTokensAsync(user.Id);

                await _notificationService.NotifyAsync(new NotificationDispatchRequest
                {
                    UserId = user.Id,
                    Title = "Password Changed",
                    Message = $"The password for your account (User #{user.Id}) was changed successfully, and all active sessions were revoked for security.",
                    Type = NotificationType.PasswordReset,
                    RelatedEntityType = "User",
                    RelatedEntityId = user.Id,
                    Data = new Dictionary<string, string> { ["userId"] = user.Id.ToString() }
                });

                _logger.LogInformation("Password reset successfully for {Email}. All sessions revoked.", request.Email);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in ResetPasswordAsync for email: {Email}", request.Email);
                return (false, "An error occurred. Please try again.");
            }
        }
    }
}
