using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Infrastructure.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions
{
    public class UserSessionRepository : IUserSessionRepository
    {
        private readonly HealthCarePlusContext _context;

        public UserSessionRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<UserSession?> GetByIdAsync(int sessionId)
        {
            return await _context.UserSessions.FindAsync(sessionId);
        }

        public async Task<UserSession> AddAsync(UserSession session)
        {
            await _context.UserSessions.AddAsync(session);
            await _context.SaveChangesAsync();
            return session;
        }

        public async Task UpdateAsync(UserSession session)
        {
            _context.UserSessions.Update(session);
            await _context.SaveChangesAsync();
        }

        public async Task<List<UserSession>> GetActiveSessionsByUserAsync(int userId)
        {
            return await _context.UserSessions
                .Where(s =>
                    s.UserId == userId &&
                    s.IsActive &&
                    !s.IsRevoked &&
                    s.ExpiresAt > DateTime.UtcNow)
                .OrderBy(s => s.CreatedAt)
                .ToListAsync();
        }

        public async Task<int> GetActiveSessionCountAsync(int userId)
        {
            return await _context.UserSessions
                .CountAsync(s =>
                    s.UserId == userId &&
                    s.IsActive &&
                    !s.IsRevoked &&
                    s.ExpiresAt > DateTime.UtcNow);
        }

        public async Task<UserSession?> GetActiveSessionByDeviceAsync(int userId, string? deviceInfo)
        {
            return await _context.UserSessions
                .FirstOrDefaultAsync(s =>
                    s.UserId == userId &&
                    s.DeviceInfo == deviceInfo &&
                    s.IsActive);
        }

        public async Task RevokeAllUserSessionsAsync(int userId, string reason)
        {
            var activeSessions = await _context.UserSessions
                .Where(s => s.UserId == userId && !s.IsRevoked)
                .ToListAsync();

            foreach (var session in activeSessions)
            {
                session.IsActive = false;
                session.IsRevoked = true;
                session.RevokedAt = DateTime.UtcNow;
                session.Notes = reason;
            }

            if (activeSessions.Any())
            {
                _context.UserSessions.UpdateRange(activeSessions);
                await _context.SaveChangesAsync();
            }
        }
    }
}

