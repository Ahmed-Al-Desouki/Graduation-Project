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
        //[HttpGet("pending")]
        //public async Task<IActionResult> GetPendingVerifications(
        //    [FromQuery] int page = 1,
        //    [FromQuery] int pageSize = 10,
        //    CancellationToken ct = default)
        //{
        //    var result = await _verificationService.GetPendingVerificationsAsync(page, pageSize, ct);

        //    return result.IsSuccess
        //        ? Ok(result.Data)
        //        : BadRequest(new { error = result.Error });
        //}

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
        /// Get doctor verification request details by doctor ID
        /// </summary>
        [HttpGet("{doctorId:int}")]
        public async Task<IActionResult> GetDoctorVerificationDetails(int doctorId, CancellationToken ct = default)
        {
            var result = await _verificationService.GetDoctorVerificationDetailsAsync(doctorId, ct);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(new { error = result.Error ?? "Doctor verification request not found" });
        }

        /// <summary>
        /// Approve a doctor verification request
        /// </summary>
        [HttpPost("{doctorId}/approve")]
        public async Task<IActionResult> ApproveDoctor(
            int doctorId,
            [FromBody] ApproveDoctorVerificationRequest? request,
            CancellationToken ct = default)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0"); // Get admin id from token

            var result = await _verificationService.ApproveDoctorAsync(doctorId, request, adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString(), ct);

            return result.IsSuccess
                ? Ok(new { message = "Doctor verification request approved successfully" })
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Reject a doctor verification request with reason
        /// </summary>
        [HttpPost("{doctorId}/reject")]
        public async Task<IActionResult> RejectDoctor(
            int doctorId,
            [FromBody] RejectDoctorVerificationRequest request,
            CancellationToken ct = default)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _verificationService.RejectDoctorAsync(doctorId, request, adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString(), ct);

            return result.IsSuccess
                ? Ok(new { message = "Doctor verification request rejected successfully" })
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
