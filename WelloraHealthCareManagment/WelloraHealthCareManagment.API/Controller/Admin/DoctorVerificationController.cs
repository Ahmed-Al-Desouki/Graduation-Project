// Presentation/Controllers/Admin/DoctorVerificationController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Presentation.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/doctor-verifications")]
    [Authorize(Roles = "Admin")]
    public class AdminDoctorVerificationController : ControllerBase
    {
        private readonly IDoctorVerificationService _verificationService;

        public AdminDoctorVerificationController(IDoctorVerificationService verificationService)
        {
            _verificationService = verificationService;
        }

        /// <summary>
        /// Get pending doctor verifications (with pagination)
        /// </summary>
        [HttpGet("pending")]
        public async Task<IActionResult> GetPendingVerifications(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken ct = default)
        {
            var result = await _verificationService.GetPendingVerificationsAsync(page, pageSize, ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get all verifications with optional filtering and pagination
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllVerifications(
            [FromQuery] VerificationStatus? status = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10,
            CancellationToken ct = default)
        {
            var result = await _verificationService.GetAllVerificationsAsync(
                status, fromDate, toDate, page, pageSize, ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get single verification details by ID
        /// </summary>
        [HttpGet("{verificationId}")]
        public async Task<IActionResult> GetVerificationDetails(int verificationId, CancellationToken ct = default)
        {
            var result = await _verificationService.GetVerificationDetailsAsync(verificationId, ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(new { error = result.Error ?? "Verification not found" });
        }

        /// <summary>
        /// Approve a doctor verification
        /// </summary>
        [HttpPost("approve")]
        public async Task<IActionResult> ApproveDoctor([FromBody] ApproveDoctorVerificationRequest request, CancellationToken ct = default)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0"); // Get admin id from token

            var result = await _verificationService.ApproveDoctorAsync(request, adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString(), ct);

            return result.IsSuccess
                ? Ok(new { message = "Doctor verification approved successfully" })
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Reject a doctor verification with reason
        /// </summary>
        [HttpPost("reject")]
        public async Task<IActionResult> RejectDoctor([FromBody] RejectDoctorVerificationRequest request, CancellationToken ct = default)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _verificationService.RejectDoctorAsync(request, adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString(), ct);

            return result.IsSuccess
                ? Ok(new { message = "Doctor verification rejected successfully" })
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get verification statistics
        /// </summary>
        [HttpGet("statistics")]
        public async Task<IActionResult> GetStatistics(CancellationToken ct = default)
        {
            var result = await _verificationService.GetStatisticsAsync(ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }
    }
}