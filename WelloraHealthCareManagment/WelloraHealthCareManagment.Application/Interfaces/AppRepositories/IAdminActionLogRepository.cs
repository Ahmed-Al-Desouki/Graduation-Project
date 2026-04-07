// Application/Interfaces/AppRepositories/IAdminActionLogRepository.cs
using WelloraHealthCareManagment.Domain.Entities.AdminLogs;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IAdminActionLogRepository
    {
        Task<AdminActionLog> CreateAsync(AdminActionLog log, CancellationToken ct = default);
        Task<List<AdminActionLog>> CreateBulkAsync(List<AdminActionLog> logs, CancellationToken ct = default);

        // Query logs
        Task<List<AdminActionLog>> GetByAdminIdAsync(
            int adminId,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        Task<List<AdminActionLog>> GetByActionTypeAsync(
            AdminActionType actionType,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        Task<List<AdminActionLog>> GetByTargetAsync(
            string targetEntity,
            string targetId,
            CancellationToken ct = default);

        // Advanced filtering
        Task<List<AdminActionLog>> GetAllAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default);

        Task<int> CountAllAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);

        // Statistics
        Task<Dictionary<AdminActionType, int>> GetActionTypeCountsAsync(
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);

        Task<List<(int AdminId, string AdminName, int ActionCount)>> GetMostActiveAdminsAsync(
            int topCount = 10,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default);

        Task<List<AdminActionLog>> GetRecentAdminActionsAsync(int count = 10, CancellationToken ct = default);
    }
}