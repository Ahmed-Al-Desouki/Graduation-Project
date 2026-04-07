// Infrastructure/Repositories/AdminActionLogRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.AdminLogs;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class AdminActionLogRepository : IAdminActionLogRepository
    {
        private readonly HealthCarePlusContext _context;

        public AdminActionLogRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<AdminActionLog> CreateAsync(AdminActionLog log, CancellationToken ct = default)
        {
            await _context.AdminActionLogs.AddAsync(log, ct);
            await _context.SaveChangesAsync(ct);
            return log;
        }

        public async Task<List<AdminActionLog>> CreateBulkAsync(List<AdminActionLog> logs, CancellationToken ct = default)
        {
            await _context.AdminActionLogs.AddRangeAsync(logs, ct);
            await _context.SaveChangesAsync(ct);
            return logs;
        }

        public async Task<List<AdminActionLog>> GetByAdminIdAsync(
            int adminId,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            return await _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .Where(aal => aal.AdminId == adminId)
                .OrderByDescending(aal => aal.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<List<AdminActionLog>> GetByActionTypeAsync(
            AdminActionType actionType,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            return await _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .Where(aal => aal.ActionType == actionType)
                .OrderByDescending(aal => aal.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<List<AdminActionLog>> GetByTargetAsync(
            string targetEntity,
            string targetId,
            CancellationToken ct = default)
        {
            return await _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .Where(aal => aal.TargetEntity == targetEntity && aal.TargetId == targetId)
                .OrderByDescending(aal => aal.CreatedAt)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<List<AdminActionLog>> GetAllAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            int page = 1,
            int pageSize = 20,
            CancellationToken ct = default)
        {
            var query = _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .AsQueryable();

            if (adminId.HasValue)
                query = query.Where(aal => aal.AdminId == adminId.Value);

            if (actionType.HasValue)
                query = query.Where(aal => aal.ActionType == actionType.Value);

            if (!string.IsNullOrWhiteSpace(targetEntity))
                query = query.Where(aal => aal.TargetEntity == targetEntity);

            if (fromDate.HasValue)
                query = query.Where(aal => aal.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(aal => aal.CreatedAt <= toDate.Value);

            return await query
                .OrderByDescending(aal => aal.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountAllAsync(
            int? adminId = null,
            AdminActionType? actionType = null,
            string? targetEntity = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.AdminActionLogs.AsQueryable();

            if (adminId.HasValue)
                query = query.Where(aal => aal.AdminId == adminId.Value);

            if (actionType.HasValue)
                query = query.Where(aal => aal.ActionType == actionType.Value);

            if (!string.IsNullOrWhiteSpace(targetEntity))
                query = query.Where(aal => aal.TargetEntity == targetEntity);

            if (fromDate.HasValue)
                query = query.Where(aal => aal.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(aal => aal.CreatedAt <= toDate.Value);

            return await query.CountAsync(ct);
        }

        public async Task<Dictionary<AdminActionType, int>> GetActionTypeCountsAsync(
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.AdminActionLogs.AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(aal => aal.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(aal => aal.CreatedAt <= toDate.Value);

            return await query
                .GroupBy(aal => aal.ActionType)
                .Select(g => new { ActionType = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.ActionType, x => x.Count, ct);
        }

        public async Task<List<(int AdminId, string AdminName, int ActionCount)>> GetMostActiveAdminsAsync(
            int topCount = 10,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken ct = default)
        {
            var query = _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .AsQueryable();

            if (fromDate.HasValue)
                query = query.Where(aal => aal.CreatedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(aal => aal.CreatedAt <= toDate.Value);

            return await query
                .GroupBy(aal => new { aal.AdminId, aal.Admin.FullName })
                .Select(g => new
                {
                    AdminId = g.Key.AdminId,
                    AdminName = g.Key.FullName,
                    ActionCount = g.Count()
                })
                .OrderByDescending(x => x.ActionCount)
                .Take(topCount)
                .Select(x => ValueTuple.Create(x.AdminId, x.AdminName, x.ActionCount))
                .ToListAsync(ct);
        }

        public async Task<List<AdminActionLog>> GetRecentAdminActionsAsync(int count = 10, CancellationToken ct = default)
        {
            return await _context.AdminActionLogs
                .Include(aal => aal.Admin)
                .OrderByDescending(aal => aal.CreatedAt)
                .Take(count)
                .AsNoTracking()
                .ToListAsync(ct);
        }
    }
}