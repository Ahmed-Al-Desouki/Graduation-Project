using Hangfire;

namespace HealthCare_.Services.Background.Reminder
{
    public class ReminderCacheHealthCheckService : BackgroundService
    {
        private readonly IServiceProvider _sp;
        private readonly ILogger<ReminderCacheHealthCheckService> _logger;

        public ReminderCacheHealthCheckService(IServiceProvider sp, ILogger<ReminderCacheHealthCheckService> logger)
        {
            _sp = sp;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(6), stoppingToken); // كل 6 ساعات كويس

                try
                {
                    await using var scope = _sp.CreateAsyncScope();
                    var ctx = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

                    var in30Days = DateTime.Today.AddDays(30);

                    var emptyPatients = await ctx.ReminderV2s
                        .Where(r => r.IsActive)
                        .Select(r => r.PatientId)
                        .Distinct()
                        .Where(pid => !ctx.ReminderOccurrencesCache.Any(c =>
                            c.PatientId == pid &&
                            c.DueDateTime >= DateTime.Today &&
                            c.DueDateTime < in30Days))
                        .Take(100) // ما نعملش load كبير
                        .ToListAsync();

                    if (emptyPatients.Any())
                    {
                        _logger.LogWarning("Cache missing for {Count} patients – regenerating...", emptyPatients.Count);
                        foreach (var pid in emptyPatients)
                        {
                            BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(j => j.GenerateForPatientAsync(pid));
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "HealthCheck failed");
                }
            }
        }
    }

}
