// Application/Interfaces/Services/IAdminAuditService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IAdminAuditService
    {
        // Log actions (called internally by other services)
        Task LogActionAsync(
            int adminId,
            AdminActionType actionType,
            string targetEntity,
            string targetId,
            object? details = null,
            string? ipAddress = null,
            string? userAgent = null,
            CancellationToken ct = default);

        // Query logs
        Task<ServiceResult<AuditLogListResponse>> GetLogsAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        // Get logs by admin
        Task<ServiceResult<AuditLogListResponse>> GetLogsByAdminAsync(
            int adminId,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        // Get logs by target
        Task<ServiceResult<AuditLogListResponse>> GetLogsByTargetAsync(
            string targetEntity,
            string targetId,
            CancellationToken ct = default);

        // Statistics
        Task<ServiceResult<AuditLogStatisticsDto>> GetStatisticsAsync(
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);
    }
}