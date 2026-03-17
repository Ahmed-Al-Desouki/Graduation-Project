using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.SlotConfig;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;

namespace WelloraHealthCareManagment.Infrastructure.BackgroundJobs
{
    public class SlotRollingWindowJob : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<SlotRollingWindowJob> _logger;

        private const int ROLLING_WINDOW_MONTHS = 2;

        public SlotRollingWindowJob(
            IServiceScopeFactory scopeFactory,
            ILogger<SlotRollingWindowJob> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation(
                "SlotRollingWindowJob started — will run every 24 hours at {Time}",
                DateTime.UtcNow);

            await DoWorkAsync(stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(24), stoppingToken);

                try
                {
                    await DoWorkAsync(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "SlotRollingWindowJob error");
                }
            }
        }

        private async Task DoWorkAsync(CancellationToken ct)
        {
            using var scope = _scopeFactory.CreateScope();

            var configRepo = scope.ServiceProvider
                .GetRequiredService<IDoctorSlotConfigRepository>();

            var slotConfigService = scope.ServiceProvider
                .GetRequiredService<IDoctorSlotConfigService>();

            var timeSlotRepo = scope.ServiceProvider
                .GetRequiredService<ITimeSlotRepository>();

            var doctorIds = await configRepo
                .GetDoctorsWithActiveConfigsAsync(ct);

            _logger.LogInformation(
                "RollingWindowJob: processing {Count} doctors",
                doctorIds.Count);

            var targetEndDate = DateTime.UtcNow.Date.AddMonths(ROLLING_WINDOW_MONTHS);

            foreach (var doctorId in doctorIds)
            {
                try
                {
                    var lastSlotDate = await timeSlotRepo
                        .GetLastSlotDateAsync(doctorId, ct);

                    if (lastSlotDate.HasValue
                        && lastSlotDate.Value.Date >= targetEndDate)
                    {
                        _logger.LogDebug(
                            "Doctor {DoctorId} already covered until {Date}",
                            doctorId, lastSlotDate.Value.Date);
                        continue;
                    }

                    var startDate = lastSlotDate.HasValue
                        ? lastSlotDate.Value.Date.AddDays(1)
                        : DateTime.UtcNow.Date;

                    _logger.LogInformation(
                        "Extending slots for doctor {DoctorId}: {Start} → {End}",
                        doctorId, startDate, targetEndDate);

                    // GenerateSlotsAsync دلوقتي بتأخذ Exceptions في الاعتبار تلقائياً
                    var result = await slotConfigService.GenerateSlotsAsync(
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
        }
    }
}
