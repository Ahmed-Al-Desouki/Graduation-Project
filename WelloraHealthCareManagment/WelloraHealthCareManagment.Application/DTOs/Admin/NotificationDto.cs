using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class NotificationDto
    {
        public Guid Id { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public NotificationType Type { get; set; }
        public bool IsRead { get; set; }
        public DateTime? ReadAt { get; set; }
        public DateTime CreatedAt { get; set; }
        public string? RelatedEntityType { get; set; }
        public int? RelatedEntityId { get; set; }
        public string? RelatedEntityKey { get; set; }
        public string? NavigationTarget { get; set; }
        public Dictionary<string, string>? NavigationPayload { get; set; }
    }

    public class CreateNotificationRequest
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public NotificationType Type { get; set; }
        public string? RelatedEntityType { get; set; }
        public int? RelatedEntityId { get; set; }
        public string? RelatedEntityKey { get; set; }
        public string? NavigationTarget { get; set; }
        public Dictionary<string, string>? NavigationPayload { get; set; }
    }

    public class NotificationDispatchRequest
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public NotificationType Type { get; set; }
        public string? RelatedEntityType { get; set; }
        public int? RelatedEntityId { get; set; }
        public string? RelatedEntityKey { get; set; }
        public string? NavigationTarget { get; set; }
        public Dictionary<string, string>? Data { get; set; }
    }

    public class NotificationListResponse
    {
        public List<NotificationDto> Notifications { get; set; } = new();
        public int TotalCount { get; set; }
        public int UnreadCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
    }

    public class MarkNotificationAsReadRequest
    {
        public Guid NotificationId { get; set; }
    }
}
