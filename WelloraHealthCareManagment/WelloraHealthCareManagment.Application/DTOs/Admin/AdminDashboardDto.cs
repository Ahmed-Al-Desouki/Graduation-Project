using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class AdminDashboardDto
    {
        public UserStatisticsDto UserStatistics { get; set; } = new();
        public DoctorStatisticsDto DoctorStatistics { get; set; } = new();
        public TicketStatisticsDto TicketStatistics { get; set; } = new();
        public VerificationStatisticsDto VerificationStatistics { get; set; } = new();
        public RecentActivityDto RecentActivity { get; set; } = new();
    }

    public class UserStatisticsDto
    {
        public int TotalUsers { get; set; }
        public int TotalDoctors { get; set; }
        public int TotalPatients { get; set; }
        public int BlockedUsers { get; set; }
        public int SuspendedUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int NewUsersThisMonth { get; set; }
    }

    public class DoctorStatisticsDto
    {
        public int TotalDoctors { get; set; }
        public int VerifiedDoctors { get; set; }
        public int PendingVerification { get; set; }
        public int RejectedDoctors { get; set; }
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
    }

    public class RecentActivityDto
    {
        public List<RecentActionDto> RecentActions { get; set; } = new();
        public List<TicketDto> RecentTickets { get; set; } = new();
        public List<DoctorVerificationDto> PendingVerifications { get; set; } = new();
    }

    public class RecentActionDto
    {
        public string AdminName { get; set; } = string.Empty;
        public string ActionType { get; set; } = string.Empty;
        public string TargetEntity { get; set; } = string.Empty;
        public DateTime Timestamp { get; set; }
    }
}
