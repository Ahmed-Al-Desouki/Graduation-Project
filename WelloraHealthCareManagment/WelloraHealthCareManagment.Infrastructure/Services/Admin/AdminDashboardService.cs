// Infrastructure/Services/Admin/AdminDashboardService.cs

using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories;

namespace WelloraHealthCareManagment.Infrastructure.Services.Admin;

public class AdminDashboardService : IAdminDashboardService
{
    private readonly IUserStatusRepository _userStatusRepository;
    private readonly IDoctorVerificationRepository _verificationRepository;
    private readonly ITicketRepository _ticketRepository;
    private readonly IAdminActionLogRepository _auditRepository;
    private readonly ILogger<AdminDashboardService> _logger;

    public AdminDashboardService(
        IUserStatusRepository userStatusRepository,
        IDoctorVerificationRepository verificationRepository,
        ITicketRepository ticketRepository,
        IAdminActionLogRepository auditRepository,
        ILogger<AdminDashboardService> logger)
    {
        _userStatusRepository = userStatusRepository;
        _verificationRepository = verificationRepository;
        _ticketRepository = ticketRepository;
        _auditRepository = auditRepository;
        _logger = logger;
    }

    public async Task<ServiceResult<AdminDashboardDto>> GetDashboardOverviewAsync(CancellationToken ct = default)
    {
        try
        {
            var userStats = await GetUserStatisticsAsync(ct);
            var doctorStats = await GetDoctorStatisticsAsync(ct);
            var ticketStats = await GetTicketStatisticsAsync(ct);
            var verificationStats = await GetVerificationStatisticsAsync(ct);
            var recentActivity = await GetRecentActivityAsync(ct);

            // التحقق من وجود أخطاء في أي قسم
            if (!userStats.IsSuccess)
                return ServiceResult<AdminDashboardDto>.Failure(userStats.Error ?? "Failed to get user statistics");

            if (!doctorStats.IsSuccess)
                return ServiceResult<AdminDashboardDto>.Failure(doctorStats.Error ?? "Failed to get doctor statistics");

            if (!ticketStats.IsSuccess)
                return ServiceResult<AdminDashboardDto>.Failure(ticketStats.Error ?? "Failed to get ticket statistics");

            if (!verificationStats.IsSuccess)
                return ServiceResult<AdminDashboardDto>.Failure(verificationStats.Error ?? "Failed to get verification statistics");

            if (!recentActivity.IsSuccess)
                return ServiceResult<AdminDashboardDto>.Failure(recentActivity.Error ?? "Failed to get recent activity");

            var dashboard = new AdminDashboardDto
            {
                UserStatistics = userStats.Data!,
                DoctorStatistics = doctorStats.Data!,
                TicketStatistics = ticketStats.Data!,
                VerificationStatistics = verificationStats.Data!,
                RecentActivity = recentActivity.Data!
            };

            return ServiceResult<AdminDashboardDto>.Success(dashboard);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting dashboard overview");
            return ServiceResult<AdminDashboardDto>.Failure("Failed to get dashboard overview");
        }
    }

