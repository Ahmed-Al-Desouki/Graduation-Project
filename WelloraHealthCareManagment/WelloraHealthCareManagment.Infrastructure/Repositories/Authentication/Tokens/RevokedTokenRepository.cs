using HealthCare_.Models.DTOs.AuthModels;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Repositories;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens
{
    public class RevokedTokenRepository : IRevokedTokenRepository
    {
        private readonly HealthCarePlusContext _context;

        public RevokedTokenRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<bool> IsTokenRevokedAsync(string jti)
        {
            return await _context.RevokedTokens
                .AnyAsync(rt => rt.Jti == jti && rt.Expires > DateTime.UtcNow);
        }

        public async Task AddAsync(RevokedToken revokedToken)
        {
            var exists = await _context.RevokedTokens
                .AnyAsync(rt => rt.Jti == revokedToken.Jti);

            if (!exists)
            {
                await _context.RevokedTokens.AddAsync(revokedToken);
                await _context.SaveChangesAsync();
            }
        }

        public async Task CleanupExpiredTokensAsync()
        {
            var expired = await _context.RevokedTokens
                .Where(rt => rt.Expires < DateTime.UtcNow)
                .ToListAsync();

            _context.RevokedTokens.RemoveRange(expired);
            await _context.SaveChangesAsync();
        }

        public async Task<List<RevokedToken>> GetExpiredTokensAsync(
            CancellationToken cancellationToken = default)
        {
            return await _context.RevokedTokens
                .Where(t => t.Expires <= DateTime.UtcNow)
                .ToListAsync(cancellationToken);
        }

        public async Task DeleteRangeAsync(
            List<RevokedToken> tokens,
            CancellationToken cancellationToken = default)
        {
            _context.RevokedTokens.RemoveRange(tokens);
            await _context.SaveChangesAsync(cancellationToken);
        }

    }
}

