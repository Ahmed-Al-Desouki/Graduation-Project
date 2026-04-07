// Presentation/Controllers/Admin/AdminDashboardController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Presentation.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/dashboard")]
    [Authorize(Roles = "Admin")]
    public class AdminDashboardController : ControllerBase
    {
        private readonly IAdminDashboardService _dashboardService;

        public AdminDashboardController(IAdminDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        /// <summary>
        /// Get complete admin dashboard overview (All statistics + recent activity)
        /// </summary>
        [HttpGet("overview")]
        public async Task<IActionResult> GetDashboardOverview(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetDashboardOverviewAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error ?? "Failed to load dashboard" });
        }

        /// <summary>
        /// Get only User Statistics
        /// </summary>
        [HttpGet("users")]
        public async Task<IActionResult> GetUserStatistics(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetUserStatisticsAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get only Doctor Statistics
        /// </summary>
        [HttpGet("doctors")]
        public async Task<IActionResult> GetDoctorStatistics(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetDoctorStatisticsAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get only Ticket Statistics
        /// </summary>
        [HttpGet("tickets")]
        public async Task<IActionResult> GetTicketStatistics(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetTicketStatisticsAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get only Verification Statistics
        /// </summary>
        [HttpGet("verifications")]
        public async Task<IActionResult> GetVerificationStatistics(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetVerificationStatisticsAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get only Recent Activity (Recent actions, tickets, pending verifications)
        /// </summary>
        [HttpGet("recent-activity")]
        public async Task<IActionResult> GetRecentActivity(CancellationToken ct = default)
        {
            var result = await _dashboardService.GetRecentActivityAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }
    }
}