    public async Task<ServiceResult<UserStatisticsDto>> GetUserStatisticsAsync(CancellationToken ct = default)
    {
        try
        {
            var totalUsers = await _userStatusRepository.GetTotalUsersCountAsync(ct);
            var totalDoctors = await _userStatusRepository.GetTotalDoctorsCountAsync(ct);
            var totalPatients = await _userStatusRepository.GetTotalPatientsCountAsync(ct);
            var blockedUsers = await _userStatusRepository.CountBlockedUsersAsync(ct);
            var suspendedUsers = await _userStatusRepository.CountSuspendedUsersAsync(ct);
            var activeUsers = await _userStatusRepository.CountActiveUsersAsync(ct);

            var startOfMonth = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
            var newUsersThisMonth = await _userStatusRepository.GetNewUsersThisMonthAsync(startOfMonth, ct);

            var stats = new UserStatisticsDto
            {
                TotalUsers = totalUsers,
                TotalDoctors = totalDoctors,
                TotalPatients = totalPatients,
                BlockedUsers = blockedUsers,
                SuspendedUsers = suspendedUsers,
                ActiveUsers = activeUsers,
                NewUsersThisMonth = newUsersThisMonth
            };

            return ServiceResult<UserStatisticsDto>.Success(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting user statistics");
            return ServiceResult<UserStatisticsDto>.Failure("Failed to get user statistics");
        }
    }

    public async Task<ServiceResult<DoctorStatisticsDto>> GetDoctorStatisticsAsync(CancellationToken ct = default)
    {
        try
        {
            var totalDoctors = await _userStatusRepository.GetTotalDoctorsCountAsync(ct);
            var verifiedDoctors = await _verificationRepository.CountVerifiedDoctorsAsync(ct);
            var pendingVerification = await _verificationRepository.CountPendingVerificationsAsync(ct);

            var statusCounts = await _verificationRepository.GetStatusCountsAsync(ct);
            var rejectedDoctors = statusCounts.GetValueOrDefault(VerificationStatus.Rejected, 0);

            var averageRating = await _verificationRepository.GetAverageDoctorRatingAsync(ct) ?? 0;
            var totalReviews = await _verificationRepository.GetTotalReviewsCountAsync(ct);

            var stats = new DoctorStatisticsDto
            {
                TotalDoctors = totalDoctors,
                VerifiedDoctors = verifiedDoctors,
                PendingVerification = pendingVerification,
                RejectedDoctors = rejectedDoctors,
                AverageRating = Math.Round(averageRating, 2),
                TotalReviews = totalReviews
            };

            return ServiceResult<DoctorStatisticsDto>.Success(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting doctor statistics");
            return ServiceResult<DoctorStatisticsDto>.Failure("Failed to get doctor statistics");
        }
    }

    public async Task<ServiceResult<TicketStatisticsDto>> GetTicketStatisticsAsync(CancellationToken ct = default)
    {
        try
        {
            var statusCounts = await _ticketRepository.GetStatusCountsAsync(ct);
            var categoryCounts = await _ticketRepository.GetCategoryCountsAsync(ct);

            var openTickets = await _ticketRepository.GetOpenTicketsCountAsync(ct);
            var inProgress = await _ticketRepository.GetInProgressTicketsCountAsync(ct);
            var resolved = await _ticketRepository.GetResolvedTicketsCountAsync(ct);
            var closed = statusCounts.GetValueOrDefault(TicketStatus.Closed, 0);
            var urgent = await _ticketRepository.GetUrgentTicketsCountAsync(ct);

            var stats = new TicketStatisticsDto
            {
                TotalTickets = statusCounts.Values.Sum(),
                OpenTickets = openTickets,
                InProgressTickets = inProgress,
                ResolvedTickets = resolved,
                ClosedTickets = closed,
                UrgentTickets = urgent,
                TicketsByCategory = categoryCounts,
                TicketsByStatus = statusCounts
            };

            return ServiceResult<TicketStatisticsDto>.Success(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting ticket statistics");
            return ServiceResult<TicketStatisticsDto>.Failure("Failed to get ticket statistics");
        }
    }

    public async Task<ServiceResult<VerificationStatisticsDto>> GetVerificationStatisticsAsync(CancellationToken ct = default)
    {
        try
        {
            var statusCounts = await _verificationRepository.GetStatusCountsAsync(ct);
            var startOfMonth = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
            var stats = new VerificationStatisticsDto
            {
                TotalVerifications = statusCounts.Values.Sum(),
                PendingVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Pending, 0),
                ApprovedVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Approved, 0),
                RejectedVerifications = statusCounts.GetValueOrDefault(VerificationStatus.Rejected, 0),
                VerificationsByStatus = statusCounts,
                ApprovedThisMonth = await _verificationRepository.CountApprovedThisMonthAsync(startOfMonth, ct),
                RejectedThisMonth = await _verificationRepository.CountRejectedThisMonthAsync(startOfMonth, ct)
            };

            return ServiceResult<VerificationStatisticsDto>.Success(stats);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting verification statistics");
            return ServiceResult<VerificationStatisticsDto>.Failure("Failed to get verification statistics");
        }
    }

    public async Task<ServiceResult<RecentActivityDto>> GetRecentActivityAsync(CancellationToken ct = default)
    {
        try
        {
            var recentActions = await _auditRepository.GetRecentAdminActionsAsync(10, ct);
            var recentTickets = await _ticketRepository.GetRecentTicketsAsync(5, ct);
            var pendingVerifications = await _verificationRepository.GetRecentPendingVerificationsAsync(5, ct);

            var activity = new RecentActivityDto
            {
                RecentActions = recentActions.Select(log => new RecentActionDto
                {
                    AdminName = log.Admin?.FullName ?? "Unknown",
                    ActionType = log.ActionType.ToString(),
                    TargetEntity = log.TargetEntity,
                    Timestamp = log.CreatedAt
                }).ToList(),

                RecentTickets = recentTickets,
                PendingVerifications = pendingVerifications
            };

            return ServiceResult<RecentActivityDto>.Success(activity);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting recent activity");
            return ServiceResult<RecentActivityDto>.Failure("Failed to get recent activity");
        }
    }
}