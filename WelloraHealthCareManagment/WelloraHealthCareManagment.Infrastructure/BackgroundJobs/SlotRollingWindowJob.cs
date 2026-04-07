using Hangfire;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs
{
    public class SlotRollingWindowJob
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<SlotRollingWindowJob> _logger;

        private const int ROLLING_WINDOW_MONTHS = 2;

        // IMPORTANT: Inject IServiceProvider only — NOT the scoped services directly.
        // Hangfire jobs share a single instance across executions; injecting scoped
        // services directly causes stale DbContext and threading issues.
        // Each execution must create its own scope.
        public SlotRollingWindowJob(
            IServiceProvider serviceProvider,
            ILogger<SlotRollingWindowJob> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        [DisableConcurrentExecution(timeoutInSeconds: 300)]
        [AutomaticRetry(Attempts = 2)]
        public async Task ExecuteAsync(CancellationToken ct = default)
        {
            _logger.LogInformation(
                "SlotRollingWindowJob started at {Time}", DateTime.UtcNow);

            // كل execution بياخد scope جديد — بيضمن fresh DbContext
            await using var scope = _serviceProvider.CreateAsyncScope();

            var configRepository = scope.ServiceProvider
                .GetRequiredService<IDoctorSlotConfigRepository>();

            var timeSlotRepository = scope.ServiceProvider
                .GetRequiredService<ITimeSlotRepository>();

            var slotGenerationService = scope.ServiceProvider
                .GetRequiredService<ISlotGenerationService>();

            var doctorIds = await configRepository
                .GetDoctorsWithActiveConfigsAsync(ct);

            _logger.LogInformation(
                "RollingWindowJob: processing {Count} doctors", doctorIds.Count);

            var targetEndDate = DateTime.UtcNow.Date.AddMonths(ROLLING_WINDOW_MONTHS);

            foreach (var doctorId in doctorIds)
            {
                try
                {
                    var lastSlotDate = await timeSlotRepository
                        .GetLastSlotDateAsync(doctorId, ct);

                    if (lastSlotDate?.Date >= targetEndDate)
                    {
                        _logger.LogDebug(
                            "Doctor {DoctorId} already covered until {Date}",
                            doctorId, lastSlotDate.Value.Date);
                        continue;
                    }

                    var startDate = lastSlotDate.HasValue
                        ? lastSlotDate.Value.Date.AddDays(1)
                        : DateTime.UtcNow.Date;

                    var result = await slotGenerationService.GenerateAsync(
                        doctorId,
                        new GenerateSlotsByConfigRequest
                        {
                            StartDate = startDate,
                            EndDate = targetEndDate,
                            RegenerateExisting = false,
                            BatchSize = 1000
                        },
                        ct);

                    _logger.LogInformation(
                        "Doctor {DoctorId}: added {Count} slots, skipped {Skipped}",
                        doctorId, result.SlotsGenerated, result.SlotsSkipped);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex,
                        "RollingWindowJob failed for doctor {DoctorId}", doctorId);
                }
            }

            _logger.LogInformation(
                "SlotRollingWindowJob completed at {Time}", DateTime.UtcNow);
        }
    }
}