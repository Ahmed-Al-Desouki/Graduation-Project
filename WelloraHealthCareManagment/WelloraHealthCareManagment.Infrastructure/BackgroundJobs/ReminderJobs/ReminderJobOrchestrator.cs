// Infrastructure/BackgroundJobs/ReminderJobOrchestrator.cs
using Hangfire;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs
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

        // يُنَفّذ يوميًا الساعة 3 فجرًا
        public async Task RunDailyGenerationAsync()
        {
            _logger.LogInformation("🌅 Daily Reminder Orchestration started");
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();

                var patientIds = await reminderRepo.GetAllActivePatientIdsAsync();

                foreach (var pid in patientIds)
                {
                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                        j => j.GenerateForPatientAsync(pid)
                    );
                }

                _logger.LogInformation("✅ {Count} patients scheduled for cache generation", patientIds.Count);
            }
            catch (Exception ex)
            {
                _logger.LogCritical(ex, "❌ Daily Reminder Orchestration failed");
                throw;
            }
        }

        // Health Check للكاش
        public async Task<bool> CacheHealthCheckAsync()
        {
            try
            {
                await using var scope = _serviceProvider.CreateAsyncScope();
                var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

                var today = DateTime.Today;
                var nextMonth = today.AddDays(30);

                // Check if there's any data for active patients
                using var innerScope = _serviceProvider.CreateScope();
                var reminderRepo = innerScope.ServiceProvider.GetRequiredService<IReminderRepository>();
                var activePatientIds = await reminderRepo.GetAllActivePatientIdsAsync();

                if (!activePatientIds.Any())
                {
                    _logger.LogInformation("No active patients - cache is healthy");
                    return true;
                }

                // Sample check on first patient
                var samplePatientId = activePatientIds.First();
                var todayUtc = DateTime.UtcNow.Date;
                var nextMonthUtc = todayUtc.AddDays(30);

                var hasData = await cacheRepo.GetByPatientAndDateRangeAsync(
                    samplePatientId, todayUtc, nextMonthUtc);

                if (!hasData.Any())
                {
                    _logger.LogWarning("⚠️ Cache is empty for sample patient {PatientId}!", samplePatientId);
                    return false;
                }

                _logger.LogInformation("✅ Cache health check passed");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Cache health check failed");
                return false;
            }
        }
    }
}