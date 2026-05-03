// Infrastructure/Services/RevokedTokenCleanupService.cs

using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class RevokedTokenCleanupService : IRevokedTokenCleanupService
    {
        private readonly IRevokedTokenRepository _revokedTokenRepository;
        private readonly ILogger<RevokedTokenCleanupService> _logger;

        public RevokedTokenCleanupService(
            IRevokedTokenRepository revokedTokenRepository,
            ILogger<RevokedTokenCleanupService> logger)
        {
            _revokedTokenRepository = revokedTokenRepository;
            _logger = logger;
        }

        public async Task CleanupExpiredTokensAsync(CancellationToken cancellationToken = default)
        {
            try
            {
                _logger.LogInformation("🧹 Starting expired revoked tokens cleanup...");

                var expiredTokens = await _revokedTokenRepository
                    .GetExpiredTokensAsync(cancellationToken);

                if (expiredTokens.Any())
                {
                    await _revokedTokenRepository.DeleteRangeAsync(
                        expiredTokens,
                        cancellationToken);

                    _logger.LogInformation(
                        "✅ Cleaned {Count} expired revoked tokens.",
                        expiredTokens.Count);
                }
                else
                {
                    _logger.LogInformation("✅ No expired tokens to clean.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error during revoked tokens cleanup");
                throw;
            }
        }
    }
}