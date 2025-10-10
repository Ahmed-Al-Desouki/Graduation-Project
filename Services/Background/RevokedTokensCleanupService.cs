namespace HealthCare_.Services.BackGround
{
    public class RevokedTokensCleanupService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<RevokedTokensCleanupService> _logger;

        public RevokedTokensCleanupService(IServiceScopeFactory scopeFactory, ILogger<RevokedTokensCleanupService> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                using var scope = _scopeFactory.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

                var expiredTokens = await context.RevokedTokens
                    .Where(t => t.Expires <= DateTime.UtcNow)
                    .ToListAsync(stoppingToken);

                if (expiredTokens.Any())
                {
                    context.RevokedTokens.RemoveRange(expiredTokens);
                    await context.SaveChangesAsync(stoppingToken);
                    _logger.LogInformation($"Cleaned {expiredTokens.Count} expired revoked tokens.");
                }

                await Task.Delay(TimeSpan.FromHours(1), stoppingToken); // كل ساعة
            }
        }
    }

}
