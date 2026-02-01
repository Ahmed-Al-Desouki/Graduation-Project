using HealthCare_.Models.DTOs.Email;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IOtpRepository
    {
        Task<EmailOTP> CreateOtpAsync(int userId, string code, DateTime expiresAt);
        Task<EmailOTP?> GetValidOtpAsync(int userId, string code);
        Task MarkOtpAsUsedAsync(EmailOTP otp);
        Task InvalidateAllUserOtpsAsync(int userId);
        Task CleanupExpiredOtpsAsync();
    }
}
