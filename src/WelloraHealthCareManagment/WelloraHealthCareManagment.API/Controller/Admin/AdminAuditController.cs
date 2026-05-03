// Presentation/Controllers/Admin/AdminAuditController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Presentation.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/audit")]
    [Authorize(Roles = "Admin")]
    public class AdminAuditController : ControllerBase
    {
        private readonly IAdminAuditService _auditService;

        public AdminAuditController(IAdminAuditService auditService)
        {
            _auditService = auditService;
        }

        // POST: api/admin/audit/log
        // (عادةً ما يتم استدعاؤها داخليًا من الخدمات الأخرى، لكن يمكن تركها للاختبار)
        [HttpPost("log")]
        public async Task<IActionResult> LogActionForTest([FromBody] LogActionRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            await _auditService.LogActionAsync(
                adminId: request.AdminId,
                actionType: request.ActionType,
                targetEntity: request.TargetEntity,
                targetId: request.TargetId,
                details: request.Details,
                ipAddress: HttpContext.Connection.RemoteIpAddress?.ToString(),
                userAgent: Request.Headers["User-Agent"].ToString());

            // LogActionAsync لا يرجع ServiceResult، بل يتعامل مع الخطأ داخليًا
            return Ok(new { message = "Action logged successfully" });
        }

        // GET: api/admin/audit/logs
        [HttpGet("logs")]
        public async Task<IActionResult> GetLogs(
            [FromQuery] int? adminId = null,
            [FromQuery] AdminActionType? actionType = null,
            [FromQuery] string? targetEntity = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var result = await _auditService.GetLogsAsync(
                adminId, actionType, targetEntity, fromDate, toDate, page, pageSize);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        // GET: api/admin/audit/logs/admin/{adminId}
        [HttpGet("logs/admin/{adminId}")]
        public async Task<IActionResult> GetLogsByAdmin(
            int adminId,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var result = await _auditService.GetLogsByAdminAsync(adminId, page, pageSize);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        // GET: api/admin/audit/logs/target
        [HttpGet("logs/target")]
        public async Task<IActionResult> GetLogsByTarget(
            [FromQuery] string targetEntity,
            [FromQuery] string targetId)
        {
            if (string.IsNullOrWhiteSpace(targetEntity) || string.IsNullOrWhiteSpace(targetId))
                return BadRequest("TargetEntity and TargetId are required");

            var result = await _auditService.GetLogsByTargetAsync(targetEntity, targetId);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        // GET: api/admin/audit/statistics
        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics(
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null)
        {
            var result = await _auditService.GetStatisticsAsync(fromDate, toDate);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }
    }

    // Helper Request Model for internal logging (اختياري)
    public class LogActionRequest
    {
        public int AdminId { get; set; }
        public AdminActionType ActionType { get; set; }
        public string TargetEntity { get; set; } = string.Empty;
        public string TargetId { get; set; } = string.Empty;
        public object? Details { get; set; }
    }
}