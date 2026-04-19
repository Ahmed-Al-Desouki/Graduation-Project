// Application/Interfaces/AppRepositories/IUserStatusRepository.cs
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IUserStatusRepository
    {
        Task<UserStatus?> GetByUserIdAsync(int userId, CancellationToken ct = default);
        Task<UserStatus?> GetEffectiveByUserIdAsync(int userId, CancellationToken ct = default);
        Task<UserStatus> CreateAsync(UserStatus userStatus, CancellationToken ct = default);
        Task UpdateAsync(UserStatus userStatus, CancellationToken ct = default);
        Task<bool> ExistsAsync(int userId, CancellationToken ct = default);

        // Check status methods
        Task<bool> IsBlockedAsync(int userId, CancellationToken ct = default);
        Task<bool> IsSuspendedAsync(int userId, CancellationToken ct = default);
        Task<bool> IsActiveAsync(int userId, CancellationToken ct = default); // Not blocked AND not suspended

        // Admin queries
        Task<List<UserStatus>> GetBlockedUsersAsync(int page, int pageSize, CancellationToken ct = default);
        Task<List<UserStatus>> GetSuspendedUsersAsync(int page, int pageSize, CancellationToken ct = default);
        Task<int> CountBlockedUsersAsync(CancellationToken ct = default);
        Task<int> CountSuspendedUsersAsync(CancellationToken ct = default);

        // Cleanup expired suspensions
        Task<List<int>> GetExpiredSuspensionsAsync(CancellationToken ct = default);
        Task UnsuspendExpiredAsync(List<int> userIds, CancellationToken ct = default);
        
        // دول الجداد 
        Task<int> GetTotalUsersCountAsync(CancellationToken ct = default);
        Task<int> GetTotalDoctorsCountAsync(CancellationToken ct = default);
        Task<int> GetTotalPatientsCountAsync(CancellationToken ct = default);
        Task<int> CountActiveUsersAsync(CancellationToken ct = default);
        Task<int> GetNewUsersThisMonthAsync(DateTime startOfMonth, CancellationToken ct = default);
        Task<int> GetNewUsersCountAsync(DateTime startDate, DateTime endDate, CancellationToken ct = default);
        Task<List<ApplicationUser>> GetAllUsersWithDoctorAsync(CancellationToken ct = default);
        Task<Dictionary<int, UserStatus>> GetUserStatusesByUserIdsAsync(
        List<int> userIds, CancellationToken ct = default);
    }
}
