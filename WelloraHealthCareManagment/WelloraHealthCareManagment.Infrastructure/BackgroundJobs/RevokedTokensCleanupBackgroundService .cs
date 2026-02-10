// Infrastructure/BackgroundJobs/RevokedTokensCleanupBackgroundService.cs
using HealthCare.Application.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs
{
    public class RevokedTokensCleanupBackgroundService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<RevokedTokensCleanupBackgroundService> _logger;

        public RevokedTokensCleanupBackgroundService(
            IServiceScopeFactory scopeFactory,
            ILogger<RevokedTokensCleanupBackgroundService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("🧹 RevokedTokensCleanupBackgroundService started");

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using var scope = _scopeFactory.CreateScope();
                    var cleanupService = scope.ServiceProvider
                        .GetRequiredService<IRevokedTokenCleanupService>();

                    await cleanupService.CleanupExpiredTokensAsync(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "❌ Error in RevokedTokensCleanupBackgroundService");
                }

                // انتظر ساعة قبل التشغيل مرة أخرى
                await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            }

            _logger.LogInformation("🛑 RevokedTokensCleanupBackgroundService stopped");
        }
    }
}