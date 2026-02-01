using HealthCare_.Models.DTOs.AuthModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens
{
    public class RefreshTokenRepository : IRefreshTokenRepository
    {
        private readonly HealthCarePlusContext _context;

        public RefreshTokenRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<RefreshToken?> GetByTokenHashAsync(string tokenHash, int userId)
        {
            return await _context.RefreshTokens
                .Include(rt => rt.UserSession)
                .FirstOrDefaultAsync(rt =>
                    rt.Token == tokenHash &&
                    rt.UserId == userId &&
                    !rt.IsRevoked &&
                    !rt.IsUsed &&
                    rt.Expires > DateTime.UtcNow);
        }

        public async Task<RefreshToken?> GetByJtiAsync(string jti, int userId)
        {
            return await _context.RefreshTokens
                .FirstOrDefaultAsync(rt =>
                    rt.JwtId == jti &&
                    rt.UserId == userId);
        }

        public async Task<RefreshToken> AddAsync(RefreshToken refreshToken)
        {
            await _context.RefreshTokens.AddAsync(refreshToken);
            await _context.SaveChangesAsync();
            return refreshToken;
        }

        public async Task UpdateAsync(RefreshToken refreshToken)
        {
            _context.RefreshTokens.Update(refreshToken);
            await _context.SaveChangesAsync();
        }

        public async Task<int> GetActiveTokenCountByUserAsync(int userId)
        {
            return await _context.RefreshTokens
                .CountAsync(rt =>
                    rt.UserId == userId &&
                    !rt.IsRevoked &&
                    !rt.IsUsed &&
                    rt.Expires > DateTime.UtcNow);
        }

        public async Task RevokeOldestTokenAsync(int userId)
        {
            var oldest = await _context.RefreshTokens
                .Where(rt =>
                    rt.UserId == userId &&
                    !rt.IsRevoked &&
                    !rt.IsUsed)
                .OrderBy(rt => rt.CreatedAt)
                .FirstOrDefaultAsync();

            if (oldest != null)
            {
                oldest.IsRevoked = true;
                oldest.Revoked = DateTime.UtcNow;
                _context.RefreshTokens.Update(oldest);
                await _context.SaveChangesAsync();
            }
        }

        public async Task RevokeAllUserTokensAsync(int userId)
        {
            var activeTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in activeTokens)
            {
                token.IsRevoked = true;
                token.Revoked = DateTime.UtcNow;
            }

            if (activeTokens.Any())
            {
                _context.RefreshTokens.UpdateRange(activeTokens);
                await _context.SaveChangesAsync();
            }
        }
    }
}
