// Application/Interfaces/AppRepositories/INotificationRepository.cs
using WelloraHealthCareManagment.Domain.Entities.Notifications;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface INotificationRepository
    {
        Task<Notification> CreateAsync(Notification notification, CancellationToken ct = default);
        Task<List<Notification>> CreateBulkAsync(List<Notification> notifications, CancellationToken ct = default);
        Task UpdateAsync(Notification notification, CancellationToken ct = default);
        Task<Notification?> GetByIdAsync(Guid id, CancellationToken ct = default);

        Task<List<Notification>> GetByUserIdAsync(
            int userId,
            bool unreadOnly = false,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        Task<int> CountByUserIdAsync(
            int userId,
            bool unreadOnly = false,
            CancellationToken ct = default);

        Task<int> CountUnreadByUserIdAsync(int userId, CancellationToken ct = default);

        // Mark as read
        Task MarkAsReadAsync(Guid notificationId, CancellationToken ct = default);
        Task MarkAllAsReadAsync(int userId, CancellationToken ct = default);

        // Cleanup old notifications
        Task DeleteOldNotificationsAsync(DateTime olderThan, CancellationToken ct = default);

        // Admin queries
        Task<List<Notification>> GetByTypeAsync(
            NotificationType type,
            int page,
            int pageSize,
            CancellationToken ct = default);
    }
}
