using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class UserActivityService : IUserActivityService
    {
        private readonly IUserSessionRepository _userSessionRepository;

        public UserActivityService(IUserSessionRepository userSessionRepository)
        {
            _userSessionRepository = userSessionRepository;
        }

        public async Task UpdateLastActivityAsync(int userId, CancellationToken cancellationToken = default)
        {
            var sessions = await _userSessionRepository.GetActiveSessionsByUserAsync(userId);
            var session = sessions.FirstOrDefault();

            if (session == null)
            {
                return;
            }

            session.LastActivity = DateTime.UtcNow;
            await _userSessionRepository.UpdateAsync(session);
        }
    }
}
