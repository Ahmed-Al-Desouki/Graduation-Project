using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class AdminAuditLogDto
    {
        public Guid Id { get; set; }
        public int AdminId { get; set; }
        public string AdminName { get; set; } = string.Empty;
        public AdminActionType ActionType { get; set; }
        public string TargetEntity { get; set; } = string.Empty;
        public string TargetId { get; set; } = string.Empty;
        public string? Details { get; set; }
        public string? IpAddress { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class AuditLogListResponse
    {
        public List<AdminAuditLogDto> Logs { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
    }

    public class AuditLogStatisticsDto
    {
        public int TotalActions { get; set; }
        public Dictionary<AdminActionType, int> ActionsByType { get; set; } = new();
        public List<(int AdminId, string AdminName, int ActionCount)> MostActiveAdmins { get; set; } = new();
    }
}
