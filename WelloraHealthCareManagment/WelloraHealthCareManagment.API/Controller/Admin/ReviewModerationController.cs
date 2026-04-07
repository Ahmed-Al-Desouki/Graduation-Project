// Presentation/Controllers/Admin/ReviewModerationController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Presentation.Controllers.Admin
{
    [ApiController]
    [Route("api/admin/reviews")]
    [Authorize(Roles = "Admin")]
    public class AdminReviewModerationController : ControllerBase
    {
        private readonly IReviewModerationService _reviewService;

        public AdminReviewModerationController(IReviewModerationService reviewService)
        {
            _reviewService = reviewService;
        }

        /// <summary>
        /// Get all active reviews with filtering and pagination
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAllReviews(
            [FromQuery] int? doctorId = null,
            [FromQuery] int? userId = null,
            [FromQuery] double? minRating = null,
            [FromQuery] double? maxRating = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result = await _reviewService.GetAllReviewsAsync(
                doctorId, userId, minRating, maxRating, fromDate, toDate, page, pageSize);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get deleted reviews (soft deleted) with pagination
        /// </summary>
        [HttpGet("deleted")]
        public async Task<IActionResult> GetDeletedReviews(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            var result = await _reviewService.GetDeletedReviewsAsync(page, pageSize);

            return result.IsSuccess
                ? Ok(result.Data)
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Soft delete a review
        /// </summary>
        [HttpPost("delete")]
        public async Task<IActionResult> DeleteReview(
            [FromBody] DeleteReviewRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _reviewService.DeleteReviewAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "Review deleted successfully" })
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Restore a soft-deleted review
        /// </summary>
        [HttpPost("restore")]
        public async Task<IActionResult> RestoreReview(
            [FromBody] RestoreReviewRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var adminId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            var result = await _reviewService.RestoreReviewAsync(
                request,
                adminId,
                HttpContext.Connection.RemoteIpAddress?.ToString());

            return result.IsSuccess
                ? Ok(new { message = "Review restored successfully" })
                : BadRequest(new { error = result.Error });
        }

        /// <summary>
        /// Get single review details
        /// </summary>
        [HttpGet("{reviewId}")]
        public async Task<IActionResult> GetReviewDetails(int reviewId)
        {
            var result = await _reviewService.GetReviewDetailsAsync(reviewId);

            return result.IsSuccess
                ? Ok(result.Data)
                : NotFound(new { error = result.Error ?? "Review not found" });
        }
    }
}