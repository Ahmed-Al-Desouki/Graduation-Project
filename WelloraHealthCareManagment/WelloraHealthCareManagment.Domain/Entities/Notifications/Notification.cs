using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.Entities.Notifications
{
    public class Notification : BaseEntity
    {
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public NotificationType Type { get; set; }
        public bool IsRead { get; set; } = false;
        public DateTime? ReadAt { get; set; }

        // For linking to specific entities (optional)
        public string? RelatedEntityType { get; set; } // "Doctor", "Ticket", "Review"
        public int? RelatedEntityId { get; set; }
        public string? RelatedEntityKey { get; set; }
        public string? NavigationTarget { get; set; }
        public string? NavigationPayloadJson { get; set; }

        // Navigation
        public ApplicationUser User { get; set; } = null!;
    }
}
