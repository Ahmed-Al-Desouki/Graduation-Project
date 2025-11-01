using HealthCare_.Models.DTOs.Email;
using HealthCare_.Models.sharedModels;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Services.Auth
{
    public class MfaService : IMfaService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly HealthCarePlusContext _context;
        private readonly IEmailService _emailService;
        private readonly ILogger<MfaService> _logger;

        public MfaService(
            UserManager<ApplicationUser> userManager,
            HealthCarePlusContext context,
            IEmailService emailService,
            ILogger<MfaService> logger)
        {
            _userManager = userManager;
            _context = context;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task GenerateAndSendOtpAsync(ApplicationUser user, IEmailService emailService)
        {
            var oldOtps = await _context.EmailOtps
                .Where(o => o.UserId == user.Id && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var old in oldOtps) old.IsUsed = true;

            var code = new Random().Next(100000, 999999).ToString("D6");
            var expiresAt = DateTime.UtcNow.AddMinutes(5);

            var otp = new EmailOTP
            {
                UserId = user.Id,
                Code = code,
                ExpiresAt = expiresAt,
                IsUsed = false
            };

            _context.EmailOtps.Add(otp);
            await _context.SaveChangesAsync();

            var subject = "Your HealthCare Login Code";
            var html = $@"
                <div style='font-family: Arial; text-align: center; padding: 20px;'>
                    <h2>Your One-Time Login Code</h2>
                    <p>Use this code to complete your login:</p>
                    <h1 style='font-size: 36px; color: #0e76a8; letter-spacing: 5px;'>{code}</h1>
                    <p>This code expires in <strong>5 minutes</strong>.</p>
                    <hr><small>If you didn't request this, ignore this email.</small>
                </div>";

            await emailService.SendEmailAsync(user.Email!, subject, html);
            _logger.LogInformation("OTP sent to {Email}: {Code}", user.Email, code);
        }

        public async Task<(bool Succeeded, string Error)> VerifyMfaAsync(int userId, string otpCode)
        {
            var otp = await _context.EmailOtps
                .FirstOrDefaultAsync(o => o.UserId == userId && o.Code == otpCode && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow);

            if (otp == null) return (false, "Invalid or expired OTP");

            otp.IsUsed = true;
            await _context.SaveChangesAsync();

            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user != null)
                await _userManager.AddClaimAsync(user, new Claim("amr", "mfa"));

            return (true, "");
        }

        public async Task<(bool Succeeded, string Message, string Error)> EnableMfaAsync(int userId, IEmailService emailService)
        {
            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null) return (false, "", "User not found");
            if (user.TwoFactorEnabled) return (false, "", "MFA already enabled");

            user.TwoFactorEnabled = true;
            var result = await _userManager.UpdateAsync(user);
            if (!result.Succeeded) return (false, "", "Failed to enable MFA");

            await GenerateAndSendOtpAsync(user, emailService);
            return (true, "Check your email for the login code.", "");
        }
    }
}