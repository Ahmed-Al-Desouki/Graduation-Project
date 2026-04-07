// Application/Interfaces/Services/IAdminDashboardService.cs
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IAdminDashboardService
    {
        // Get complete dashboard overview
        Task<ServiceResult<AdminDashboardDto>> GetDashboardOverviewAsync(CancellationToken ct = default);

        // Individual statistics
        Task<ServiceResult<UserStatisticsDto>> GetUserStatisticsAsync(CancellationToken ct = default);
        Task<ServiceResult<DoctorStatisticsDto>> GetDoctorStatisticsAsync(CancellationToken ct = default);
        Task<ServiceResult<TicketStatisticsDto>> GetTicketStatisticsAsync(CancellationToken ct = default);
        Task<ServiceResult<VerificationStatisticsDto>> GetVerificationStatisticsAsync(CancellationToken ct = default);
        Task<ServiceResult<RecentActivityDto>> GetRecentActivityAsync(CancellationToken ct = default);
    }
}