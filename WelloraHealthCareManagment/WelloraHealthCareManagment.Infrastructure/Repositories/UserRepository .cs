// Infrastructure/Repositories/UserRepository.cs
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly HealthCarePlusContext _context;

        public UserRepository(UserManager<ApplicationUser> userManager, HealthCarePlusContext context)
        {
            _userManager = userManager;
            _context = context;
        }

        public async Task<ApplicationUser?> GetByEmailAsync(string email)
            => await _userManager.FindByEmailAsync(email);

        public async Task<ApplicationUser?> GetByIdAsync(int userId)
            => await _userManager.FindByIdAsync(userId.ToString());

        public async Task<IdentityResult> CreateUserAsync(ApplicationUser user, string password)
            => await _userManager.CreateAsync(user, password);

        public async Task<IdentityResult> AddToRoleAsync(ApplicationUser user, string role)
            => await _userManager.AddToRoleAsync(user, role);

        public async Task<IdentityResult> UpdateUserAsync(ApplicationUser user)
            => await _userManager.UpdateAsync(user);

        public async Task<bool> CheckPasswordAsync(ApplicationUser user, string password)
            => await _userManager.CheckPasswordAsync(user, password);

        public async Task<IList<string>> GetRolesAsync(ApplicationUser user)
            => await _userManager.GetRolesAsync(user);

        public async Task<IdentityResult> AddClaimAsync(ApplicationUser user, Claim claim)
            => await _userManager.AddClaimAsync(user, claim);

        public async Task<bool> IsTwoFactorEnabledAsync(int userId)
        {
            var user = await GetByIdAsync(userId);
            return user?.TwoFactorEnabled ?? false;
        }

        public async Task<IdentityResult> SetTwoFactorEnabledAsync(int userId, bool enabled)
        {
            var user = await GetByIdAsync(userId);
            if (user == null)
                return IdentityResult.Failed(new IdentityError { Description = "User not found" });
            user.TwoFactorEnabled = enabled;
            return await _userManager.UpdateAsync(user);
        }

        public async Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user)
            => await _userManager.GeneratePasswordResetTokenAsync(user);

        public async Task<IdentityResult> ResetPasswordAsync(ApplicationUser user, string token, string newPassword)
            => await _userManager.ResetPasswordAsync(user, token, newPassword);

        public async Task<IdentityResult> ChangePasswordAsync(ApplicationUser user, string currentPassword, string newPassword)
            => await _userManager.ChangePasswordAsync(user, currentPassword, newPassword);

        public async Task<bool> IsEmailConfirmedAsync(ApplicationUser user)
            => await _userManager.IsEmailConfirmedAsync(user);

        // الدوال  لـ UserSearchService
        public async Task<List<ApplicationUser>> GetAllUsersWithDoctorAsync(CancellationToken ct = default)
        {
            return await _context.Users
                .Include(u => u.Doctor)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<List<ApplicationUser>> SearchUsersFilteredAsync(
            string? role = null,
            bool? isBlocked = null,
            bool? isSuspended = null,
            bool? isVerified = null,
            string? specialization = null,
            double? minRating = null,
            DateTime? registeredAfter = null,
            DateTime? registeredBefore = null,
            string? sortBy = null,
            bool descending = false,
            int page = 1,
            int pageSize = 10,
            List<int>? userIds = null,
            CancellationToken ct = default)
        {
            var query = _context.Users
                .Include(u => u.Doctor)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(role))
                query = query.Where(u => u.Role == role);

            if (userIds != null && userIds.Any())
                query = query.Where(u => userIds.Contains(u.Id));

            if (isBlocked.HasValue || isSuspended.HasValue)
            {
                var statusQuery = _context.UserStatuses.AsQueryable();
                if (isBlocked.HasValue)
                    statusQuery = statusQuery.Where(us => us.IsBlocked == isBlocked.Value);
                if (isSuspended.HasValue)
                {
                    statusQuery = isSuspended.Value
                        ? statusQuery.Where(us => us.IsSuspended &&
                            (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow))
                        : statusQuery.Where(us => !us.IsSuspended ||
                            (us.SuspensionEndDate.HasValue && us.SuspensionEndDate.Value <= DateTime.UtcNow));
                }

                var filteredIds = await statusQuery.Select(us => us.UserId).ToListAsync(ct);
                query = query.Where(u => filteredIds.Contains(u.Id));
            }

            if (role == "Doctor" || isVerified.HasValue || !string.IsNullOrWhiteSpace(specialization) || minRating.HasValue)
            {
                query = query.Where(u => u.Doctor != null);

                if (!string.IsNullOrWhiteSpace(specialization))
                    query = query.Where(u => u.Doctor!.Specialization.ToLower().Contains(specialization.ToLower()));

                if (minRating.HasValue)
                    query = query.Where(u => u.Doctor!.AverageRating >= minRating.Value);

                if (isVerified.HasValue)
                    query = query.Where(u => u.Doctor!.IsActive == isVerified.Value);
            }

            if (registeredAfter.HasValue)
                query = query.Where(u => u.CreatedAt >= registeredAfter.Value);

            if (registeredBefore.HasValue)
                query = query.Where(u => u.CreatedAt <= registeredBefore.Value);

            // Sorting
            query = sortBy?.ToLower() switch
            {
                "createdat" => descending ? query.OrderByDescending(u => u.CreatedAt) : query.OrderBy(u => u.CreatedAt),
                "rating" => descending
                    ? query.OrderByDescending(u => u.Doctor != null ? u.Doctor.AverageRating : 0)
                    : query.OrderBy(u => u.Doctor != null ? u.Doctor.AverageRating : 0),
                "reviewcount" => descending
                    ? query.OrderByDescending(u => u.Reviews.Count(r => !r.IsDeleted))
                    : query.OrderBy(u => u.Reviews.Count(r => !r.IsDeleted)),
                _ => descending ? query.OrderByDescending(u => u.FullName) : query.OrderBy(u => u.FullName)
            };

            return await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountUsersFilteredAsync(
            string? role = null,
            bool? isBlocked = null,
            bool? isSuspended = null,
            bool? isVerified = null,
            string? specialization = null,
            double? minRating = null,
            DateTime? registeredAfter = null,
            DateTime? registeredBefore = null,
            List<int>? userIds = null,
            CancellationToken ct = default)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrWhiteSpace(role))
                query = query.Where(u => u.Role == role);

            if (userIds != null && userIds.Any())
                query = query.Where(u => userIds.Contains(u.Id));

            if (isBlocked.HasValue || isSuspended.HasValue)
            {
                var statusQuery = _context.UserStatuses.AsQueryable();
                if (isBlocked.HasValue) statusQuery = statusQuery.Where(us => us.IsBlocked == isBlocked.Value);
                if (isSuspended.HasValue)
                {
                    statusQuery = isSuspended.Value
                        ? statusQuery.Where(us => us.IsSuspended &&
                            (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow))
                        : statusQuery.Where(us => !us.IsSuspended ||
                            (us.SuspensionEndDate.HasValue && us.SuspensionEndDate.Value <= DateTime.UtcNow));
                }

                var filteredIds = await statusQuery.Select(us => us.UserId).ToListAsync(ct);
                query = query.Where(u => filteredIds.Contains(u.Id));
            }

            if (role == "Doctor" || isVerified.HasValue || !string.IsNullOrWhiteSpace(specialization) || minRating.HasValue)
            {
                query = query.Where(u => u.Doctor != null);

                if (!string.IsNullOrWhiteSpace(specialization))
                    query = query.Where(u => u.Doctor!.Specialization.ToLower().Contains(specialization.ToLower()));

                if (minRating.HasValue)
                    query = query.Where(u => u.Doctor!.AverageRating >= minRating.Value);

                if (isVerified.HasValue)
                    query = query.Where(u => u.Doctor!.IsActive == isVerified.Value);
            }

            if (registeredAfter.HasValue)
                query = query.Where(u => u.CreatedAt >= registeredAfter.Value);

            if (registeredBefore.HasValue)
                query = query.Where(u => u.CreatedAt <= registeredBefore.Value);

            return await query.CountAsync(ct);
        }

        public async Task<Dictionary<int, UserStatus>> GetUserStatusesByUserIdsAsync(List<int> userIds, CancellationToken ct = default)
        {
            if (userIds == null || userIds.Count == 0)
                return new Dictionary<int, UserStatus>();

            return await _context.UserStatuses
                .Where(us => userIds.Contains(us.UserId))
                .ToDictionaryAsync(us => us.UserId, ct);
        }

        public async Task<Dictionary<int, int>> GetDoctorReviewCountsAsync(List<int> doctorIds, CancellationToken ct = default)
        {
            if (doctorIds == null || doctorIds.Count == 0)
                return new Dictionary<int, int>();

            return await _context.Reviews
                .Where(r => r.TargetType == "Doctor" && doctorIds.Contains(r.TargetID) && !r.IsDeleted)
                .GroupBy(r => r.TargetID)
                .Select(g => new { DoctorId = g.Key, Count = g.Count() })
                .ToDictionaryAsync(x => x.DoctorId, x => x.Count, ct);
        }

        public async Task<int> GetDoctorReviewCountAsync(int doctorId, CancellationToken ct = default)
        {
            return await _context.Reviews
                .CountAsync(r => r.TargetType == "Doctor" && r.TargetID == doctorId && !r.IsDeleted, ct);
        }

        public async Task<List<int>> GetUserIdsByNameOrEmailAsync(List<string> namesOrEmails, CancellationToken ct = default)
        {
            if (namesOrEmails == null || namesOrEmails.Count == 0)
                return new List<int>();

            return await _context.Users
                .Where(u => namesOrEmails.Contains(u.FullName.ToLower()) ||
                           (u.Email != null && namesOrEmails.Contains(u.Email.ToLower())))
                .Select(u => u.Id)
                .ToListAsync(ct);
        }
        public async Task<ApplicationUser?> GetByIdWithDoctorAsync(int userId, CancellationToken ct = default)
        {
            return await _context.Users
                .Include(u => u.Doctor)
                .FirstOrDefaultAsync(u => u.Id == userId, ct);
        }

        public async Task<List<int>> GetUserIdsByRoleAsync(string role, CancellationToken ct = default)
        {
            return await _context.Users
                .Where(u => u.Role == role)
                .Select(u => u.Id)
                .ToListAsync(ct);
        }

        public async Task<List<ApplicationUser>> GetDoctorsFilteredAsync(
            string? searchTerm,
            bool? onlyVerified,
            bool? onlyActive,
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            var query = _context.Users
                .Include(u => u.Doctor)
                .Where(u => u.Role == "Doctor" /*&& u.Doctor != null*/)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var s = searchTerm.ToLower();
                query = query.Where(u =>
                    u.FullName.ToLower().Contains(s) ||
                    (u.Email != null && u.Email.ToLower().Contains(s)) ||
                    u.Doctor!.Specialization.ToLower().Contains(s));
            }

            if (onlyVerified.HasValue)
                query = query.Where(u => u.Doctor!.IsActive == onlyVerified.Value);

            if (onlyActive.HasValue)
            {
                var inactiveIds = await _context.UserStatuses
                    .Where(us => us.IsBlocked ||
                        (us.IsSuspended &&
                         (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow)))
                    .Select(us => us.UserId)
                    .ToListAsync(ct);

                query = onlyActive.Value
                    ? query.Where(u => !inactiveIds.Contains(u.Id))
                    : query.Where(u => inactiveIds.Contains(u.Id));
            }

            return await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountDoctorsFilteredAsync(
            string? searchTerm,
            bool? onlyVerified,
            bool? onlyActive,
            CancellationToken ct = default)
        {
            var query = _context.Users
                .Include(u => u.Doctor)
                .Where(u => u.Role == "Doctor" /*&& u.Doctor != null*/)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var s = searchTerm.ToLower();
                query = query.Where(u =>
                    u.FullName.ToLower().Contains(s) ||
                    (u.Email != null && u.Email.ToLower().Contains(s)) ||
                    u.Doctor!.Specialization.ToLower().Contains(s));
            }

            if (onlyVerified.HasValue)
                query = query.Where(u => u.Doctor!.IsActive == onlyVerified.Value);

            if (onlyActive.HasValue)
            {
                var inactiveIds = await _context.UserStatuses
                    .Where(us => us.IsBlocked ||
                        (us.IsSuspended &&
                         (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow)))
                    .Select(us => us.UserId)
                    .ToListAsync(ct);

                query = onlyActive.Value
                    ? query.Where(u => !inactiveIds.Contains(u.Id))
                    : query.Where(u => inactiveIds.Contains(u.Id));
            }

            return await query.CountAsync(ct);
        }

        public async Task<List<ApplicationUser>> GetPatientsFilteredAsync(
            string? searchTerm,
            bool? onlyActive,
            int page,
            int pageSize,
            CancellationToken ct = default)
        {
            var query = _context.Users
                .Include(u => u.Patient)
                .Where(u => u.Role == "Patient" && u.Patient != null)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var s = searchTerm.ToLower();
                query = query.Where(u =>
                    u.FullName.ToLower().Contains(s) ||
                    (u.Email != null && u.Email.ToLower().Contains(s)));
            }

            if (onlyActive.HasValue)
            {
                var inactiveIds = await _context.UserStatuses
                    .Where(us => us.IsBlocked ||
                        (us.IsSuspended &&
                         (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow)))
                    .Select(us => us.UserId)
                    .ToListAsync(ct);

                query = onlyActive.Value
                    ? query.Where(u => !inactiveIds.Contains(u.Id))
                    : query.Where(u => inactiveIds.Contains(u.Id));
            }

            return await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .AsNoTracking()
                .ToListAsync(ct);
        }

        public async Task<int> CountPatientsFilteredAsync(
            string? searchTerm,
            bool? onlyActive,
            CancellationToken ct = default)
        {
            var query = _context.Users
                .Where(u => u.Role == "Patient" && u.Patient != null)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                var s = searchTerm.ToLower();
                query = query.Where(u =>
                    u.FullName.ToLower().Contains(s) ||
                    (u.Email != null && u.Email.ToLower().Contains(s)));
            }

            if (onlyActive.HasValue)
            {
                var inactiveIds = await _context.UserStatuses
                    .Where(us => us.IsBlocked ||
                        (us.IsSuspended &&
                         (!us.SuspensionEndDate.HasValue || us.SuspensionEndDate.Value > DateTime.UtcNow)))
                    .Select(us => us.UserId)
                    .ToListAsync(ct);

                query = onlyActive.Value
                    ? query.Where(u => !inactiveIds.Contains(u.Id))
                    : query.Where(u => inactiveIds.Contains(u.Id));
            }

            return await query.CountAsync(ct);
        }
    }
}

