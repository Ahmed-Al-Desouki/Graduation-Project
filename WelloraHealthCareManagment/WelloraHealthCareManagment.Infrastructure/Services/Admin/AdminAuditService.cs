// Infrastructure/Services/AdminAuditService.cs
using AutoMapper;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.AdminLogs;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin
{
    public class AdminAuditService : IAdminAuditService
    {
        private readonly IAdminActionLogRepository _auditRepository;
        private readonly IMapper _mapper;
        private readonly ILogger<AdminAuditService> _logger;

        public AdminAuditService(
            IAdminActionLogRepository auditRepository,
            IMapper mapper,
            ILogger<AdminAuditService> logger)
        {
            _auditRepository = auditRepository;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task LogActionAsync(
            int adminId,
            AdminActionType actionType,
            string targetEntity,
            string targetId,
            object? details = null,
            string? ipAddress = null,
            string? userAgent = null,
            CancellationToken ct = default)
        {
            try
            {
                var log = new AdminActionLog
                {
                    AdminId = adminId,
                    ActionType = actionType,
                    TargetEntity = targetEntity,
                    TargetId = targetId,
                    Details = details != null ? JsonSerializer.Serialize(details) : null,
                    IpAddress = ipAddress,
                    UserAgent = userAgent,
                    CreatedAt = DateTime.UtcNow
                };

                await _auditRepository.CreateAsync(log, ct);

                _logger.LogInformation(
                    "Admin action logged: Admin {AdminId} performed {ActionType} on {TargetEntity} {TargetId}",
                    adminId, actionType, targetEntity, targetId);
            }
            catch (Exception ex)
            {
                // Don't fail the main operation if audit logging fails
                _logger.LogError(ex,
                    "Error logging admin action: {ActionType} by admin {AdminId}",
                    actionType, adminId);
            }
        }

        public async Task<ServiceResult<AuditLogListResponse>> GetLogsAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            try
            {
                var logs = await _auditRepository.GetAllAsync(
                    adminId, actionType, targetEntity, fromDate, toDate, page, pageSize, ct);

                var totalCount = await _auditRepository.CountAllAsync(
                    adminId, actionType, targetEntity, fromDate, toDate, ct);

                var dtos = _mapper.Map<List<AdminAuditLogDto>>(logs);

                var response = new AuditLogListResponse
                {
                    Logs = dtos,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<AuditLogListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting audit logs");
                return ServiceResult<AuditLogListResponse>.Failure("Failed to get audit logs");
            }
        }

        public async Task<ServiceResult<AuditLogListResponse>> GetLogsByAdminAsync(
            int adminId,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            try
            {
                var logs = await _auditRepository.GetByAdminIdAsync(adminId, page, pageSize, ct);

                // Get total count using GetAllAsync with adminId filter
                var totalCount = await _auditRepository.CountAllAsync(
                    adminId: adminId, ct: ct);

                var dtos = _mapper.Map<List<AdminAuditLogDto>>(logs);

                var response = new AuditLogListResponse
                {
                    Logs = dtos,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize
                };

                return ServiceResult<AuditLogListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting logs for admin {AdminId}", adminId);
                return ServiceResult<AuditLogListResponse>.Failure("Failed to get admin logs");
            }
        }

        public async Task<ServiceResult<AuditLogListResponse>> GetLogsByTargetAsync(
            string targetEntity,
            string targetId,
            CancellationToken ct = default)
        {
            try
            {
                var logs = await _auditRepository.GetByTargetAsync(targetEntity, targetId, ct);
                var dtos = _mapper.Map<List<AdminAuditLogDto>>(logs);

                var response = new AuditLogListResponse
                {
                    Logs = dtos,
                    TotalCount = logs.Count,
                    Page = 1,
                    PageSize = logs.Count
                };

                return ServiceResult<AuditLogListResponse>.Success(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error getting logs for target {TargetEntity} {TargetId}",
                    targetEntity, targetId);
                return ServiceResult<AuditLogListResponse>.Failure("Failed to get target logs");
            }
        }

        public async Task<ServiceResult<AuditLogStatisticsDto>> GetStatisticsAsync(
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            try
            {
                var actionTypeCounts = await _auditRepository.GetActionTypeCountsAsync(
                    fromDate, toDate, ct);

                var mostActiveAdmins = await _auditRepository.GetMostActiveAdminsAsync(
                    10, fromDate, toDate, ct);

                var stats = new AuditLogStatisticsDto
                {
                    TotalActions = actionTypeCounts.Values.Sum(),
                    ActionsByType = actionTypeCounts,
                    MostActiveAdmins = mostActiveAdmins
                };

                return ServiceResult<AuditLogStatisticsDto>.Success(stats);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting audit statistics");
                return ServiceResult<AuditLogStatisticsDto>.Failure("Failed to get statistics");
            }
        }
    }
}