// Application/Interfaces/Services/IUserManagementService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IUserManagementService
    {
        // Block/Unblock
        Task<ServiceResult> BlockUserAsync(BlockUserRequest request, int adminId, string? ipAddress = null, CancellationToken ct = default);
        Task<ServiceResult> UnblockUserAsync(UnblockUserRequest request, int adminId, string? ipAddress = null, CancellationToken ct = default);

        // Suspend/Unsuspend
        Task<ServiceResult> SuspendUserAsync(SuspendUserRequest request, int adminId, string? ipAddress = null, CancellationToken ct = default);
        Task<ServiceResult> UnsuspendUserAsync(UnsuspendUserRequest request, int adminId, string? ipAddress = null, CancellationToken ct = default);

        // Get user status
        Task<ServiceResult<UserStatusDto>> GetUserStatusAsync(int userId, CancellationToken ct = default);

        // Check status (for middleware)
        Task<bool> IsUserActiveAsync(int userId, CancellationToken ct = default);
        Task<ServiceResult<string>> GetInactiveReasonAsync(int userId, CancellationToken ct = default);

        // Admin queries
        Task<ServiceResult<List<UserStatusDto>>> GetBlockedUsersAsync(int page, int pageSize, CancellationToken ct = default);
        Task<ServiceResult<List<UserStatusDto>>> GetSuspendedUsersAsync(int page, int pageSize, CancellationToken ct = default);

        // Background job: Auto-unsuspend expired suspensions
        Task ProcessExpiredSuspensionsAsync(CancellationToken ct = default);
    }
}