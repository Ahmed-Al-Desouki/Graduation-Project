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

        [DisableConcurrentExecution(timeoutInSeconds: 1800)]
        public async Task RunDailyGenerationAsync()
        {
            _logger.LogInformation("Daily Reminder Orchestration started");

            try
            {
                await using var scope = _serviceProvider.CreateAsyncScope();

                var reminderRepo = scope.ServiceProvider
                    .GetRequiredService<IReminderRepository>();

                var patientIds = await reminderRepo.GetAllActivePatientIdsAsync();

                foreach (var pid in patientIds)
                {
                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                        j => j.GenerateForPatientAsync(pid));
                }

                _logger.LogInformation(
                    "{Count} patients scheduled for cache generation",
                    patientIds.Count);
            }
            catch (Exception ex)
            {
                _logger.LogCritical(ex, "Daily Reminder Orchestration failed");
                throw;
            }
        }

        [DisableConcurrentExecution(timeoutInSeconds: 1800)]
        public async Task<bool> CacheHealthCheckAsync()
        {
            try
            {
                await using var scope = _serviceProvider.CreateAsyncScope();

                var cacheRepo = scope.ServiceProvider
                    .GetRequiredService<IReminderOccurrencesCacheRepository>();

                var reminderRepo = scope.ServiceProvider
                    .GetRequiredService<IReminderRepository>();

                var activePatientIds = await reminderRepo.GetAllActivePatientIdsAsync();
                var activeDoctorIds = await reminderRepo.GetAllActiveDoctorIdsAsync();

                if (!activePatientIds.Any() && !activeDoctorIds.Any())
                {
                    _logger.LogInformation("No active reminders found — cache is healthy");
                    return true;
                }

                var todayUtc = DateTime.UtcNow.Date;
                var horizonUtc = todayUtc.AddDays(30);
                var missingPatients = new List<int>();
                var missingDoctors = new List<int>();

                foreach (var patientId in activePatientIds.Take(200))
                {
                    var activeReminders = await reminderRepo.GetActiveByPatientIdAsync(patientId);
                    if (!activeReminders.Any())
                        continue;

                    var hasData = await cacheRepo.GetByPatientAndDateRangeAsync(
                        patientId,
                        todayUtc,
                        horizonUtc);

                    if (!hasData.Any())
                    {
                        missingPatients.Add(patientId);

                        BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                            j => j.GenerateForPatientAsync(patientId));

                        foreach (var prescriptionReminder in activeReminders.Where(r => r.PrescriptionItemId.HasValue))
                        {
                            BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                                j => j.GenerateForReminderAsync(prescriptionReminder.Id));
                        }
                    }
                }

                foreach (var doctorId in activeDoctorIds.Take(200))
                {
                    var activeReminders = await reminderRepo.GetActiveByDoctorIdAsync(doctorId);
                    if (!activeReminders.Any())
                        continue;

                    var hasData = await cacheRepo.GetByDoctorAndDateRangeAsync(
                        doctorId,
                        todayUtc,
                        horizonUtc);

                    if (!hasData.Any())
                    {
                        missingDoctors.Add(doctorId);
                    }
                }

                foreach (var doctorId in missingDoctors)
                {
                    BackgroundJob.Enqueue<IReminderOccurrenceGenerator>(
                        j => j.GenerateForDoctorAsync(doctorId));
                }

                var healthy = !missingPatients.Any() && !missingDoctors.Any();

                if (healthy)
                {
                    _logger.LogInformation("Cache health check passed");
                }
                else
                {
                    _logger.LogWarning(
                        "Cache health check enqueued rebuilds for {PatientCount} patients and {DoctorCount} doctors",
                        missingPatients.Count,
                        missingDoctors.Count);
                }

                return healthy;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Cache health check failed");
                return false;
            }
        }
    }
}
