using Hangfire;

namespace HealthCare_.Services.Background.Reminder
{
    public class ReminderJobOrchestrator
    {
        private readonly ILogger<ReminderJobOrchestrator> _logger;
        private readonly IServiceProvider _serviceProvider;

        public ReminderJobOrchestrator(
            IServiceProvider serviceProvider,
            ILogger<ReminderJobOrchestrator> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        //  يُنَفّذ يوميًا الساعة 3 فجرًا
        public async Task RunDailyGenerationAsync()
        {
            _logger.LogInformation(" Daily Reminder Orchestration started");

            try
            {
                using var scope = _serviceProvider.CreateScope();
                var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();

                var patientIds = await context.ReminderV2s
                    .Where(r => r.IsActive)
                    .Select(r => r.PatientId)
                    .Distinct()
                    .ToListAsync();

                foreach (var pid in patientIds)
                {
                    BackgroundJob.Enqueue<ReminderOccurrencesGeneratorJob>(
                        j => j.GenerateForPatientAsync(pid)
                    );
                }

                _logger.LogInformation(" {Count} patients scheduled for cache generation", patientIds.Count);
            }
            catch (Exception ex)
            {
                _logger.LogCritical(ex, " Daily Reminder Orchestration failed");
                throw;
            }
        }


        //  Health Check للكاش
        public async Task<bool> CacheHealthCheckAsync()
        {
            try
            {
                await using var scope = _serviceProvider.CreateAsyncScope();
                var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
                var today = DateTime.Today;
                var nextMonth = today.AddDays(30);

                var hasData = await context.ReminderOccurrencesCache
                    .AnyAsync(x => x.DueDateTime >= today && x.DueDateTime < nextMonth);

                if (!hasData)
                    _logger.LogWarning("Cache is empty for next 30 days!");

                return hasData;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Cache health check failed");
                return false;
            }
        }
    }
}
