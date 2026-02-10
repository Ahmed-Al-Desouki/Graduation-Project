using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagement.Infrastructure.BackgroundJobs
{
    /// Background Job لتوليد الخانات تلقائياً كل يوم
    /// يعمل على الساعة 2 صباحاً يومياً
    public class SlotGenerationJob : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<SlotGenerationJob> _logger;
        private Timer? _timer;

        public SlotGenerationJob(
            IServiceProvider serviceProvider,
            ILogger<SlotGenerationJob> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Slot Generation Background Job started");

            // جدولة التشغيل على الساعة 2 صباحاً كل يوم
            var timeUntilFirstRun = GetTimeUntilNextRun();

            _timer = new Timer(
                async _ => await GenerateSlotsForAllDoctors(stoppingToken),
                null,
                timeUntilFirstRun,
                TimeSpan.FromDays(1) // يتكرر كل 24 ساعة
            );

            return Task.CompletedTask;
        }

        /// حساب الوقت المتبقي حتى الساعة 2 صباحاً القادمة
        private TimeSpan GetTimeUntilNextRun()
        {
            var now = DateTime.Now;
            var nextRun = now.Date.AddHours(2); // اليوم الساعة 2 صباحاً

            // إذا فات الوقت، خذ الساعة 2 صباحاً بكرة
            if (now >= nextRun)
            {
                nextRun = nextRun.AddDays(1);
            }

            var timeUntil = nextRun - now;

            _logger.LogInformation(
                "Next slot generation scheduled at {NextRun} (in {Hours} hours)",
                nextRun, timeUntil.TotalHours);

            return timeUntil;
        }

        /// توليد الخانات لكل الأطباء اللي عندهم جداول نشطة
        private async Task GenerateSlotsForAllDoctors(CancellationToken stoppingToken)
        {
            try
            {
                _logger.LogInformation("Starting automatic slot generation for all doctors");

                using var scope = _serviceProvider.CreateScope();
                var timeSlotService = scope.ServiceProvider.GetRequiredService<ITimeSlotService>();
                var scheduleRepository = scope.ServiceProvider.GetRequiredService<IDoctorScheduleRepository>();

                // 1. جلب كل الأطباء اللي عندهم جداول نشطة
                var doctorIds = await scheduleRepository.GetDoctorsWithActiveSchedulesAsync(stoppingToken);

                _logger.LogInformation("Found {Count} doctors with active schedules", doctorIds.Count);

                int totalSlotsGenerated = 0;
                int doctorsProcessed = 0;

                // 2. لكل طبيب، ولّد الخانات للشهرين القادمين
                foreach (var doctorId in doctorIds)
                {
                    try
                    {
                        var request = new GenerateSlotsRequest
                        {
                            StartDate = DateTime.UtcNow.Date,
                            EndDate = DateTime.UtcNow.Date.AddMonths(2), // شهرين قدام
                            RegenerateExisting = false // لا تحذف الخانات المحجوزة
                        };

                        var result = await timeSlotService.GenerateSlotsAsync(
                            doctorId, request, stoppingToken);

                        totalSlotsGenerated += result.SlotsGenerated;
                        doctorsProcessed++;

                        _logger.LogInformation(
                            "Generated {Count} slots for doctor {DoctorId}",
                            result.SlotsGenerated, doctorId);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex,
                            "Error generating slots for doctor {DoctorId}", doctorId);
                        // استمر مع باقي الأطباء
                    }
                }

                _logger.LogInformation(
                    "Slot generation completed. Processed {DoctorsCount} doctors, generated {SlotsCount} slots",
                    doctorsProcessed, totalSlotsGenerated);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Fatal error in slot generation job");
            }
        }

        public override async Task StopAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Slot Generation Background Job is stopping");

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