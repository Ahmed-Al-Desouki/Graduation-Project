using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.Extensions.Logging;
using System.Security.Claims;
using System.Security.Cryptography;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Email;


namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class MfaService : IMfaService
    {
        private readonly IOtpRepository _otpRepository;
        private readonly IUserRepository _userRepository;
        private readonly IEmailService _emailService;
        private readonly ILogger<MfaService> _logger;
        private const int OTP_LENGTH = 6;
        private const int OTP_EXPIRY_MINUTES = 1;

        public MfaService(
            IOtpRepository otpRepository,
            IUserRepository userRepository,
            IEmailService emailService,
            ILogger<MfaService> logger)
        {
            _otpRepository = otpRepository;
            _userRepository = userRepository;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task<bool> GenerateAndSendOtpAsync(ApplicationUser user)
        {
            if (user == null || string.IsNullOrEmpty(user.Email))
            {
                _logger.LogWarning("Cannot generate OTP for null user or empty email");
                return false;
            }

            try
            {
                // 1. إبطال كل OTPs القديمة
                await _otpRepository.InvalidateAllUserOtpsAsync(user.Id);

                // 2. توليد OTP آمن
                var code = GenerateSecureOtp(OTP_LENGTH);
                var expiresAt = DateTime.UtcNow.AddMinutes(OTP_EXPIRY_MINUTES);

                // 3. حفظ OTP في Database
                await _otpRepository.CreateOtpAsync(user.Id, code, expiresAt);

                // 4. إرسال Email
                var emailSent = await _emailService.SendOtpEmailAsync(
                    user.Email,
                    code,
                    user.FullName);

                if (!emailSent)
                {
                    _logger.LogError("Failed to send OTP email to {Email}", user.Email);
                    return false;
                }

                _logger.LogInformation("OTP generated and sent to {Email}", user.Email);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating/sending OTP for user {UserId}", user.Id);
                return false;
            }
        }

        public async Task<(bool Succeeded, string Error)> VerifyOtpAsync(int userId, string otpCode)
        {
            if (string.IsNullOrWhiteSpace(otpCode))
                return (false, "OTP code is required");

            try
            {
                // 1. التحقق من OTP في Database
                var otp = await _otpRepository.GetValidOtpAsync(userId, otpCode.Trim());

                if (otp == null)
                {
                    _logger.LogWarning("Invalid or expired OTP attempt for user {UserId}", userId);
                    return (false, "Invalid or expired OTP code");
                }

                // 2. تعليم OTP كـ مستخدم
                await _otpRepository.MarkOtpAsUsedAsync(otp);

                // 3. إضافة MFA Claim للـ User
                var user = await _userRepository.GetByIdAsync(userId);
                if (user != null)
                {
                    await _userRepository.AddClaimAsync(user, new Claim("amr", "mfa"));
                }

                _logger.LogInformation("OTP verified successfully for user {UserId}", userId);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error verifying OTP for user {UserId}", userId);
                return (false, "An error occurred while verifying OTP");
            }
        }

        public async Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null)
                    return (false, string.Empty, "User not found");

                if (user.TwoFactorEnabled)
                    return (false, string.Empty, "MFA is already enabled");

                // 1. تفعيل MFA
                var result = await _userRepository.SetTwoFactorEnabledAsync(userId, true);
                if (!result.Succeeded)
                    return (false, string.Empty, "Failed to enable MFA");

                // 2. إرسال OTP
                var otpSent = await GenerateAndSendOtpAsync(user);
                if (!otpSent)
                    return (false, string.Empty, "MFA enabled but failed to send OTP");

                _logger.LogInformation("MFA enabled for user {UserId}", userId);
                return (true, "MFA enabled. Check your email for the verification code.", string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error enabling MFA for user {UserId}", userId);
                return (false, string.Empty, "An error occurred while enabling MFA");
            }
        }

        public async Task<(bool Succeeded, string Error)> DisableMfaAsync(int userId)
        {
            try
            {
                var user = await _userRepository.GetByIdAsync(userId);
                if (user == null)
                    return (false, "User not found");

                if (!user.TwoFactorEnabled)
                    return (false, "MFA is already disabled");

                // 1. تعطيل MFA
                var result = await _userRepository.SetTwoFactorEnabledAsync(userId, false);
                if (!result.Succeeded)
                    return (false, "Failed to disable MFA");

                // 2. إبطال كل OTPs
                await _otpRepository.InvalidateAllUserOtpsAsync(userId);

                _logger.LogInformation("MFA disabled for user {UserId}", userId);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error disabling MFA for user {UserId}", userId);
                return (false, "An error occurred while disabling MFA");
            }
        }

        public async Task<bool> IsMfaEnabledAsync(int userId)
        {
            return await _userRepository.IsTwoFactorEnabledAsync(userId);
        }

        #region Private Helpers

        /// Generate cryptographically secure OTP
        private string GenerateSecureOtp(int length)
        {
            // استخدام RandomNumberGenerator بدلاً من Random (أكثر أماناً)
            var buffer = new byte[length];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(buffer);

            // تحويل لأرقام من 0-9
            var otp = new char[length];
            for (int i = 0; i < length; i++)
            {
                otp[i] = (char)('0' + (buffer[i] % 10));
            }

            return new string(otp);
        }

        #endregion
    }
}