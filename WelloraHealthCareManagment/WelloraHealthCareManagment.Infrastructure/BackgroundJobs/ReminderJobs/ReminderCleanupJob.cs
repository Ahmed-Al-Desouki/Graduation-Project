using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

public class ReminderCleanupJob
{
    private readonly IServiceProvider _sp;
    private readonly ILogger<ReminderCleanupJob> _logger;

    public ReminderCleanupJob(IServiceProvider sp, ILogger<ReminderCleanupJob> logger)
    {
        _sp = sp;
        _logger = logger;
    }

    public async Task CleanupAllExpiredRemindersAsync()
    {
        var now = DateTime.UtcNow;
        _logger.LogInformation("🧹 Starting cleanup of ALL expired reminders at {Time}", now);

        await using var scope = _sp.CreateAsyncScope();
        var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
        var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

        // جيب كل التذكيرات المنتهية النشطة (مش بس prescriptions)
        var expiredReminders = await reminderRepo.GetAllExpiredActiveRemindersAsync(now);

        int cleaned = 0;
        foreach (var r in expiredReminders)
        {
            try
            {
                // 1. Soft delete الـ Reminder نفسه
                r.IsActive = false;
                r.Status = Enums.ReminderStatus.Dismissed; // أو Expired حسب enumك
                r.UpdatedAt = now;
                await reminderRepo.UpdateAsync(r);

                // 2. امسح الكاش الخاص بالتذكير ده
                await cacheRepo.DeleteByReminderIdAsync(r.Id);

                cleaned++;
                _logger.LogInformation(
                    "Cleaned expired reminder {Id} (Type: {Type}, End: {End})",
                    r.Id, r.Type, r.EndDateUtc);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to clean reminder {Id}", r.Id);
            }
        }

        _logger.LogInformation("Cleanup finished: {Count} expired reminders cleaned", cleaned);
    }
}