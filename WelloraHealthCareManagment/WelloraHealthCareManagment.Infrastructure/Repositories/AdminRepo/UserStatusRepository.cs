// Infrastructure/Repositories/UserStatusRepository.cs
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class UserStatusRepository : IUserStatusRepository
    {
        private readonly HealthCarePlusContext _context;

        public UserStatusRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        // ... كل الدوال القديمة تبقى كما هي (لم أغيرها) ...

        public async Task<UserStatus?> GetByUserIdAsync(int userId, CancellationToken ct = default)
        {
            return await _context.UserStatuses
                .Include(us => us.User)
                .Include(us => us.BlockedByAdmin)
                .Include(us => us.SuspendedByAdmin)
                .FirstOrDefaultAsync(us => us.UserId == userId, ct);
        }

        public async Task<UserStatus?> GetEffectiveByUserIdAsync(int userId, CancellationToken ct = default)
        {
            var status = await GetByUserIdAsync(userId, ct);
            if (status == null)
                return null;

            if (status.IsSuspended &&
                status.SuspensionEndDate.HasValue &&
                status.SuspensionEndDate.Value <= DateTime.UtcNow)
            {
                status.IsSuspended = false;
                status.SuspendedAt = null;
                status.SuspensionEndDate = null;
                status.SuspendedByAdminId = null;
                status.SuspensionReason = null;
                status.UpdatedAt = DateTime.UtcNow;

                await _context.SaveChangesAsync(ct);
            }

            return status;
        }

        public async Task<UserStatus> CreateAsync(UserStatus userStatus, CancellationToken ct = default)
        {
            await _context.UserStatuses.AddAsync(userStatus, ct);
            await _context.SaveChangesAsync(ct);
            return userStatus;
        }

        public async Task UpdateAsync(UserStatus userStatus, CancellationToken ct = default)
        {
            _context.UserStatuses.Update(userStatus);
            await _context.SaveChangesAsync(ct);
        }

        public async Task<bool> ExistsAsync(int userId, CancellationToken ct = default)
        {
            return await _context.UserStatuses.AnyAsync(us => us.UserId == userId, ct);
        }

        public async Task<bool> IsBlockedAsync(int userId, CancellationToken ct = default)
        {
            var status = await GetEffectiveByUserIdAsync(userId, ct);
            return status?.IsBlocked ?? false;
        }

        public async Task<bool> IsSuspendedAsync(int userId, CancellationToken ct = default)
        {
            var status = await GetEffectiveByUserIdAsync(userId, ct);
            return status?.IsSuspended ?? false;
        }

        public async Task<bool> IsActiveAsync(int userId, CancellationToken ct = default)
        {
            var status = await GetEffectiveByUserIdAsync(userId, ct);
            if (status == null) return true;

            if (status.IsBlocked) return false;
            if (status.IsSuspended) return false;
            return true;
        }

        public async Task<List<UserStatus>> GetBlockedUsersAsync(int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.UserStatuses
                .Include(us => us.User)
                .Include(us => us.BlockedByAdmin)
                .Where(us => us.IsBlocked)
                .OrderByDescending(us => us.BlockedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<List<UserStatus>> GetSuspendedUsersAsync(int page, int pageSize, CancellationToken ct = default)
        {
            return await _context.UserStatuses
                .Include(us => us.User)
                .Include(us => us.SuspendedByAdmin)
                .Where(us => us.IsSuspended &&
                    (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow))
                .OrderByDescending(us => us.SuspendedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountBlockedUsersAsync(CancellationToken ct = default)
        {
            return await _context.UserStatuses.CountAsync(us => us.IsBlocked, ct);
        }

        public async Task<int> CountSuspendedUsersAsync(CancellationToken ct = default)
        {
            return await _context.UserStatuses
                .CountAsync(us => us.IsSuspended &&
                    (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow), ct);
        }

        public async Task<List<int>> GetExpiredSuspensionsAsync(CancellationToken ct = default)
        {
            return await _context.UserStatuses
                .Where(us => us.IsSuspended &&
                    us.SuspensionEndDate.HasValue &&
                    us.SuspensionEndDate.Value <= DateTime.UtcNow)
                .Select(us => us.UserId)
                .ToListAsync(ct);
        }

        public async Task UnsuspendExpiredAsync(List<int> userIds, CancellationToken ct = default)
        {
            var statuses = await _context.UserStatuses
                .Where(us => userIds.Contains(us.UserId))
                .ToListAsync(ct);

            foreach (var status in statuses)
            {
                status.IsSuspended = false;
                status.SuspensionEndDate = null;
                status.UpdatedAt = DateTime.UtcNow;
            }
            await _context.SaveChangesAsync(ct);
        }


        // الدوال للـ Dashboard

        public async Task<int> GetTotalUsersCountAsync(CancellationToken ct = default)
        {
            return await _context.Users.CountAsync(ct);
        }

        public async Task<int> GetTotalDoctorsCountAsync(CancellationToken ct = default)
        {
            return await _context.Doctors.CountAsync(ct);
        }

        public async Task<int> GetTotalPatientsCountAsync(CancellationToken ct = default)
        {
            return await _context.Patients.CountAsync(ct);
        }

        public async Task<int> CountActiveUsersAsync(CancellationToken ct = default)
        {
            var totalUsers = await GetTotalUsersCountAsync(ct);
            var blocked = await CountBlockedUsersAsync(ct);
            var suspended = await CountSuspendedUsersAsync(ct);
            return totalUsers - blocked - suspended;
        }

        public async Task<int> GetNewUsersThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default)
        {
            return await _context.Users
                .CountAsync(u => u.CreatedAt >= startOfMonth, ct);
        }

        public async Task<int> GetNewUsersCountAsync(DateTime startDate, DateTime endDate, CancellationToken ct = default)
        {
            return await _context.Users
                .CountAsync(u => u.CreatedAt >= startDate && u.CreatedAt < endDate, ct);
        }

        public async Task<List<ApplicationUser>> GetAllUsersWithDoctorAsync(CancellationToken ct = default)
        {
            return await _context.Users
                .Include(u => u.Doctor)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<Dictionary<int, UserStatus>> GetUserStatusesByUserIdsAsync(
            List<int> userIds, CancellationToken ct = default)
        {
            if (userIds == null || userIds.Count == 0)
                return new Dictionary<int, UserStatus>();

            return await _context.UserStatuses
                .Where(us => userIds.Contains(us.UserId))
                .ToDictionaryAsync(us => us.UserId, ct);
        }
    }
}

