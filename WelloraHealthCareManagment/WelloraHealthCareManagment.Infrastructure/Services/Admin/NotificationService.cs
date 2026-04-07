// Infrastructure/Services/NotificationService.cs
using AutoMapper;
using HealthCare_.Models.DoctorModels;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.Notifications;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notificationRepository;
        private readonly IUserRepository _userRepository;
        private readonly IUserDeviceRepository _userDeviceRepository;
        private readonly IFirebaseNotificationService _firebaseService;
        private readonly IMapper _mapper;
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(
            INotificationRepository notificationRepository,
            IUserRepository userRepository,
            IUserDeviceRepository userDeviceRepository,
            IFirebaseNotificationService firebaseService,
            IMapper mapper,
            ILogger<NotificationService> logger)
        {
            _notificationRepository = notificationRepository;
            _userRepository = userRepository;
            _userDeviceRepository = userDeviceRepository;
            _firebaseService = firebaseService;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<ServiceResult<NotificationDto>> CreateNotificationAsync(
            CreateNotificationRequest request,
            CancellationToken ct = default)
        {
            try
            {
                var notification = new Notification
                {
                    UserId = request.UserId,
                    Title = request.Title,
                    Message = request.Message,
                    Type = request.Type,
                    RelatedEntityType = request.RelatedEntityType,
                    RelatedEntityId = request.RelatedEntityId,
                    IsRead = false,
                    CreatedAt = DateTime.UtcNow
                };

                var created = await _notificationRepository.CreateAsync(notification, ct);
                var dto = _mapper.Map<NotificationDto>(created);

                _logger.LogInformation(
                    "Notification created for user {UserId}: {Type}",
                    request.UserId, request.Type);

                return ServiceResult<NotificationDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating notification for user {UserId}", request.UserId);
                return ServiceResult<NotificationDto>.Failure("Failed to create notification");
            }
        }

        public async Task<ServiceResult> CreateBulkNotificationsAsync(
            List<CreateNotificationRequest> requests,
            CancellationToken ct = default)
        {
            try
            {
                var notifications = requests.Select(r => new Notification
                {
                    UserId = r.UserId,
                    Title = r.Title,
                    Message = r.Message,
                    Type = r.Type,
                    RelatedEntityType = r.RelatedEntityType,
                    RelatedEntityId = r.RelatedEntityId,
                    IsRead = false,
                    CreatedAt = DateTime.UtcNow
                }).ToList();

                await _notificationRepository.CreateBulkAsync(notifications, ct);

                _logger.LogInformation("Created {Count} notifications in bulk", requests.Count);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating bulk notifications");
                return ServiceResult.Failure("Failed to create notifications");
            }
        }

        public async Task SendDoctorApprovedNotificationAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = doctorId,
                Title = "Verification Approved",
                Message = "Congratulations! Your doctor verification has been approved. You can now access all doctor features.",
                Type = NotificationType.DoctorApproved,
                RelatedEntityType = "Doctor",
                RelatedEntityId = doctorId
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
            userId: doctorId,
            title: "Verification Approved",
            body: "Congratulations! Your doctor verification has been approved. You can now access all doctor features.",
            ct: ct);

        }

        public async Task SendDoctorRejectedNotificationAsync(
            int doctorId,
            string rejectionReason,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = doctorId,
                Title = "Verification Rejected",
                Message = $"Your doctor verification has been rejected. Reason: {rejectionReason}",
                Type = NotificationType.DoctorRejected,
                RelatedEntityType = "Doctor",
                RelatedEntityId = doctorId
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
            userId: doctorId,
            title: "Verification Rejected",
            body: $"Your doctor verification has been rejected. Reason: {rejectionReason}",
            ct: ct);
        }

        public async Task SendAccountBlockedNotificationAsync(
            int userId,
            string reason,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "Account Blocked",
                Message = $"Your account has been blocked. Reason: {reason}. Please contact support for more information.",
                Type = NotificationType.AccountBlocked
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
            userId: userId,
            title: "Account Blocked",
            body: $"Your account has been blocked. Reason: {reason}. Please contact support for more information.",
            ct: ct);
        }

        public async Task SendAccountSuspendedNotificationAsync(
            int userId,
            DateTime suspensionEnd,
            string reason,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "Account Suspended",
                Message = $"Your account has been suspended until {suspensionEnd:yyyy-MM-dd}. Reason: {reason}",
                Type = NotificationType.AccountSuspended
            };

            await CreateNotificationAsync(request, ct);
            
            await SendPushNotificationAsync(
            userId: userId,
            title: "Account Suspended",
            body: $"Your account has been suspended until {suspensionEnd:yyyy-MM-dd}. Reason: {reason}.",
            ct: ct);
        }

        public async Task SendAccountUnblockedNotificationAsync(
            int userId,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "Account Unblocked",
                Message = "Your account has been unblocked. You can now access all features.",
                Type = NotificationType.AccountUnblocked
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
            userId: userId,
            title: "Account Unblocked",
            body: "Your account has been unblocked. You can now access all features.",
            ct: ct);
        }

        public async Task SendTicketResponseNotificationAsync(
            int userId,
            Guid ticketId,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "New Ticket Response",
                Message = "An admin has responded to your support ticket.",
                Type = NotificationType.TicketResponse,
                RelatedEntityType = "Ticket",
                RelatedEntityId = null // Guid stored separately
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
                userId: userId,
                title: "New Ticket Response",
                body: "An admin has responded to your support ticket.",
                ct: ct);
        }

        public async Task SendTicketClosedNotificationAsync(
            int userId,
            Guid ticketId,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "Ticket Closed",
                Message = "Your support ticket has been closed. If you need further assistance, feel free to create a new ticket.",
                Type = NotificationType.TicketClosed,
                RelatedEntityType = "Ticket"
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
                userId: userId,
                title: "Ticket Closed",
                body: "Your support ticket has been closed. If you need further assistance, feel free to create a new ticket.",
                ct: ct);
        }

        public async Task SendReviewDeletedNotificationAsync(
            int userId,
            string doctorName,
            string reason,
            CancellationToken ct = default)
        {
            var request = new CreateNotificationRequest
            {
                UserId = userId,
                Title = "Review Removed",
                Message = $"Your review for Dr. {doctorName} has been removed. Reason: {reason}",
                Type = NotificationType.ReviewDeleted
            };

            await CreateNotificationAsync(request, ct);

            await SendPushNotificationAsync(
                userId: userId,
                title: "Review Removed",
                body: $"Your review for Dr. {doctorName} has been removed. Reason: {reason}.",
                ct: ct);
        }

        public async Task<ServiceResult<NotificationListResponse>> GetUserNotificationsAsync(
            int userId,
            bool unreadOnly = false,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            try
            {
                var notifications = await _notificationRepository.GetByUserIdAsync(
                    userId, unreadOnly, page, pageSize, ct);

                var unreadCount = await _notificationRepository.CountUnreadByUserIdAsync(userId, ct);

                var dtos = _mapper.Map<List<NotificationDto>>(notifications);

                var response = new NotificationListResponse
                {
                    Notifications = dtos,
                    TotalCount = notifications.Count,
                    UnreadCount = unreadCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<NotificationListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting notifications for user {UserId}", userId);
                return ServiceResult<NotificationListResponse>.Failure("Failed to get notifications");
            }
        }

        public async Task<ServiceResult<int>> GetUnreadCountAsync(
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                var count = await _notificationRepository.CountUnreadByUserIdAsync(userId, ct);
                return ServiceResult<int>.Success(count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting unread count for user {UserId}", userId);
                return ServiceResult<int>.Failure("Failed to get unread count");
            }
        }

        public async Task<ServiceResult> MarkAsReadAsync(
            Guid notificationId,
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                // Verify notification belongs to user
                var notification = await _notificationRepository.GetByIdAsync(notificationId, ct);
                if (notification == null)
                    return ServiceResult.Failure("Notification not found");

                if (notification.UserId != userId)
                    return ServiceResult.Failure("Unauthorized");

                await _notificationRepository.MarkAsReadAsync(notificationId, ct);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking notification {NotificationId} as read", notificationId);
                return ServiceResult.Failure("Failed to mark notification as read");
            }
        }

        public async Task<ServiceResult> MarkAllAsReadAsync(
            int userId,
            CancellationToken ct = default)
        {
            try
            {
                await _notificationRepository.MarkAllAsReadAsync(userId, ct);
                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking all notifications as read for user {UserId}", userId);
                return ServiceResult.Failure("Failed to mark notifications as read");
            }
        }

        public async Task CleanupOldNotificationsAsync(
            int daysToKeep = 90,
            CancellationToken ct = default)
        {
            try
            {
                var cutoffDate = DateTime.UtcNow.AddDays(-daysToKeep);
                await _notificationRepository.DeleteOldNotificationsAsync(cutoffDate, ct);

                _logger.LogInformation(
                    "Cleaned up notifications older than {CutoffDate}",
                    cutoffDate);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cleaning up old notifications");
            }
        }
        public async Task SendPushNotificationAsync(
        int userId,
        string title,
        string body,
        string? data = null,
        CancellationToken ct = default)
        {
            try
            {
                var tokens = await _userDeviceRepository.GetAllActiveDeviceTokensAsync(userId, ct);
                if (!tokens.Any()) return;

                foreach (var token in tokens)
                {
                    await _firebaseService.SendPushAsync(token, title, body, data, ct);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send push notification to user {UserId}", userId);
            }
        }

        public async Task SendPushToTokenAsync(
            string fcmToken,
            string title,
            string body,
            string? data = null,
            CancellationToken ct = default)
        {
            try
            {
                await _firebaseService.SendPushAsync(fcmToken, title, body, data, ct);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send push to specific token");
            }
        }
    }
}