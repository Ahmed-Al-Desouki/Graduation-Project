using HealthCare_.Models.DTOs.Email;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication
{
    public class OtpRepository : IOtpRepository
    {
        private readonly HealthCarePlusContext _context;

        public OtpRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<EmailOTP> CreateOtpAsync(int userId, string code, DateTime expiresAt)
        {
            var otp = new EmailOTP
            {
                UserId = userId,
                Code = code,
                ExpiresAt = expiresAt,
                IsUsed = false,
                CreatedAt = DateTime.UtcNow
            };

            await _context.EmailOtps.AddAsync(otp);
            await _context.SaveChangesAsync();

            return otp;
        }

        public async Task<EmailOTP?> GetValidOtpAsync(int userId, string code)
        {
            return await _context.EmailOtps
                .FirstOrDefaultAsync(o =>
                    o.UserId == userId &&
                    o.Code == code &&
                    !o.IsUsed &&
                    o.ExpiresAt > DateTime.UtcNow);
        }

        public async Task MarkOtpAsUsedAsync(EmailOTP otp)
        {
            otp.IsUsed = true;
            _context.EmailOtps.Update(otp);
            await _context.SaveChangesAsync();
        }

        public async Task InvalidateAllUserOtpsAsync(int userId)
        {
            var activeOtps = await _context.EmailOtps
                .Where(o => o.UserId == userId && !o.IsUsed && o.ExpiresAt > DateTime.UtcNow)
                .ToListAsync();

            foreach (var otp in activeOtps)
            {
                otp.IsUsed = true;
            }

            if (activeOtps.Any())
            {
                _context.EmailOtps.UpdateRange(activeOtps);
                await _context.SaveChangesAsync();
            }
        }

        public async Task CleanupExpiredOtpsAsync()
        {
            var expired = await _context.EmailOtps
                .Where(o => o.ExpiresAt < DateTime.UtcNow)
                .ToListAsync();

            _context.EmailOtps.RemoveRange(expired);
            await _context.SaveChangesAsync();
        }
    }
}

