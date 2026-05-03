// Infrastructure/Services/Admin/AdminDashboardService.cs

using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories;

namespace WelloraHealthCareManagment.Infrastructure.Services.Admin;

public class AdminDashboardService : IAdminDashboardService
{
    private readonly IUserStatusRepository _userStatusRepository;
    private readonly IDoctorVerificationRepository _verificationRepository;
    private readonly ITicketRepository _ticketRepository;
    private readonly IAdminActionLogRepository _auditRepository;
    private readonly IAppLocalizationService _localizationService;
    private readonly ILogger<AdminDashboardService> _logger;

    public AdminDashboardService(
        IUserStatusRepository userStatusRepository,
        IDoctorVerificationRepository verificationRepository,
        ITicketRepository ticketRepository,
        IAdminActionLogRepository auditRepository,
        IAppLocalizationService localizationService,
        ILogger<AdminDashboardService> logger)
    {
        _userStatusRepository = userStatusRepository;
        _verificationRepository = verificationRepository;
        _ticketRepository = ticketRepository;
        _auditRepository = auditRepository;
        _localizationService = localizationService;
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
            var registrationTrends = await BuildSixMonthRegistrationTrendsAsync(ct);

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
                UserRegistrationTrends = registrationTrends,
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

            var now = DateTime.UtcNow;
            var startOfCurrentMonth = new DateTime(now.Year, now.Month, 1);
            var startOfNextMonth = startOfCurrentMonth.AddMonths(1);
            var startOfPreviousMonth = startOfCurrentMonth.AddMonths(-1);

            var newUsersThisMonth = await _userStatusRepository.GetNewUsersCountAsync(
                startOfCurrentMonth,
                startOfNextMonth,
                ct);
            var newUsersLastMonth = await _userStatusRepository.GetNewUsersCountAsync(
                startOfPreviousMonth,
                startOfCurrentMonth,
                ct);
            var lastSevenDaysTrend = await BuildDailyTrendAsync(
                (start, end, token) => _userStatusRepository.GetNewUsersCountAsync(start, end, token),
                ct);

            var stats = new UserStatisticsDto
            {
                TotalUsers = totalUsers,
                TotalDoctors = totalDoctors,
                TotalPatients = totalPatients,
                BlockedUsers = blockedUsers,
                SuspendedUsers = suspendedUsers,
                ActiveUsers = activeUsers,
                NewUsersThisMonth = newUsersThisMonth,
                NewUsersLastMonth = newUsersLastMonth,
                NewUsersPercentageChange = CalculatePercentageChange(newUsersThisMonth, newUsersLastMonth),
                LastSevenDaysTrend = lastSevenDaysTrend
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
            var pendingVerification = await _verificationRepository.CountPendingDoctorsAsync(ct);
            var doctors = await _verificationRepository.GetAllDoctorsWithVerificationsAsync(ct);
            var rejectedDoctors = doctors.Count(d => DoctorVerificationPolicy.DetermineRequestStatus(d.Verifications) == DoctorVerificationRequestStatus.Rejected);

            var averageRating = await _verificationRepository.GetAverageDoctorRatingAsync(ct) ?? 0;
            var totalReviews = await _verificationRepository.GetTotalReviewsCountAsync(ct);
            var now = DateTime.UtcNow;
            var startOfCurrentMonth = new DateTime(now.Year, now.Month, 1);
            var startOfNextMonth = startOfCurrentMonth.AddMonths(1);
            var startOfPreviousMonth = startOfCurrentMonth.AddMonths(-1);
            var verifiedDoctorsThisMonth = await _verificationRepository.CountApprovedBetweenAsync(
                startOfCurrentMonth,
                startOfNextMonth,
                ct);
            var verifiedDoctorsLastMonth = await _verificationRepository.CountApprovedBetweenAsync(
                startOfPreviousMonth,
                startOfCurrentMonth,
                ct);
            var lastSevenDaysTrend = await BuildDailyTrendAsync(
                (start, end, token) => _userStatusRepository.GetNewDoctorsCountAsync(start, end, token),
                ct);

            var stats = new DoctorStatisticsDto
            {
                TotalDoctors = totalDoctors,
                VerifiedDoctors = verifiedDoctors,
                PendingVerification = pendingVerification,
                RejectedDoctors = rejectedDoctors,
                AverageRating = Math.Round(averageRating, 2),
                TotalReviews = totalReviews,
                VerifiedDoctorsThisMonth = verifiedDoctorsThisMonth,
                VerifiedDoctorsLastMonth = verifiedDoctorsLastMonth,
                VerifiedDoctorsPercentageChange = CalculatePercentageChange(
                    verifiedDoctorsThisMonth,
                    verifiedDoctorsLastMonth),
                LastSevenDaysTrend = lastSevenDaysTrend
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
            var now = DateTime.UtcNow;
            var startOfCurrentMonth = new DateTime(now.Year, now.Month, 1);
            var startOfNextMonth = startOfCurrentMonth.AddMonths(1);
            var startOfPreviousMonth = startOfCurrentMonth.AddMonths(-1);
            var closedTicketsThisMonth = await _ticketRepository.CountClosedTicketsBetweenAsync(
                startOfCurrentMonth,
                startOfNextMonth,
                ct);
            var closedTicketsLastMonth = await _ticketRepository.CountClosedTicketsBetweenAsync(
                startOfPreviousMonth,
                startOfCurrentMonth,
                ct);
            var lastSevenDaysTrend = await BuildDailyTrendAsync(
                (start, end, token) => _ticketRepository.CountClosedTicketsBetweenAsync(start, end, token),
                ct);

            var stats = new TicketStatisticsDto
            {
                TotalTickets = statusCounts.Values.Sum(),
                OpenTickets = openTickets,
                InProgressTickets = inProgress,
                ResolvedTickets = resolved,
                ClosedTickets = closed,
                UrgentTickets = urgent,
                ClosedTicketsThisMonth = closedTicketsThisMonth,
                ClosedTicketsLastMonth = closedTicketsLastMonth,
                ClosedTicketsPercentageChange = CalculatePercentageChange(closedTicketsThisMonth, closedTicketsLastMonth),
                LastSevenDaysTrend = lastSevenDaysTrend,
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
            var doctors = await _verificationRepository.GetAllDoctorsWithVerificationsAsync(ct);
            var statusCounts = doctors
                .Select(d => DoctorVerificationPolicy.DetermineRequestStatus(d.Verifications))
                .GroupBy(status => status)
                .ToDictionary(group => group.Key, group => group.Count());
            var now = DateTime.UtcNow;
            var startOfMonth = new DateTime(now.Year, now.Month, 1);
            var startOfNextMonth = startOfMonth.AddMonths(1);
            var startOfPreviousMonth = startOfMonth.AddMonths(-1);
            var pendingThisMonth = await _verificationRepository.CountPendingDoctorRequestsBetweenAsync(
                startOfMonth,
                startOfNextMonth,
                ct);
            var pendingLastMonth = await _verificationRepository.CountPendingDoctorRequestsBetweenAsync(
                startOfPreviousMonth,
                startOfMonth,
                ct);
            var lastSevenDaysTrend = await BuildDailyTrendAsync(
                (start, end, token) => _verificationRepository.CountPendingDoctorRequestsBetweenAsync(start, end, token),
                ct);
            var stats = new VerificationStatisticsDto
            {
                TotalDoctors = doctors.Count,
                PendingDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Pending, 0),
                ApprovedDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Approved, 0),
                RejectedDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Rejected, 0),
                IncompleteDoctors = statusCounts.GetValueOrDefault(DoctorVerificationRequestStatus.Incomplete, 0),
                DoctorsByStatus = statusCounts,
                ApprovedThisMonth = await _verificationRepository.CountApprovedThisMonthAsync(startOfMonth, ct),
                RejectedThisMonth = await _verificationRepository.CountRejectedThisMonthAsync(startOfMonth, ct),
                PendingDoctorsPercentageChange = CalculatePercentageChange(pendingThisMonth, pendingLastMonth),
                LastSevenDaysTrend = lastSevenDaysTrend
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
                    ActionType = _localizationService.FormatEnumLabel(log.ActionType.ToString()),
                    TargetEntity = _localizationService.FormatEnumLabel(log.TargetEntity),
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

    private static double CalculatePercentageChange(int currentValue, int previousValue)
    {
        if (previousValue == 0)
            return currentValue == 0 ? 0 : 100;

        var difference = currentValue - previousValue;
        var percentageChange = (double)difference / previousValue * 100;

        return Math.Round(percentageChange, 2);
    }

    private async Task<List<int>> BuildDailyTrendAsync(
        Func<DateTime, DateTime, CancellationToken, Task<int>> countFunc,
        CancellationToken ct)
    {
        var today = DateTime.UtcNow.Date;
        var values = new List<int>(capacity: 7);

        for (var offset = 6; offset >= 0; offset--)
        {
            var start = today.AddDays(-offset);
            var end = start.AddDays(1);
            values.Add(await countFunc(start, end, ct));
        }

        return values;
    }

    private async Task<List<UserRegistrationTrendDto>> BuildSixMonthRegistrationTrendsAsync(CancellationToken ct)
    {
        var currentMonthStart = new DateTime(DateTime.UtcNow.Year, DateTime.UtcNow.Month, 1);
        var monthStarts = Enumerable.Range(0, 6)
            .Select(offset => currentMonthStart.AddMonths(-(5 - offset)))
            .ToList();

        var trends = new List<UserRegistrationTrendDto>(capacity: 6);

        foreach (var monthStart in monthStarts)
        {
            var monthEnd = monthStart.AddMonths(1);
            trends.Add(new UserRegistrationTrendDto
            {
                Month = monthStart.ToString("MMM yyyy", _localizationService.GetCulture()),
                Patients = await _userStatusRepository.GetNewPatientsCountAsync(monthStart, monthEnd, ct),
                Doctors = await _userStatusRepository.GetNewDoctorsCountAsync(monthStart, monthEnd, ct)
            });
        }

        return trends;
    }
}
