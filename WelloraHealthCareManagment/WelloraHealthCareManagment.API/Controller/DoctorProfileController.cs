namespace WelloraHealthCareManagment.API.Controller
{
    using global::WelloraHealthCareManagment.Application.DTOs.DoctorDtos;
    using global::WelloraHealthCareManagment.Application.Interfaces;
    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using System.Security.Claims;

    namespace WelloraHealthCareManagment.API.Controllers
    {
        [ApiController]
        [Route("api/doctor/profile")]
        [Authorize(Roles = "Doctor")]
        public class DoctorProfileController : ControllerBase
        {
            private readonly IDoctorProfileService _profileService;

            public DoctorProfileController(IDoctorProfileService profileService)
            {
                _profileService = profileService;
            }

            // ─── Helper ───
            private int GetDoctorId() =>
                int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);


            // GET /api/doctor/profile
            [HttpGet]
            public async Task<IActionResult> GetProfile()
            {
                var result = await _profileService.GetProfileAsync(GetDoctorId());
                return result.IsSuccess ? Ok(result.Data) : NotFound(result.Error);
            }


            // POST /api/doctor/profile/complete
            [HttpPost("complete")]
            public async Task<IActionResult> CompleteProfile([FromBody] CompleteDoctorProfileRequest request)
            {
                var result = await _profileService.CompleteDoctorProfileAsync(GetDoctorId(), request);
                return result.IsSuccess ? Ok("Profile completed successfully") : BadRequest(result.Error);
            }


            // PATCH /api/doctor/profile/basic-info
            [HttpPatch("basic-info")]
            public async Task<IActionResult> UpdateBasicInfo([FromBody] UpdateDoctorBasicInfoRequest request)
            {
                var result = await _profileService.UpdateBasicInfoAsync(GetDoctorId(), request);
                return result.IsSuccess ? Ok("Basic info updated") : BadRequest(result.Error);
            }


            // PATCH /api/doctor/profile/location
            [HttpPatch("location")]
            public async Task<IActionResult> UpdateLocation([FromBody] UpdateDoctorLocationRequest request)
            {
                var result = await _profileService.UpdateLocationAsync(GetDoctorId(), request);
                return result.IsSuccess ? Ok("Location updated") : BadRequest(result.Error);
            }


            // POST /api/doctor/profile/verification-documents
            [HttpPost("verification-documents")]
            [Consumes("multipart/form-data")]
            public async Task<IActionResult> AddVerificationDocument(
                [FromForm] AddVerificationDocumentRequest request)
            {
                var result = await _profileService.AddVerificationDocumentAsync(GetDoctorId(), request);
                return result.IsSuccess ? Ok("Document submitted for review") : BadRequest(result.Error);
            }


            // PUT /api/doctor/profile/verification-documents/{id}
            [HttpPut("verification-documents/{verificationId}")]
            [Consumes("multipart/form-data")]
            public async Task<IActionResult> ReplaceVerificationDocument(
                int verificationId,
                IFormFile newFile)
            {
                var result = await _profileService.ReplaceVerificationDocumentAsync(
                    GetDoctorId(), verificationId, newFile);
                return result.IsSuccess ? Ok("Document replaced and resubmitted for review") : BadRequest(result.Error);
            }


            // POST /api/doctor/profile/achievements
            [HttpPost("achievements")]
            [Consumes("multipart/form-data")]
            public async Task<IActionResult> AddAchievement([FromForm] AddAchievementRequest request)
            {
                var result = await _profileService.AddAchievementAsync(GetDoctorId(), request);
                return result.IsSuccess ? Ok(result.Data) : BadRequest(result.Error);
            }


            // PATCH /api/doctor/profile/achievements/{id}
            [HttpPatch("achievements/{achievementId}")]
            [Consumes("multipart/form-data")]
            public async Task<IActionResult> UpdateAchievement(
                int achievementId,
                [FromForm] UpdateAchievementRequest request)
            {
                var result = await _profileService.UpdateAchievementAsync(
                    GetDoctorId(), achievementId, request);
                return result.IsSuccess ? Ok("Achievement updated") : BadRequest(result.Error);
            }


            // DELETE /api/doctor/profile/achievements/{id}
            [HttpDelete("achievements/{achievementId}")]
            public async Task<IActionResult> DeleteAchievement(int achievementId)
            {
                var result = await _profileService.DeleteAchievementAsync(GetDoctorId(), achievementId);
                return result.IsSuccess ? Ok("Achievement deleted") : BadRequest(result.Error);
            }
        }
    }
}
