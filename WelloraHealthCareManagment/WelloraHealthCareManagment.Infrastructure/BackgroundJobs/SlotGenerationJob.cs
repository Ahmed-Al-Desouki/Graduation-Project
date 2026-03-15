using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.BackgroundJobs
{
    // Background Job لتوليد الخانات تلقائياً - Rolling Window Strategy
    public class SlotGenerationJob : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<SlotGenerationJob> _logger;
        private Timer? _timer;

        // ثوابت قابلة للتعديل
        private const int ROLLING_WINDOW_MONTHS = 2;
        private const int JOB_RUN_HOUR = 2; // 2 AM
        private const int BATCH_SIZE = 1000;

        public SlotGenerationJob(
            IServiceProvider serviceProvider,
            ILogger<SlotGenerationJob> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation(
                "Slot Generation Job started - Running daily at {Hour}:00 AM",
                JOB_RUN_HOUR);

            // أول تشغيل
            var timeUntilFirstRun = GetTimeUntilNextRun();

            _timer = new Timer(
                async _ => await GenerateSlotsForAllDoctors(stoppingToken),
                null,
                timeUntilFirstRun,
                TimeSpan.FromDays(1) // يتكرر كل 24 ساعة
            );

            return Task.CompletedTask;
        }

        private TimeSpan GetTimeUntilNextRun()
        {
            var now = DateTime.UtcNow;
            var nextRun = now.Date.AddHours(JOB_RUN_HOUR);

            if (now >= nextRun)
            {
                nextRun = nextRun.AddDays(1);
            }

            var timeUntil = nextRun - now;

            _logger.LogInformation(
                "Next slot generation at {NextRun} UTC (in {Hours:F1} hours)",
                nextRun, timeUntil.TotalHours);

            return timeUntil;
        }

        //توليد الخانات لكل الأطباء - Rolling Window Strategy
        private async Task GenerateSlotsForAllDoctors(CancellationToken stoppingToken)
        {
            try
            {
                _logger.LogInformation("Starting automatic slot generation (Rolling Window)");

                using var scope = _serviceProvider.CreateScope();
                var timeSlotService = scope.ServiceProvider.GetRequiredService<ITimeSlotService>();
                var scheduleRepository = scope.ServiceProvider.GetRequiredService<IDoctorScheduleRepository>();
                var timeSlotRepository = scope.ServiceProvider.GetRequiredService<ITimeSlotRepository>();

                // 1. جلب كل الأطباء النشطين
                var doctorIds = await scheduleRepository
                    .GetDoctorsWithActiveSchedulesAsync(stoppingToken);

                _logger.LogInformation(
                    "Found {Count} doctors with active schedules",
                    doctorIds.Count);

                int totalSlotsGenerated = 0;
                int doctorsProcessed = 0;

                // 2. لكل طبيب
                foreach (var doctorId in doctorIds)
                {
                    try
                    {
                        // Rolling Window: ولّد slots من اليوم لحد شهرين قدام
                        var startDate = DateTime.UtcNow.Date;
                        var endDate = startDate.AddMonths(ROLLING_WINDOW_MONTHS);

                        // تحقق من آخر slot موجود
                        var lastSlot = await timeSlotRepository
                            .GetLastSlotDateAsync(doctorId, stoppingToken);

                        // لو في slots موجودة، ابدأ من بعدها
                        if (lastSlot.HasValue && lastSlot.Value > startDate)
                        {
                            startDate = lastSlot.Value.AddDays(1);
                        }

                        // لو الفترة صغيرة جداً، تخطى
                        if ((endDate - startDate).TotalDays < 7)
                        {
                            _logger.LogDebug(
                                "Doctor {DoctorId} has sufficient slots, skipping",
                                doctorId);
                            continue;
                        }

                        var request = new GenerateSlotsRequest
                        {
                            StartDate = startDate,
                            EndDate = endDate,
                            RegenerateExisting = false,
                            BatchSize = BATCH_SIZE
                        };

                        var result = await timeSlotService.GenerateSlotsAsync(
                            doctorId, request, stoppingToken);

                        totalSlotsGenerated += result.SlotsGenerated;
                        doctorsProcessed++;

                        _logger.LogInformation(
                            "Doctor {DoctorId}: Generated {Count} slots in {Time}ms",
                            doctorId,
                            result.SlotsGenerated,
                            result.ProcessingTime.TotalMilliseconds);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex,
                            "Error generating slots for doctor {DoctorId}",
                            doctorId);
                        // استمر مع باقي الأطباء
                    }
                }

                _logger.LogInformation(
                    "Slot generation completed: {Doctors} doctors, {Slots} slots",
                    doctorsProcessed, totalSlotsGenerated);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Fatal error in slot generation job");
            }
        }

        public override async Task StopAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Slot Generation Job is stopping");
            _timer?.Change(Timeout.Infinite, 0);
            await base.StopAsync(stoppingToken);
        }

        public override void Dispose()
        {
            _timer?.Dispose();
            base.Dispose();
        }
    }
}