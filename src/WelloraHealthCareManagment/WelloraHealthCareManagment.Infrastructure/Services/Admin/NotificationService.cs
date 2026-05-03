// Infrastructure/Services/NotificationService.cs
using AutoMapper;
using HealthCare_.Models.DoctorModels;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Application.Common.Localization;
using WelloraHealthCareManagment.Domain.Entities.Notifications;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Services.Notifications;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class NotificationService : INotificationService
    {
        private readonly INotificationRepository _notificationRepository;
        private readonly IUserRepository _userRepository;
        private readonly IUserDeviceRepository _userDeviceRepository;
        private readonly IFirebaseNotificationService _firebaseService;
        private readonly IRealtimeService _realtimeService;
        private readonly IMapper _mapper;
        private readonly IAppLocalizationService _localizationService;
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(
            INotificationRepository notificationRepository,
            IUserRepository userRepository,
            IUserDeviceRepository userDeviceRepository,
            IFirebaseNotificationService firebaseService,
            IRealtimeService realtimeService,
            IMapper mapper,
            IAppLocalizationService localizationService,
            ILogger<NotificationService> logger)
        {
            _notificationRepository = notificationRepository;
            _userRepository = userRepository;
            _userDeviceRepository = userDeviceRepository;
            _firebaseService = firebaseService;
            _realtimeService = realtimeService;
            _mapper = mapper;
            _localizationService = localizationService;
            _logger = logger;
        }

        public async Task NotifyAsync(NotificationDispatchRequest request, CancellationToken ct = default)
        {
            var normalizedRequest = NormalizeDispatchRequest(request);
            var userLanguage = await _userRepository.GetPreferredLanguageAsync(normalizedRequest.UserId, ct)
                ?? AppLanguages.English;
            using var languageScope = AppLanguageContext.BeginScope(userLanguage);
            normalizedRequest.Title = _localizationService.TranslateText(normalizedRequest.Title, userLanguage);
            normalizedRequest.Message = _localizationService.TranslateText(normalizedRequest.Message, userLanguage);

            var createResult = await CreateNotificationAsync(new CreateNotificationRequest
            {
                UserId = normalizedRequest.UserId,
                Title = normalizedRequest.Title,
                Message = normalizedRequest.Message,
                Type = normalizedRequest.Type,
                RelatedEntityType = normalizedRequest.RelatedEntityType,
                RelatedEntityId = normalizedRequest.RelatedEntityId,
                RelatedEntityKey = normalizedRequest.RelatedEntityKey,
                NavigationTarget = normalizedRequest.NavigationTarget,
                NavigationPayload = normalizedRequest.Data == null
                    ? null
                    : new Dictionary<string, string>(normalizedRequest.Data)
            }, ct);

            if (!createResult.IsSuccess)
            {
                _logger.LogWarning(
                    "Failed to persist notification for user {UserId} and type {Type}",
                    normalizedRequest.UserId,
                    normalizedRequest.Type);
            }

            var data = BuildPushPayload(normalizedRequest);
            await SendPushNotificationAsync(normalizedRequest.UserId, normalizedRequest.Title, normalizedRequest.Message, data, ct);
        }

        public async Task NotifyManyAsync(IEnumerable<NotificationDispatchRequest> requests, CancellationToken ct = default)
        {
            var materializedRequests = requests
                .Where(r => r.UserId > 0)
                .GroupBy(r => new
                {
                    r.UserId,
                    r.Title,
                    r.Message,
                    r.Type,
                    r.RelatedEntityType,
                    r.RelatedEntityId,
                    r.RelatedEntityKey,
                    r.NavigationTarget
                })
                .Select(g => g.First())
                .ToList();

            foreach (var request in materializedRequests)
            {
                await NotifyAsync(request, ct);
            }
        }

        public async Task NotifyAdminsAsync(
            string title,
            string message,
            NotificationType type,
            string? relatedEntityType = null,
            int? relatedEntityId = null,
            Dictionary<string, string>? data = null,
            CancellationToken ct = default)
        {
            var adminIds = await _userRepository.GetUserIdsByRoleAsync("Admin", ct);
            if (!adminIds.Any())
            {
                _logger.LogInformation("No admin users found for notification type {Type}", type);
                return;
            }

            var requests = adminIds.Select(adminId => new NotificationDispatchRequest
            {
                UserId = adminId,
                Title = title,
                Message = message,
                Type = type,
                RelatedEntityType = relatedEntityType,
                RelatedEntityId = relatedEntityId,
                Data = data == null ? null : new Dictionary<string, string>(data)
            });

            await NotifyManyAsync(requests, ct);
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
                    RelatedEntityKey = request.RelatedEntityKey,
                    NavigationTarget = request.NavigationTarget,
                    NavigationPayloadJson = SerializeNavigationPayload(request.NavigationPayload),
                    IsRead = false,
                    CreatedAt = DateTime.UtcNow
                };

                var created = await _notificationRepository.CreateAsync(notification, ct);
                var dto = _mapper.Map<NotificationDto>(created);

                await _realtimeService.BroadcastToUserAsync(
                    request.UserId,
                    "NotificationReceived",
                    dto,
                    ct);

                _logger.LogInformation(
                    "Notification created for user {UserId}: {Type}",
                    request.UserId, request.Type);

                return ServiceResult<NotificationDto>.Success(dto);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating notification for user {UserId}", request.UserId);
                return ServiceResult<NotificationDto>.Failure(_localizationService.TranslateText("Failed to create notification"));
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
                    RelatedEntityKey = r.RelatedEntityKey,
                    NavigationTarget = r.NavigationTarget,
                    NavigationPayloadJson = SerializeNavigationPayload(r.NavigationPayload),
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
                return ServiceResult.Failure(_localizationService.TranslateText("Failed to create notifications"));
            }
        }

        public async Task SendDoctorApprovedNotificationAsync(
            int doctorId,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = doctorId,
                Title = _localizationService.Localize("Notification.VerificationApprovedTitle"),
                Message =
                    $"Your doctor verification for {NotificationMessageFormatter.FormatDoctor(null, doctorId)} " +
                    "has been approved. You can now access doctor features and start receiving patients.",
                Type = NotificationType.DoctorApproved,
                RelatedEntityType = "Doctor",
                RelatedEntityId = doctorId,
                Data = new Dictionary<string, string> { ["doctorId"] = doctorId.ToString() }
            }, ct);
        }

        public async Task SendDoctorRejectedNotificationAsync(
            int doctorId,
            string rejectionReason,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = doctorId,
                Title = _localizationService.Localize("Notification.VerificationRejectedTitle"),
                Message =
                    $"Your doctor verification for {NotificationMessageFormatter.FormatDoctor(null, doctorId)} " +
                    $"was rejected. {NotificationMessageFormatter.FormatReason(rejectionReason)}",
                Type = NotificationType.DoctorRejected,
                RelatedEntityType = "Doctor",
                RelatedEntityId = doctorId,
                Data = new Dictionary<string, string>
                {
                    ["doctorId"] = doctorId.ToString(),
                    ["reason"] = rejectionReason
                }
            }, ct);
        }

        public async Task SendAccountBlockedNotificationAsync(
            int userId,
            string reason,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = _localizationService.Localize("Notification.AccountBlockedTitle"),
                Message =
                    $"Your account (User #{userId}) has been blocked. " +
                    $"{NotificationMessageFormatter.FormatReason(reason)} Please contact support for more information.",
                Type = NotificationType.AccountBlocked,
                Data = new Dictionary<string, string> { ["reason"] = reason }
            }, ct);
        }

        public async Task SendAccountSuspendedNotificationAsync(
            int userId,
            DateTime suspensionEnd,
            string reason,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "Account Suspended",
                Message =
                    $"Your account (User #{userId}) has been suspended until {NotificationMessageFormatter.FormatDateTime(suspensionEnd)}. " +
                    $"{NotificationMessageFormatter.FormatReason(reason)}",
                Type = NotificationType.AccountSuspended,
                Data = new Dictionary<string, string>
                {
                    ["suspensionEnd"] = suspensionEnd.ToString("O"),
                    ["reason"] = reason
                }
            }, ct);
        }

        public async Task SendAccountUnsuspendedNotificationAsync(
            int userId,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "Account Restored",
                Message = $"Your account suspension for User #{userId} has ended and your access has been restored.",
                Type = NotificationType.AccountUnsuspended
            }, ct);
        }

        public async Task SendAccountUnblockedNotificationAsync(
            int userId,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "Account Unblocked",
                Message = $"Your account (User #{userId}) has been unblocked. You can now access all available features again.",
                Type = NotificationType.AccountUnblocked
            }, ct);
        }

        public async Task SendTicketResponseNotificationAsync(
            int userId,
            Guid ticketId,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "New Ticket Response",
                Message = $"An admin responded to your support ticket #{ticketId}. Open the ticket to review the latest reply.",
                Type = NotificationType.TicketResponse,
                RelatedEntityType = "Ticket",
                Data = new Dictionary<string, string> { ["ticketId"] = ticketId.ToString() }
            }, ct);
        }

        public async Task SendTicketClosedNotificationAsync(
            int userId,
            Guid ticketId,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "Ticket Closed",
                Message = $"Your support ticket #{ticketId} has been closed. If you still need help, you can create a new ticket at any time.",
                Type = NotificationType.TicketClosed,
                RelatedEntityType = "Ticket",
                Data = new Dictionary<string, string> { ["ticketId"] = ticketId.ToString() }
            }, ct);
        }

        public async Task SendReviewDeletedNotificationAsync(
            int userId,
            string doctorName,
            string reason,
            CancellationToken ct = default)
        {
            await NotifyAsync(new NotificationDispatchRequest
            {
                UserId = userId,
                Title = "Review Removed",
                Message =
                    $"Your review for {NotificationMessageFormatter.FormatDoctor(doctorName)} was removed. " +
                    $"{NotificationMessageFormatter.FormatReason(reason)}",
                Type = NotificationType.ReviewDeleted,
                Data = new Dictionary<string, string>
                {
                    ["doctorName"] = doctorName,
                    ["reason"] = reason
                }
            }, ct);
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
                page = Math.Max(page, 1);
                pageSize = pageSize <= 0 ? 20 : pageSize;

                var totalCount = await _notificationRepository.CountByUserIdAsync(
                    userId, unreadOnly, ct);

                var notifications = await _notificationRepository.GetByUserIdAsync(
                    userId, unreadOnly, page, pageSize, ct);

                var unreadCount = await _notificationRepository.CountUnreadByUserIdAsync(userId, ct);

                var dtos = _mapper.Map<List<NotificationDto>>(notifications);

                var response = new NotificationListResponse
                {
                    Notifications = dtos,
                    TotalCount = totalCount,
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

        private static string? BuildPushPayload(NotificationDispatchRequest request)
        {
            var payload = request.Data == null
                ? new Dictionary<string, string>()
                : new Dictionary<string, string>(request.Data);

            payload["type"] = request.Type.ToString();

            if (!string.IsNullOrWhiteSpace(request.RelatedEntityType))
            {
                payload["relatedEntityType"] = request.RelatedEntityType;
            }

            if (request.RelatedEntityId.HasValue)
            {
                payload["relatedEntityId"] = request.RelatedEntityId.Value.ToString();
            }

            if (!string.IsNullOrWhiteSpace(request.RelatedEntityKey))
            {
                payload["relatedEntityKey"] = request.RelatedEntityKey;
            }

            if (!string.IsNullOrWhiteSpace(request.NavigationTarget))
            {
                payload["navigationTarget"] = request.NavigationTarget;
            }

            return payload.Count == 0 ? null : JsonSerializer.Serialize(payload);
        }

        private static NotificationDispatchRequest NormalizeDispatchRequest(NotificationDispatchRequest request)
        {
            var data = request.Data == null
                ? new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
                : new Dictionary<string, string>(request.Data, StringComparer.OrdinalIgnoreCase);

            var relatedEntityType = string.IsNullOrWhiteSpace(request.RelatedEntityType)
                ? InferRelatedEntityType(request.Type, data)
                : request.RelatedEntityType;

            var relatedEntityId = request.RelatedEntityId ?? InferNumericEntityId(relatedEntityType, data);
            var relatedEntityKey = string.IsNullOrWhiteSpace(request.RelatedEntityKey)
                ? InferEntityKey(relatedEntityType, relatedEntityId, data)
                : request.RelatedEntityKey;
            var navigationTarget = string.IsNullOrWhiteSpace(request.NavigationTarget)
                ? InferNavigationTarget(relatedEntityType, request.Type)
                : request.NavigationTarget;

            if (!string.IsNullOrWhiteSpace(relatedEntityType))
            {
                data["relatedEntityType"] = relatedEntityType;
            }

            if (relatedEntityId.HasValue)
            {
                data["relatedEntityId"] = relatedEntityId.Value.ToString();
            }

            if (!string.IsNullOrWhiteSpace(relatedEntityKey))
            {
                data["relatedEntityKey"] = relatedEntityKey;
            }

            if (!string.IsNullOrWhiteSpace(navigationTarget))
            {
                data["navigationTarget"] = navigationTarget;
            }

            return new NotificationDispatchRequest
            {
                UserId = request.UserId,
                Title = request.Title,
                Message = request.Message,
                Type = request.Type,
                RelatedEntityType = relatedEntityType,
                RelatedEntityId = relatedEntityId,
                RelatedEntityKey = relatedEntityKey,
                NavigationTarget = navigationTarget,
                Data = data.Count == 0 ? null : data
            };
        }

        private static string? InferRelatedEntityType(NotificationType type, Dictionary<string, string> data)
        {
            foreach (var pair in PrimaryEntityKeyMap)
            {
                if (data.ContainsKey(pair.Value))
                {
                    return pair.Key;
                }
            }

            return type switch
            {
                NotificationType.Welcome => "User",
                NotificationType.DoctorRegistrationSubmitted => "Doctor",
                NotificationType.DoctorProfileCompleted => "Doctor",
                NotificationType.DoctorVerificationSubmitted => "DoctorVerification",
                NotificationType.DoctorApproved => "Doctor",
                NotificationType.DoctorRejected => "Doctor",
                NotificationType.AccountBlocked => "User",
                NotificationType.AccountSuspended => "User",
                NotificationType.AccountUnsuspended => "User",
                NotificationType.AccountUnblocked => "User",
                NotificationType.AppointmentBooked => "Appointment",
                NotificationType.AppointmentCancelledByPatient => "Appointment",
                NotificationType.AppointmentCancelledByDoctor => "Appointment",
                NotificationType.ReviewRequested => "Appointment",
                NotificationType.PaymentPending => "Payment",
                NotificationType.PaymentSucceeded => "Payment",
                NotificationType.PaymentFailed => "Payment",
                NotificationType.RefundProcessed => "Payment",
                NotificationType.MedicalRecordCreated => "MedicalRecord",
                NotificationType.MedicalRecordUpdated => "MedicalRecord",
                NotificationType.MedicalHistoryViewed => "Appointment",
                NotificationType.MedicalHistoryAccessRequested => "Appointment",
                NotificationType.MedicalHistoryAccessGranted => "Appointment",
                NotificationType.MedicalHistoryAccessUpdated => "Appointment",
                NotificationType.MedicalHistoryAccessRevoked => "Appointment",
                NotificationType.MedicalHistoryAccessExtended => "Appointment",
                NotificationType.PrescriptionCreated => "Prescription",
                NotificationType.PrescriptionUpdated => "Prescription",
                NotificationType.ReminderCreated => "Reminder",
                NotificationType.ReminderUpdated => "Reminder",
                NotificationType.MfaEnabled => "User",
                NotificationType.MfaDisabled => "User",
                NotificationType.PasswordReset => "User",
                NotificationType.ReviewCreated => "Review",
                NotificationType.ReviewUpdated => "Review",
                NotificationType.ReviewDeletedByPatient => "Review",
                NotificationType.TicketCreated => "Ticket",
                NotificationType.TicketResponse => "Ticket",
                NotificationType.TicketClosed => "Ticket",
                NotificationType.ReviewDeleted => "Review",
                _ => null
            };
        }

        private static int? InferNumericEntityId(string? relatedEntityType, Dictionary<string, string> data)
        {
            if (!string.IsNullOrWhiteSpace(relatedEntityType) &&
                PrimaryEntityKeyMap.TryGetValue(relatedEntityType, out var primaryKeyName) &&
                data.TryGetValue(primaryKeyName, out var primaryKeyValue) &&
                int.TryParse(primaryKeyValue, out var parsedPrimaryId))
            {
                return parsedPrimaryId;
            }

            if (data.TryGetValue("relatedEntityId", out var relatedEntityIdValue) &&
                int.TryParse(relatedEntityIdValue, out var parsedRelatedEntityId))
            {
                return parsedRelatedEntityId;
            }

            return null;
        }

        private static string? InferEntityKey(
            string? relatedEntityType,
            int? relatedEntityId,
            Dictionary<string, string> data)
        {
            if (!string.IsNullOrWhiteSpace(relatedEntityType) &&
                ParentContextKeyPriorityMap.TryGetValue(relatedEntityType, out var parentKeyPriority))
            {
                foreach (var candidateKey in parentKeyPriority)
                {
                    if (data.TryGetValue(candidateKey, out var candidateValue) &&
                        !string.IsNullOrWhiteSpace(candidateValue))
                    {
                        return candidateValue;
                    }
                }
            }

            if (!string.IsNullOrWhiteSpace(relatedEntityType) &&
                PrimaryEntityKeyMap.TryGetValue(relatedEntityType, out var primaryKeyName) &&
                data.TryGetValue(primaryKeyName, out var primaryKeyValue) &&
                !string.IsNullOrWhiteSpace(primaryKeyValue))
            {
                return primaryKeyValue;
            }

            if (data.TryGetValue("relatedEntityKey", out var relatedEntityKey) &&
                !string.IsNullOrWhiteSpace(relatedEntityKey))
            {
                return relatedEntityKey;
            }

            return relatedEntityId?.ToString();
        }

        private static string InferNavigationTarget(string? relatedEntityType, NotificationType type)
        {
            return relatedEntityType switch
            {
                "Appointment" => type == NotificationType.ReviewRequested ? "review_create" : "appointment_details",
                "Payment" => "payment_details",
                "Prescription" => "prescription_details",
                "Review" => "review_details",
                "Ticket" => "ticket_details",
                "Doctor" => "doctor_profile",
                "DoctorVerification" => "doctor_verification_status",
                "Patient" => "patient_profile",
                "Reminder" => "reminder_details",
                "MedicalRecord" => "medical_record_details",
                "User" => "account_security",
                _ => "notifications"
            };
        }

        private static string? SerializeNavigationPayload(Dictionary<string, string>? payload)
        {
            return payload == null || payload.Count == 0
                ? null
                : JsonSerializer.Serialize(payload);
        }

        private static readonly Dictionary<string, string> PrimaryEntityKeyMap = new(StringComparer.OrdinalIgnoreCase)
        {
            ["Appointment"] = "appointmentId",
            ["Payment"] = "paymentId",
            ["Prescription"] = "prescriptionId",
            ["Review"] = "reviewId",
            ["Ticket"] = "ticketId",
            ["Doctor"] = "doctorId",
            ["Patient"] = "patientId",
            ["User"] = "userId",
            ["Reminder"] = "reminderId",
            ["MedicalRecord"] = "medicalRecordId",
            ["DoctorVerification"] = "verificationId"
        };

        private static readonly Dictionary<string, string[]> ParentContextKeyPriorityMap =
            new(StringComparer.OrdinalIgnoreCase)
        {
            ["Appointment"] = new[] { "appointmentId" },
            ["Payment"] = new[] { "appointmentId", "paymentId" },
            ["Prescription"] = new[] { "appointmentId", "prescriptionId" },
            ["MedicalRecord"] = new[] { "appointmentId", "medicalRecordId" },
            ["Reminder"] = new[] { "appointmentId", "prescriptionId", "reminderId" },
            ["Review"] = new[] { "appointmentId", "doctorId", "reviewId" },
            ["Ticket"] = new[] { "ticketId" },
            ["DoctorVerification"] = new[] { "doctorId", "verificationId" },
            ["Doctor"] = new[] { "doctorId" },
            ["Patient"] = new[] { "patientId" },
            ["User"] = new[] { "userId" }
        };

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
