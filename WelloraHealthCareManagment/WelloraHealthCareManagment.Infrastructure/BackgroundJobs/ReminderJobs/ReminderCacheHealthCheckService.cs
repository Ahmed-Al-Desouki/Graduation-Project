// Infrastructure/BackgroundJobs/ReminderCacheHealthCheckService.cs
using Hangfire;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs
{
    public class ReminderCacheHealthCheckService : BackgroundService
    {
        private readonly IServiceProvider _sp;
        private readonly ILogger<ReminderCacheHealthCheckService> _logger;

        public ReminderCacheHealthCheckService(
            IServiceProvider sp,
            ILogger<ReminderCacheHealthCheckService> logger)
        {
            _sp = sp;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("🏥 ReminderCacheHealthCheckService started");

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(6), stoppingToken); // كل 6 ساعات

                try
                {
                    await using var scope = _sp.CreateAsyncScope();
                    var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
                    var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

                    var in30Days = DateTime.UtcNow.Date.AddDays(30);
                    var todayUtc = DateTime.UtcNow.Date;

                    var activePatientIds = await reminderRepo.GetAllActivePatientIdsAsync();

                    var emptyPatients = new List<int>();

                    // Before: checked cache for any data, re-enqueued if empty
                    // Problem: patients with no active reminders always have empty cache → infinite loop

                    // After: skip patients with no active reminders before checking cache
                    foreach (var pid in activePatientIds.Take(100))
                    {
                        var activeReminders = await reminderRepo.GetActiveByPatientIdAsync(pid);
                        if (!activeReminders.Any())
                        {
                            _logger.LogDebug("Patient {PatientId} has no active reminders — skipping health check", pid);
                            continue; // Not a cache problem, patient genuinely has nothing
                        }

                        var cache = await cacheRepo.GetByPatientAndDateRangeAsync(pid, todayUtc, in30Days);
                        if (!cache.Any())
                        {
                            emptyPatients.Add(pid);
                        }
                    }

                    if (emptyPatients.Any())
                    {
                        _logger.LogWarning(
                            "⚠️ Cache missing for {Count} patients – regenerating...",
                            emptyPatients.Count);

                        foreach (var pid in emptyPatients)
                        {
                            BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                                j => j.GenerateForPatientAsync(pid));
                        }
                    }
                    else
                    {
                        _logger.LogInformation("✅ Cache health check passed - all patients have data");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "❌ HealthCheck failed");
                }
            }
        }
    }
}