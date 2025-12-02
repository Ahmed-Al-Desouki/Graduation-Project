// Services/EmailService.cs
using MailKit.Net.Smtp;
using MimeKit;

namespace HealthCare_.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService>? _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService>? logger = null)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            var emailSettings = _configuration.GetSection("EmailSettings");

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(
                emailSettings["SenderName"],
                emailSettings["SenderEmail"]
            ));
            message.To.Add(MailboxAddress.Parse(email));
            message.Subject = subject;

            message.Body = new TextPart("html")
            {
                Text = htmlMessage
            };

            using var client = new SmtpClient();
            try
            {
                await client.ConnectAsync(
                    emailSettings["SmtpServer"],
                    int.Parse(emailSettings["SmtpPort"] ?? "587"),
                    MailKit.Security.SecureSocketOptions.StartTls
                );

                await client.AuthenticateAsync(
                    emailSettings["Username"],
                    emailSettings["Password"]
                );

                await client.SendAsync(message);
                _logger?.LogInformation("Email sent successfully to {Email}", email);
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Failed to send email to {Email}", email);
                throw;
            }
            finally
            {
                await client.DisconnectAsync(true);
            }
        }
    }
}