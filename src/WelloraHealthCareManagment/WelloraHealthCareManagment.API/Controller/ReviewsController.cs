// File: API/Controllers/ReviewsController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Requests;
using WelloraHealthCareManagment.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controllers
{
    [ApiController]
    [Route("api/reviews")]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _reviewService;

        public ReviewsController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        private int GetUserId() =>
            int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);


        // GET /api/reviews/doctor/{doctorId}
        // Public — أي حد يقدر يشوف reviews الدكتور
        [HttpGet("doctor/{doctorId}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetDoctorReviews(int doctorId)
        {
            var result = await _reviewService.GetDoctorReviewsAsync(doctorId);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(result.Error);
        }


        // POST /api/reviews
        // Patient only
        [HttpPost]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> AddReview([FromBody] AddReviewRequest request)
        {
            var result = await _reviewService.AddReviewAsync(GetUserId(), request);
            return result.IsSuccess ? Ok(result.Data) : BadRequest(result.Error);
        }


        // PATCH /api/reviews/{reviewId}
        // Patient only — يعدل review بتاعه بس
        [HttpPatch("{reviewId}")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> UpdateReview(
            int reviewId,
            [FromBody] UpdateReviewRequest request)
        {
            var result = await _reviewService.UpdateReviewAsync(GetUserId(), reviewId, request);
            return result.IsSuccess ? Ok("Review updated") : BadRequest(result.Error);
        }


        // DELETE /api/reviews/{reviewId}
        // Patient only — يحذف review بتاعه بس
        [HttpDelete("{reviewId}")]
        [Authorize(Roles = "Patient")]
        public async Task<IActionResult> DeleteReview(int reviewId)
        {
            var result = await _reviewService.DeleteReviewAsync(GetUserId(), reviewId);
            return result.IsSuccess ? Ok("Review deleted") : BadRequest(result.Error);
        }
    }
}