using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions
{
    public interface IUserSessionRepository
    {
        Task<UserSession?> GetByIdAsync(int sessionId);
        Task<UserSession> AddAsync(UserSession session);
        Task UpdateAsync(UserSession session);
        Task<List<UserSession>> GetActiveSessionsByUserAsync(int userId);
        Task<int> GetActiveSessionCountAsync(int userId);
        Task<UserSession?> GetActiveSessionByDeviceAsync(int userId, string? deviceInfo);
        // for passowrd
        Task RevokeAllUserSessionsAsync(int userId, string reason);
    }
}
