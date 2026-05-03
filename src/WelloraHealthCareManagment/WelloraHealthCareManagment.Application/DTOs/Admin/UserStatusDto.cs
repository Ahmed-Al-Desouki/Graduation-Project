using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class UserStatusDto
    {
        public Guid Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public bool IsBlocked { get; set; }
        public DateTime? BlockedAt { get; set; }
        public string? BlockedByAdminName { get; set; }
        public string? BlockReason { get; set; }
        public bool IsSuspended { get; set; }
        public DateTime? SuspendedAt { get; set; }
        public DateTime? SuspensionEndDate { get; set; }
        public string? SuspendedByAdminName { get; set; }
        public string? SuspensionReason { get; set; }
    }

    public class BlockUserRequest
    {
        public int UserId { get; set; }
        public string Reason { get; set; } = string.Empty;
    }

    public class SuspendUserRequest
    {
        public int UserId { get; set; }
        public DateTime SuspensionEndDate { get; set; }
        public string Reason { get; set; } = string.Empty;
    }

    public class UnblockUserRequest
    {
        public int UserId { get; set; }
    }

    public class UnsuspendUserRequest
    {
        public int UserId { get; set; }
    }
}
