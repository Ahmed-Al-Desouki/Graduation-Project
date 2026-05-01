using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IUserRepository
    {
        // Basic User Operations
        Task<ApplicationUser?> GetByEmailAsync(string email);
        Task<ApplicationUser?> GetByIdAsync(int userId);
        Task<IdentityResult> CreateUserAsync(ApplicationUser user, string password);
        Task<IdentityResult> AddToRoleAsync(ApplicationUser user, string role);
        Task<IdentityResult> UpdateUserAsync(ApplicationUser user);
        Task<bool> CheckPasswordAsync(ApplicationUser user, string password);
        Task<IList<string>> GetRolesAsync(ApplicationUser user);

        // MFA Operations
        Task<IdentityResult> AddClaimAsync(ApplicationUser user, Claim claim);
        Task<bool> IsTwoFactorEnabledAsync(int userId);
        Task<IdentityResult> SetTwoFactorEnabledAsync(int userId, bool enabled);

        // Password Reset 
        Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user);
        Task<IdentityResult> ResetPasswordAsync(ApplicationUser user, string token, string newPassword);
        Task<IdentityResult> ChangePasswordAsync(ApplicationUser user, string currentPassword, string newPassword);
        Task<bool> IsEmailConfirmedAsync(ApplicationUser user);

        Task<List<ApplicationUser>> GetAllUsersWithDoctorAsync(CancellationToken ct = default);

        Task<int> CountUsersFilteredAsync(
            string? role = null,
            bool? isBlocked = null,
            bool? isSuspended = null,
            bool? isVerified = null,
            string? specialization = null,
            double? minRating = null,
            DateTime? registeredAfter = null,
            DateTime? registeredBefore = null,
            List<int>? userIds = null,
            CancellationToken ct = default);

        Task<Dictionary<int, UserStatus>> GetUserStatusesByUserIdsAsync(
            List<int> userIds, CancellationToken ct = default);

        Task<Dictionary<int, int>> GetDoctorReviewCountsAsync(
            List<int> doctorIds, CancellationToken ct = default);

        Task<List<ApplicationUser>> SearchUsersFilteredAsync(
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
            CancellationToken ct = default);

        Task<List<int>> GetUserIdsByNameOrEmailAsync(List<string> namesOrEmails, CancellationToken ct = default);
        Task<int> GetDoctorReviewCountAsync(int doctorId, CancellationToken ct = default);
        Task<ApplicationUser?> GetByIdWithDoctorAsync(int userId, CancellationToken ct = default);
        Task<List<int>> GetUserIdsByRoleAsync(string role, CancellationToken ct = default);
        Task<string?> GetPreferredLanguageAsync(int userId, CancellationToken ct = default);
        Task<string?> GetPreferredLanguageByEmailAsync(string email, CancellationToken ct = default);
        Task<Dictionary<int, string>> GetPreferredLanguagesAsync(IEnumerable<int> userIds, CancellationToken ct = default);

        // GetAllUsers methods for GetAllUsersAsync
        Task<List<ApplicationUser>> GetDoctorsFilteredAsync(
            string? searchTerm,
            bool? onlyVerified,
            bool? onlyActive,
            int page,
            int pageSize,
            CancellationToken ct = default);

        Task<int> CountDoctorsFilteredAsync(
            string? searchTerm,
            bool? onlyVerified,
            bool? onlyActive,
            CancellationToken ct = default);

        Task<List<ApplicationUser>> GetPatientsFilteredAsync(
            string? searchTerm,
            bool? onlyActive,
            int page,
            int pageSize,
            CancellationToken ct = default);

        Task<int> CountPatientsFilteredAsync(
            string? searchTerm,
            bool? onlyActive,
            CancellationToken ct = default);
    }
}
