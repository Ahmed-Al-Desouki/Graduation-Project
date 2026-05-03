using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Domain.Entities.UserManagement
{
    public class UserStatus : BaseEntity
    {
        public int UserId { get; set; }

        // Blocking
        public bool IsBlocked { get; set; } = false;
        public DateTime? BlockedAt { get; set; }
        public int? BlockedByAdminId { get; set; }
        public string? BlockReason { get; set; }

        // Suspension
        public bool IsSuspended { get; set; } = false;
        public DateTime? SuspendedAt { get; set; }
        public DateTime? SuspensionEndDate { get; set; }
        public int? SuspendedByAdminId { get; set; }
        public string? SuspensionReason { get; set; }

        // Navigation Properties
        public ApplicationUser User { get; set; } = null!;
        public ApplicationUser? BlockedByAdmin { get; set; }
        public ApplicationUser? SuspendedByAdmin { get; set; }
    }
}
