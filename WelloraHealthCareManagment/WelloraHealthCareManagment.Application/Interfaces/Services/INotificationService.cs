// Application/Interfaces/Services/INotificationService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface INotificationService
    {
        // Create notifications
        Task<ServiceResult<NotificationDto>> CreateNotificationAsync(CreateNotificationRequest request, CancellationToken ct = default);
        Task<ServiceResult> CreateBulkNotificationsAsync(List<CreateNotificationRequest> requests, CancellationToken ct = default);

        // Internal: Send notifications (called from other services)
        Task NotifyAsync(NotificationDispatchRequest request, CancellationToken ct = default);
        Task NotifyManyAsync(IEnumerable<NotificationDispatchRequest> requests, CancellationToken ct = default);
        Task NotifyAdminsAsync(
            string title,
            string message,
            NotificationType type,
            string? relatedEntityType = null,
            int? relatedEntityId = null,
            Dictionary<string, string>? data = null,
            CancellationToken ct = default);
        Task SendDoctorApprovedNotificationAsync(int doctorId, CancellationToken ct = default);
        Task SendDoctorRejectedNotificationAsync(int doctorId, string rejectionReason, CancellationToken ct = default);
        Task SendAccountBlockedNotificationAsync(int userId, string reason, CancellationToken ct = default);
        Task SendAccountSuspendedNotificationAsync(int userId, DateTime suspensionEnd, string reason, CancellationToken ct = default);
        Task SendAccountUnsuspendedNotificationAsync(int userId, CancellationToken ct = default);
        Task SendAccountUnblockedNotificationAsync(int userId, CancellationToken ct = default);
        Task SendTicketResponseNotificationAsync(int userId, Guid ticketId, CancellationToken ct = default);
        Task SendTicketClosedNotificationAsync(int userId, Guid ticketId, CancellationToken ct = default);
        Task SendReviewDeletedNotificationAsync(int userId, string doctorName, string reason, CancellationToken ct = default);

        // User queries
        Task<ServiceResult<NotificationListResponse>> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly = false,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        Task<ServiceResult<int>> GetUnreadCountAsync(int userId, CancellationToken ct = default);

        // Mark as read
        Task<ServiceResult> MarkAsReadAsync(Guid notificationId, int userId, CancellationToken ct = default);
        Task<ServiceResult> MarkAllAsReadAsync(int userId, CancellationToken ct = default);

        // Cleanup (background job)
        Task CleanupOldNotificationsAsync(int daysToKeep = 90, CancellationToken ct = default);

        // FCM Push Notification
        Task SendPushNotificationAsync(
            int userId,
            string title,
            string body,
            string? data = null,           // JSON string for custom data
            CancellationToken ct = default);

        // Send push to specific token (for internal use)
        Task SendPushToTokenAsync(
            string fcmToken,
            string title,
            string body,
            string? data = null,
            CancellationToken ct = default);

    }
}
