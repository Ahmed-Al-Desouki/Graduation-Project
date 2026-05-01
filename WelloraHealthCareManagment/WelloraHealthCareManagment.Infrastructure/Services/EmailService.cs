using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using System.Net;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly IUserRepository _userRepository;
        private readonly IAppLocalizationService _localizationService;
        private readonly ILogger<EmailService> _logger;
        private readonly string _smtpServer;
        private readonly int _smtpPort;
        private readonly string _senderName;
        private readonly string _senderEmail;
        private readonly string _username;
        private readonly string _password;

        public EmailService(
            IConfiguration configuration,
            IUserRepository userRepository,
            IAppLocalizationService localizationService,
            ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _userRepository = userRepository;
            _localizationService = localizationService;
            _logger = logger;

            // Load and validate email settings
            var emailSettings = configuration.GetSection("EmailSettings");

            _smtpServer = emailSettings["SmtpServer"]
                ?? throw new InvalidOperationException("Missing EmailSettings:SmtpServer");
            _senderName = emailSettings["SenderName"]
                ?? throw new InvalidOperationException("Missing EmailSettings:SenderName");
            _senderEmail = emailSettings["SenderEmail"]
                ?? throw new InvalidOperationException("Missing EmailSettings:SenderEmail");
            _username = emailSettings["Username"]
                ?? throw new InvalidOperationException("Missing EmailSettings:Username");
            _password = emailSettings["Password"]
                ?? throw new InvalidOperationException("Missing EmailSettings:Password");

            if (!int.TryParse(emailSettings["SmtpPort"], out _smtpPort))
                _smtpPort = 587; // Default SMTP port
        }

        public async Task<bool> SendEmailAsync(string toEmail, string subject, string htmlMessage)
        {
            if (string.IsNullOrWhiteSpace(toEmail))
            {
                _logger.LogWarning("Attempted to send email to empty address");
                return false;
            }

            try
            {
                var message = new MimeMessage();
                message.From.Add(new MailboxAddress(_senderName, _senderEmail));
                message.To.Add(MailboxAddress.Parse(toEmail));
                message.Subject = subject;
                message.Body = new TextPart("html") { Text = htmlMessage };

                using var client = new SmtpClient();

                // Connect with retry logic
                await ConnectWithRetryAsync(client);

                // Authenticate
                await client.AuthenticateAsync(_username, _password);

                // Send
                await client.SendAsync(message);

                _logger.LogInformation("Email sent successfully to {Email} with subject: {Subject}",
                    toEmail, subject);

                await client.DisconnectAsync(true);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email to {Email}", toEmail);
                return false;
            }
        }

        public async Task<bool> SendOtpEmailAsync(string toEmail, string otpCode, string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.OtpSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.OtpHeadline", language: language),
                _localizationService.Localize("Email.OtpBody", language: language),
                $"<div style='font-size:32px;font-weight:700;letter-spacing:6px;color:#0f766e;background:#f0fdfa;padding:16px 24px;border-radius:14px;display:inline-block'>{WebUtility.HtmlEncode(otpCode)}</div><p style='margin-top:18px'>{_localizationService.Localize("Email.OtpExpires", language: language)}</p><p style='color:#b45309;font-weight:600'>{_localizationService.Localize("Email.OtpWarning", language: language)}</p>",
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendPasswordResetEmailAsync(
            string toEmail,
            string resetLink,
            string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.ResetSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.ResetHeadline", language: language),
                _localizationService.Localize("Email.ResetBody", language: language),
                BuildPrimaryButton(resetLink, _localizationService.Localize("Email.ResetAction", language: language)),
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendWelcomeEmailAsync(string toEmail, string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.WelcomeSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.WelcomeHeadline", language: language),
                _localizationService.Localize("Email.WelcomeBody", language: language),
                string.Empty,
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendEmailVerificationAsync(string toEmail, string verificationToken, string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.VerifySubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.VerifyHeadline", language: language),
                _localizationService.Localize("Email.VerifyBody", language: language),
                $"<div style='font-size:16px;font-weight:600;background:#f8fafc;padding:14px 18px;border-radius:12px;word-break:break-all'>{WebUtility.HtmlEncode(verificationToken)}</div>",
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendDoctorVerificationApprovedEmailAsync(string toEmail, string userName, string? adminNotes = null)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.DoctorApprovedSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.DoctorApprovedHeadline", language: language),
                _localizationService.Localize("Email.DoctorApprovedBody", language: language),
                string.IsNullOrWhiteSpace(adminNotes)
                    ? string.Empty
                    : BuildInfoBlock(_localizationService.Localize("Email.AdminNotes", language: language), adminNotes),
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendDoctorVerificationRejectedEmailAsync(string toEmail, string userName, string rejectionReason, string? adminNotes = null)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.DoctorRejectedSubject", language: language);
            var extra = BuildInfoBlock(_localizationService.Localize("Email.RejectionReason", language: language), rejectionReason);
            if (!string.IsNullOrWhiteSpace(adminNotes))
            {
                extra += BuildInfoBlock(_localizationService.Localize("Email.AdminNotes", language: language), adminNotes);
            }

            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.DoctorRejectedHeadline", language: language),
                _localizationService.Localize("Email.DoctorRejectedBody", language: language),
                extra,
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendAccountBlockedEmailAsync(string toEmail, string userName, string reason)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.BlockedSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.BlockedHeadline", language: language),
                _localizationService.Localize("Email.BlockedBody", language: language),
                BuildInfoBlock(_localizationService.Localize("Email.RejectionReason", language: language), reason),
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendAccountUnblockedEmailAsync(string toEmail, string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.UnblockedSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.UnblockedHeadline", language: language),
                _localizationService.Localize("Email.UnblockedBody", language: language),
                string.Empty,
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendAccountSuspendedEmailAsync(string toEmail, string userName, DateTime suspensionEnd, string reason)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.SuspendedSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.SuspendedHeadline", language: language),
                _localizationService.Localize("Email.SuspendedBody", language: language),
                BuildInfoBlock(_localizationService.Localize("Email.SuspensionUntil", language: language), _localizationService.FormatDateTime(suspensionEnd, language)) +
                BuildInfoBlock(_localizationService.Localize("Email.RejectionReason", language: language), reason),
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendAccountUnsuspendedEmailAsync(string toEmail, string userName)
        {
            var language = await ResolveLanguageAsync(toEmail);
            var subject = _localizationService.Localize("Email.UnsuspendedSubject", language: language);
            var htmlMessage = BuildActionEmail(
                language,
                subject,
                _localizationService.Localize("Email.UnsuspendedHeadline", language: language),
                _localizationService.Localize("Email.UnsuspendedBody", language: language),
                string.Empty,
                userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        #region Private Helper Methods

        private async Task ConnectWithRetryAsync(SmtpClient client, int maxRetries = 3)
        {
            for (int attempt = 1; attempt <= maxRetries; attempt++)
            {
                try
                {
                    await client.ConnectAsync(
                        _smtpServer,
                        _smtpPort,
                        MailKit.Security.SecureSocketOptions.StartTls
                    );
                    _logger.LogDebug("SMTP connection established on attempt {Attempt}", attempt);
                    return;
                }
                catch (Exception ex) when (attempt < maxRetries)
                {
                    _logger.LogWarning(ex,
                        "SMTP connection failed on attempt {Attempt}/{MaxRetries}. Retrying...",
                        attempt, maxRetries);
                    await Task.Delay(TimeSpan.FromSeconds(2 * attempt)); // Exponential backoff
                }
            }

            // If all retries failed, throw on last attempt
            await client.ConnectAsync(_smtpServer, _smtpPort, MailKit.Security.SecureSocketOptions.StartTls);
        }

        private async Task<string> ResolveLanguageAsync(string toEmail)
        {
            var language = await _userRepository.GetPreferredLanguageByEmailAsync(toEmail);
            return _localizationService.NormalizeLanguage(language);
        }

        private string BuildActionEmail(
            string language,
            string subject,
            string headline,
            string body,
            string contentHtml,
            string userName)
        {
            var isArabic = _localizationService.IsRightToLeft(language);
            var direction = isArabic ? "rtl" : "ltr";
            var align = isArabic ? "right" : "left";
            var greeting = _localizationService.Localize(
                "Email.Greeting",
                new Dictionary<string, string> { ["userName"] = WebUtility.HtmlEncode(userName) },
                language);

            return $@"
<!DOCTYPE html>
<html lang='{language}' dir='{direction}'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{WebUtility.HtmlEncode(subject)}</title>
</head>
<body style='margin:0;padding:24px;background:#f3f7fb;font-family:Segoe UI,Arial,sans-serif;color:#0f172a'>
    <div style='max-width:620px;margin:0 auto;background:#ffffff;border-radius:24px;overflow:hidden;box-shadow:0 18px 50px rgba(15,23,42,.08)'>
        <div style='background:linear-gradient(135deg,#0f766e,#2563eb);padding:32px 28px;color:#fff;text-align:{align}'>
            <div style='font-size:14px;opacity:.9'>{WebUtility.HtmlEncode(_localizationService.Localize("Email.Brand", language: language))}</div>
            <h1 style='margin:10px 0 0;font-size:28px'>{WebUtility.HtmlEncode(headline)}</h1>
        </div>
        <div style='padding:32px 28px;text-align:{align};line-height:1.7'>
            <p style='margin-top:0;font-size:16px;font-weight:600'>{greeting}</p>
            <p style='font-size:15px;color:#334155'>{WebUtility.HtmlEncode(body)}</p>
            <div style='margin:24px 0'>{contentHtml}</div>
        </div>
        <div style='padding:20px 28px;background:#f8fafc;color:#64748b;font-size:13px;text-align:{align}'>
            {WebUtility.HtmlEncode(_localizationService.Localize("Email.Footer", language: language))}
        </div>
    </div>
</body>
</html>";
        }

        private static string BuildPrimaryButton(string href, string text)
            => $"<a href='{WebUtility.HtmlEncode(href)}' style='display:inline-block;background:#0f766e;color:#fff;text-decoration:none;padding:14px 22px;border-radius:12px;font-weight:600'>{WebUtility.HtmlEncode(text)}</a>";

        private static string BuildInfoBlock(string label, string value)
            => $"<div style='margin-top:14px;padding:16px;border-radius:14px;background:#f8fafc'><div style='font-size:12px;color:#64748b;margin-bottom:6px'>{WebUtility.HtmlEncode(label)}</div><div style='font-size:15px;color:#0f172a'>{WebUtility.HtmlEncode(value)}</div></div>";


        #endregion

        #region Email Templates

        private string GenerateOtpEmailTemplate(string otpCode, string userName)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 50px auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }}
        .header {{ text-align: center; padding-bottom: 20px; border-bottom: 2px solid #4CAF50; }}
        .header h1 {{ color: #4CAF50; margin: 0; }}
        .content {{ padding: 30px 0; text-align: center; }}
        .otp-code {{ font-size: 32px; font-weight: bold; color: #4CAF50; background-color: #f0f8f0; padding: 15px 30px; border-radius: 8px; display: inline-block; letter-spacing: 5px; margin: 20px 0; }}
        .footer {{ text-align: center; padding-top: 20px; border-top: 1px solid #ddd; color: #888; font-size: 12px; }}
        .warning {{ color: #ff5722; font-size: 14px; margin-top: 20px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🏥 HealthCare App</h1>
        </div>
        <div class='content'>
            <h2>Hello, {userName}!</h2>
            <p>You requested a One-Time Password (OTP) to verify your identity.</p>
            <p>Your OTP code is:</p>
            <div class='otp-code'>{otpCode}</div>
            <p>This code will expire in <strong>15 minutes</strong>.</p>
            <p class='warning'>⚠️ Never share this code with anyone.</p>
        </div>
        <div class='footer'>
            <p>If you didn't request this code, please ignore this email.</p>
            <p>&copy; 2025 HealthCare App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GeneratePasswordResetEmailTemplate(string resetLink, string userName)
        {
            return $@"
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
            margin: 10px 0;
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
        .link-text {{
            font-size: 12px;
            color: #888;
            word-break: break-all;
            margin-top: 15px;
            padding: 10px;
            background: #f5f5f5;
            border-radius: 8px;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🏥 HealthCare</h1>
            <p>Secure • Modern • Trusted</p>
        </div>
        <div class='content'>
            <h2>Reset Your Password</h2>
            <p>Hello <strong>{userName}</strong>,</p>
            <p>We received a request to reset your password. Click the button below to proceed.</p>
            <a href='{resetLink}' class='btn'>Reset Password</a>
            <p class='expires'>⏰ This link expires in <strong>1 hour</strong> for your security.</p>
            <p style='font-size: 13px; color: #888;'>If you didn't request this, no action is needed—your account remains secure.</p>
            <div class='link-text'>
                <strong>Or copy this link:</strong><br>
                {resetLink}
            </div>
        </div>
        <div class='footer'>
            <p>© 2025 <strong>HealthCare App</strong>. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GenerateWelcomeEmailTemplate(string userName)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 50px auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }}
        .header {{ text-align: center; padding-bottom: 20px; border-bottom: 2px solid #4CAF50; }}
        .header h1 {{ color: #4CAF50; margin: 0; }}
        .content {{ padding: 30px 0; }}
        .footer {{ text-align: center; padding-top: 20px; border-top: 1px solid #ddd; color: #888; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🎉 Welcome to HealthCare App!</h1>
        </div>
        <div class='content'>
            <h2>Hello, {userName}!</h2>
            <p>Thank you for registering with HealthCare App.</p>
            <p>We're excited to have you on board!</p>
            <p>You can now:</p>
            <ul>
                <li>Track your medical history</li>
                <li>Set medication reminders</li>
                <li>Book appointments with doctors</li>
                <li>And much more!</li>
            </ul>
            <p>If you have any questions, feel free to contact our support team.</p>
        </div>
        <div class='footer'>
            <p>&copy; 2025 HealthCare App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GenerateEmailVerificationTemplate(string verificationToken, string userName)
        {
            var verificationUrl = $"https://yourdomain.com/verify-email?token={verificationToken}";

            return $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; }}
        .container {{ max-width: 600px; margin: 50px auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }}
        .header {{ text-align: center; padding-bottom: 20px; border-bottom: 2px solid #FF9800; }}
        .header h1 {{ color: #FF9800; margin: 0; }}
        .content {{ padding: 30px 0; }}
        .btn {{ display: inline-block; padding: 15px 30px; background-color: #FF9800; color: white; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }}
        .footer {{ text-align: center; padding-top: 20px; border-top: 1px solid #ddd; color: #888; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>✉️ Verify Your Email</h1>
        </div>
        <div class='content'>
            <h2>Hello, {userName}!</h2>
            <p>Please verify your email address to complete your registration.</p>
            <a href='{verificationUrl}' class='btn'>Verify Email</a>
            <p>Or copy this link: {verificationUrl}</p>
        </div>
        <div class='footer'>
            <p>&copy; 2025 HealthCare App. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
        }

        private string GenerateDoctorVerificationApprovedTemplate(string userName, string? adminNotes)
        {
            var body = $@"
                <p>We are pleased to let you know that your doctor verification request has been <strong>approved</strong>.</p>
                <p>Your professional account is now verified, and you can continue using all doctor features available on the platform.</p>
                {BuildOptionalCallout("Admin notes", adminNotes)}
                <p>If you face any issue accessing your doctor tools, please contact our support team.</p>";

            return BuildStatusEmailTemplate(
                "Verification Approved",
                "Your doctor account is now verified.",
                userName,
                body,
                "#0f9d58",
                "Wellora Team");
        }

        private string GenerateDoctorVerificationRejectedTemplate(string userName, string rejectionReason, string? adminNotes)
        {
            var body = $@"
                <p>We reviewed your doctor verification request, but we could not approve it at this time.</p>
                {BuildHighlightedReason("Reason for rejection", rejectionReason, "#c62828", "#fff5f5")}
                {BuildOptionalCallout("Admin notes", adminNotes)}
                <p>Please update the required details or upload corrected documents, then submit your request again for review.</p>";

            return BuildStatusEmailTemplate(
                "Verification Rejected",
                "Please review the feedback and resubmit your documents.",
                userName,
                body,
                "#d93025",
                "Wellora Team");
        }

        private string GenerateAccountBlockedTemplate(string userName, string reason)
        {
            var body = $@"
                <p>Your account has been <strong>blocked</strong> by the administration team.</p>
                {BuildHighlightedReason("Reason", reason, "#c62828", "#fff5f5")}
                <p>If you believe this was done by mistake or you need more information, please contact support.</p>";

            return BuildStatusEmailTemplate(
                "Account Blocked",
                "Your access is currently restricted.",
                userName,
                body,
                "#b3261e",
                "Wellora Support");
        }

        private string GenerateAccountUnblockedTemplate(string userName)
        {
            var body = @"
                <p>Your account has been <strong>unblocked</strong>, and your access to the platform has been restored.</p>
                <p>You can now sign in again and continue using your account normally.</p>";

            return BuildStatusEmailTemplate(
                "Account Restored",
                "Your access is active again.",
                userName,
                body,
                "#0f9d58",
                "Wellora Support");
        }

        private string GenerateAccountSuspendedTemplate(string userName, DateTime suspensionEnd, string reason)
        {
            var body = $@"
                <p>Your account has been <strong>temporarily suspended</strong>.</p>
                {BuildHighlightedReason("Reason", reason, "#8d6e00", "#fff9e6")}
                <div style='margin: 18px 0; padding: 16px 18px; border-radius: 14px; background: #f7f9fc; border: 1px solid #d9e2f2;'>
                    <strong>Suspension end date:</strong> {WebUtility.HtmlEncode(suspensionEnd.ToString("yyyy-MM-dd HH:mm 'UTC'"))}
                </div>
                <p>Your access will be restored once the suspension period ends, unless you receive another update from the administration team.</p>";

            return BuildStatusEmailTemplate(
                "Account Suspended",
                "Your access has been paused temporarily.",
                userName,
                body,
                "#f9ab00",
                "Wellora Support");
        }

        private string GenerateAccountUnsuspendedTemplate(string userName)
        {
            var body = @"
                <p>Your account suspension has ended, and your access has now been restored.</p>
                <p>You can return to the platform and continue using your account normally.</p>";

            return BuildStatusEmailTemplate(
                "Suspension Ended",
                "Your account is active again.",
                userName,
                body,
                "#1a73e8",
                "Wellora Support");
        }

        private string BuildStatusEmailTemplate(
            string title,
            string subtitle,
            string userName,
            string bodyHtml,
            string accentColor,
            string footerSignature)
        {
            var encodedTitle = WebUtility.HtmlEncode(title);
            var encodedSubtitle = WebUtility.HtmlEncode(subtitle);
            var encodedUserName = WebUtility.HtmlEncode(userName);
            var encodedFooterSignature = WebUtility.HtmlEncode(footerSignature);

            return $@"
<!DOCTYPE html>
<html lang='en' dir='ltr'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>{encodedTitle}</title>
    <style>
        body {{
            margin: 0;
            padding: 24px;
            background: #eef3f8;
            font-family: 'Segoe UI', Arial, sans-serif;
            color: #1f2937;
        }}
        .container {{
            max-width: 620px;
            margin: 0 auto;
            background: #ffffff;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 18px 50px rgba(15, 23, 42, 0.08);
        }}
        .header {{
            padding: 36px 32px;
            background: linear-gradient(135deg, {accentColor} 0%, #16324f 100%);
            color: #ffffff;
        }}
        .header h1 {{
            margin: 0 0 8px;
            font-size: 28px;
            font-weight: 700;
        }}
        .header p {{
            margin: 0;
            font-size: 15px;
            opacity: 0.92;
        }}
        .content {{
            padding: 34px 32px 28px;
            line-height: 1.7;
            font-size: 15px;
        }}
        .content h2 {{
            margin-top: 0;
            margin-bottom: 14px;
            color: #111827;
            font-size: 22px;
        }}
        .content p {{
            margin: 0 0 16px;
        }}
        .footer {{
            padding: 22px 32px 30px;
            color: #6b7280;
            font-size: 13px;
            border-top: 1px solid #e5e7eb;
            background: #fafbfd;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>{encodedTitle}</h1>
            <p>{encodedSubtitle}</p>
        </div>
        <div class='content'>
            <h2>Hello, {encodedUserName}</h2>
            {bodyHtml}
        </div>
        <div class='footer'>
            <p>Thank you,<br /><strong>{encodedFooterSignature}</strong></p>
            <p>This is an automated email from Wellora HealthCare Management.</p>
        </div>
    </div>
</body>
</html>";
        }

        private static string BuildOptionalCallout(string title, string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            return $@"
                <div style='margin: 18px 0; padding: 16px 18px; border-radius: 14px; background: #f7f9fc; border: 1px solid #d9e2f2;'>
                    <strong>{WebUtility.HtmlEncode(title)}:</strong><br />
                    {WebUtility.HtmlEncode(value)}
                </div>";
        }

        private static string BuildHighlightedReason(string title, string value, string textColor, string backgroundColor)
        {
            return $@"
                <div style='margin: 18px 0; padding: 16px 18px; border-radius: 14px; background: {backgroundColor}; border: 1px solid {textColor}; color: {textColor};'>
                    <strong>{WebUtility.HtmlEncode(title)}:</strong><br />
                    {WebUtility.HtmlEncode(value)}
                </div>";
        }

        #endregion
    }
}
