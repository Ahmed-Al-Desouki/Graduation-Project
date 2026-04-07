using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Domain.Entities.AdminLogs
{
    public class AdminActionLog : BaseEntity
    {
        public int AdminId { get; set; }
        public AdminActionType ActionType { get; set; }
        public string TargetEntity { get; set; } = string.Empty; // "Doctor", "User", "Review", "Ticket"
        public string TargetId { get; set; } = string.Empty; // Can be int or Guid, store as string
        public string? Details { get; set; } // JSON for additional context
        public string? IpAddress { get; set; }
        public string? UserAgent { get; set; }

        // Navigation
        public ApplicationUser Admin { get; set; } = null!;
    }
}
