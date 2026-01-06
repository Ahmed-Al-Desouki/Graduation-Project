using HealthCare_.Interfaces.Email;
using HealthCare_.Interfaces.IAuth.PKeyAndPassowrd;
using HealthCare_.Models.DTOs.AuthModels.ForgetPassword;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.WebUtilities;

namespace HealthCare_.Services.Auth
{
    public class PasswordService : IPasswordService
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly HealthCarePlusContext _context;
        private readonly IConfiguration _configuration;
        private readonly IEmailService _emailService;
        private readonly ILogger<PasswordService> _logger;

        public PasswordService(
            UserManager<ApplicationUser> userManager,
            HealthCarePlusContext context,
            IConfiguration configuration,
            IEmailService emailService,
            ILogger<PasswordService> logger)
        {
            _userManager = userManager;
            _context = context;
            _configuration = configuration;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task<(bool Succeeded, string Error)> ForgotPasswordAsync(string email, string? origin = null)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null || !await _userManager.IsEmailConfirmedAsync(user))
                return (true, string.Empty);

            var token = await _userManager.GeneratePasswordResetTokenAsync(user);
            var encodedToken = WebEncoders.Base64UrlEncode(Encoding.UTF8.GetBytes(token));

            var appUrl = origin ?? _configuration["AppUrl"] ?? "http://localhost:3000";
            var resetLink = $"{appUrl}/reset-password?email={Uri.EscapeDataString(email)}&token={encodedToken}";

            var subject = "Reset Your HealthCare Password";
            var html = $@"
            <!DOCTYPE html>
            <html lang='en' dir='ltr'>
            <head>
                <meta charset='UTF-8'>
                <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                <title>Reset Your Password</title>
                <link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap' rel='stylesheet'>
                <style>
                    * {{ margin: 0; padding: 0; box-sizing: border-box; }}
                    body {{
                        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
                        padding: 20px;
                        color: #1a1a1a;
                        line-height: 1.6;
                    }}
                    .container {{
                        max-width: 480px;
                        margin: 40px auto;
                        background: #ffffff;
                        border-radius: 20px;
                        overflow: hidden;
                        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.08);
                        animation: fadeIn 0.6s ease-out;
                    }}
                    @keyframes fadeIn {{
                        from {{ opacity: 0; transform: translateY(20px); }}
                        to {{ opacity: 1; transform: translateY(0); }}
                    }}
                    .header {{
                        background: linear-gradient(120deg, #0e76a8 0%, #1e90ff 100%);
                        padding: 40px 30px;
                        text-align: center;
                        color: white;
                    }}
                    .header h1 {{
                        font-size: 28px;
                        font-weight: 700;
                        margin: 0;
                        letter-spacing: -0.5px;
                    }}
                    .header p {{
                        font-size: 16px;
                        opacity: 0.9;
                        margin-top: 8px;
                    }}
                    .content {{
                        padding: 40px 30px;
                        text-align: center;
                    }}
                    .content h2 {{
                        font-size: 22px;
                        color: #0e76a8;
                        margin-bottom: 12px;
                        font-weight: 600;
                    }}
                    .content p {{
                        font-size: 16px;
                        color: #444;
                        margin-bottom: 20px;
                    }}
                    .btn {{
                        display: inline-block;
                        background: linear-gradient(45deg, #0e76a8, #1e90ff);
                        color: white;
                        font-weight: 600;
                        font-size: 17px;
                        padding: 16px 40px;
                        border-radius: 50px;
                        text-decoration: none;
                        box-shadow: 0 8px 20px rgba(14, 118, 168, 0.3);
                        transition: all 0.3s ease;
                        margin: 10px 0;
                    }}
                    .btn:hover {{
                        transform: translateY(-3px);
                        box-shadow: 0 12px 25px rgba(14, 118, 168, 0.4);
                    }}
                    .expires {{
                        font-size: 14px;
                        color: #e74c3c;
                        font-weight: 500;
                        margin: 25px 0 15px;
                    }}
                    .footer {{
                        background: #f8f9fa;
                        padding: 25px;
                        text-align: center;
                        font-size: 13px;
                        color: #777;
                        border-top: 1px solid #eee;
                    }}
                    .footer a {{
                        color: #0e76a8;
                        text-decoration: none;
                    }}
                    .security {{
                        margin-top: 20px;
                        font-size: 13px;
                        color: #888;
                    }}
                    @media (prefers-color-scheme: dark) {{
                        body {{ background: #0f172a; color: #e2e8f0; }}
                        .container {{ background: #1e293b; box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3); }}
                        .content p {{ color: #cbd5e1; }}
                        .footer {{ background: #0f172a; border-top: 1px solid #334155; color: #94a3b8; }}
                    }}
                    @media (max-width: 480px) {{
                        .container {{ margin: 20px auto; }}
                        .header, .content {{ padding: 30px 20px; }}
                        .btn {{ padding: 14px 32px; font-size: 16px; }}
                    }}
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1>HealthCare</h1>
                        <p>Secure • Modern • Trusted</p>
                    </div>
                    <div class='content'>
                        <h2>Reset Your Password</h2>
                        <p>Hello <strong>{user.FullName}</strong>,</p>
                        <p>We received a request to reset your password. Click the button below to proceed.</p>
                        <a href='{resetLink}' class='btn'>Reset Password</a>
                        <p class='expires'>This link expires in <strong>1 hour</strong> for your security.</p>
                        <p class='security'>If you didn't request this, no action is needed your account remains secure.</p>
                    </div>
                    <div class='footer'>
                        <p>© 2025 <strong>HealthCare App</strong>. All rights reserved.</p>
                        <p><a href='#'>Privacy Policy</a> • <a href='#'>Support</a></p>
                    </div>
                </div>
            </body>
            </html>";

            try
            {
                await _emailService.SendEmailAsync(email, subject, html);
                _logger.LogInformation("Password reset link sent to {Email}", email);
                return (true, string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send password reset email to {Email}", email);
                return (false, "Failed to send email. Please try again.");
            }
        }

        public async Task<(bool Succeeded, string Error)> ResetPasswordAsync(ResetPasswordRequest request)
        {
            if (request.NewPassword != request.ConfirmPassword)
                return (false, "Passwords do not match");

            var user = await _userManager.FindByEmailAsync(request.Email);
            if (user == null)
                return (false, "Invalid reset request");

            byte[] tokenBytes;
            try
            {
                tokenBytes = WebEncoders.Base64UrlDecode(request.Token);
            }
            catch
            {
                return (false, "Invalid or corrupted token");
            }

            var token = Encoding.UTF8.GetString(tokenBytes);

            var result = await _userManager.ResetPasswordAsync(user, token, request.NewPassword);
            if (!result.Succeeded)
            {
                var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                _logger.LogWarning("Password reset failed for {Email}: {Errors}", request.Email, errors);
                return (false, errors);
            }

            var sessions = await _context.UserSessions
                .Where(s => s.UserId == user.Id && !s.IsRevoked)
                .ToListAsync();

            foreach (var s in sessions)
                s.RevokeSession("Password reset - security");

            var refreshTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == user.Id && !rt.IsRevoked)
                .ToListAsync();

            foreach (var rt in refreshTokens)
            {
                rt.IsRevoked = true;
                rt.Revoked = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Password reset successfully for {Email}", request.Email);
            return (true, string.Empty);
        }
    }
}