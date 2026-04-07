// Application/Interfaces/Services/IUserSearchService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IUserSearchService
    {
        // Advanced user search with Trie + Database filtering
        Task<ServiceResult<UserSearchResponse>> SearchUsersAsync(
            UserSearchRequest request,
            CancellationToken ct = default);

        // Get user details for admin
        Task<ServiceResult<UserSearchDto>> GetUserDetailsAsync(
            int userId,
            CancellationToken ct = default);

        // Rebuild search index (background job or admin action)
        Task RebuildIndexAsync(CancellationToken ct = default);
    }
}