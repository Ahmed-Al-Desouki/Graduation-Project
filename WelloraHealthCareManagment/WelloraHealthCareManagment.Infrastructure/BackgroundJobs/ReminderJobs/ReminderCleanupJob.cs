using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

public class ReminderCleanupJob
{
    private readonly IServiceProvider _sp;
    private readonly ILogger<ReminderCleanupJob> _logger;

    // Soft-deleted reminders are hard-deleted after this many days
    private const int HardDeleteGraceDays = 7;

    public ReminderCleanupJob(IServiceProvider sp, ILogger<ReminderCleanupJob> logger)
    {
        _sp = sp;
        _logger = logger;
    }

    public async Task CleanupAllExpiredRemindersAsync()
    {

        var now = DateTime.UtcNow;
        var todayUtc = now.Date;
        _logger.LogInformation("Starting cleanup of expired reminders at {Time}", now);

        await using var scope = _sp.CreateAsyncScope();
        var reminderRepo = scope.ServiceProvider.GetRequiredService<IReminderRepository>();
        var cacheRepo = scope.ServiceProvider.GetRequiredService<IReminderOccurrencesCacheRepository>();

        await cacheRepo.DeleteAllPastOccurrencesAsync(todayUtc);

        var expiredReminders = await reminderRepo.GetAllExpiredActiveRemindersAsync(now);
        int softDeleted = 0;
        int hardDeleted = 0;

        foreach (var r in expiredReminders)
        {
            try
            {
                // Always wipe the cache immediately
                await cacheRepo.DeleteByReminderIdAsync(r.Id);

                if (!r.IsActive)
                {
                    // Already soft-deleted — check grace period for hard delete
                    var softDeletedAt = r.UpdatedAt; // UpdatedAt is set on soft-delete
                    if (softDeletedAt.HasValue &&
                        (now - softDeletedAt.Value).TotalDays >= HardDeleteGraceDays)
                    {
                        await reminderRepo.HardDeleteAsync(r.Id);
                        hardDeleted++;
                        _logger.LogInformation(
                            "Hard deleted expired reminder {Id} (was soft-deleted on {Date})",
                            r.Id, softDeletedAt.Value);
                    }
                }
                else
                {
                    // Soft delete first
                    r.IsActive = false;
                    r.Status = ReminderEnums.ReminderStatus.Dismissed;
                    r.UpdatedAt = now;
                    await reminderRepo.UpdateAsync(r);
                    softDeleted++;
                    _logger.LogInformation(
                        "Soft deleted expired reminder {Id} (Type: {Type}, End: {End})",
                        r.Id, r.Type, r.EndDateUtc);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to clean reminder {Id}", r.Id);
            }
        }

        _logger.LogInformation(
            "Cleanup finished: {SoftCount} soft-deleted, {HardCount} hard-deleted",
            softDeleted, hardDeleted);
    }
}