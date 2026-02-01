using MailKit.Net.Smtp;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using WelloraHealthCareManagment.Application.Interfaces.Email;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;
        private readonly string _smtpServer;
        private readonly int _smtpPort;
        private readonly string _senderName;
        private readonly string _senderEmail;
        private readonly string _username;
        private readonly string _password;

        public EmailService(
            IConfiguration configuration,
            ILogger<EmailService> logger)
        {
            _configuration = configuration;
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
            var subject = "Your OTP Code - HealthCare App";
            var htmlMessage = GenerateOtpEmailTemplate(otpCode, userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendPasswordResetEmailAsync(
            string toEmail,
            string resetLink,
            string userName)
        {
            var subject = "Reset Your HealthCare Password";
            var htmlMessage = GeneratePasswordResetEmailTemplate(resetLink, userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendWelcomeEmailAsync(string toEmail, string userName)
        {
            var subject = "Welcome to HealthCare App!";
            var htmlMessage = GenerateWelcomeEmailTemplate(userName);
            return await SendEmailAsync(toEmail, subject, htmlMessage);
        }

        public async Task<bool> SendEmailVerificationAsync(string toEmail, string verificationToken, string userName)
        {
            var subject = "Verify Your Email - HealthCare App";
            var htmlMessage = GenerateEmailVerificationTemplate(verificationToken, userName);
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

        #endregion
    }
}