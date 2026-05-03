using HealthCare_.Models.DTOs.CloudinaryDTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using WelloraHealthCareManagement.Application.Interfaces;

namespace WelloraHealthCareManagment.API.Controller.fileUpload
{
    [Route("api/profile-image")]
    [ApiController]
    [Authorize(Roles = "Doctor,Patient")]
    public class ProfileImageController : ControllerBase
    {
        private readonly IFileUploadService _fileService;
        private readonly ILogger<ProfileImageController> _logger;

        public ProfileImageController(
            IFileUploadService fileService,
            ILogger<ProfileImageController> logger)
        {
            _fileService = fileService;
            _logger = logger;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value
                              ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                              ?? User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
            {
                _logger.LogError("User ID claim not found. Available claims: {Claims}",
                    string.Join(", ", User.Claims.Select(c => $"{c.Type}={c.Value}")));
                throw new UnauthorizedAccessException("User ID missing");
            }

            if (int.TryParse(userIdClaim, out int userId))
            {
                return userId;
            }

            throw new UnauthorizedAccessException("Invalid User ID format");
        }

        private string GetCurrentUserRole()
        {
            var roleClaim = User.FindFirst(ClaimTypes.Role)?.Value
                            ?? User.FindFirst("Role")?.Value;

            if (string.IsNullOrWhiteSpace(roleClaim))
            {
                _logger.LogError("User role claim not found. Available claims: {Claims}",
                    string.Join(", ", User.Claims.Select(c => $"{c.Type}={c.Value}")));
                throw new UnauthorizedAccessException("User role missing");
            }

            return roleClaim;
        }

        [HttpPut("update")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> Update([FromForm] UpdateProfileImageRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var userId = GetCurrentUserId();
            var userRole = GetCurrentUserRole();

            var response = await _fileService.UpdateProfileImageAsync(request, userId, userRole);

            if (!response.Success)
            {
                return BadRequest(new { success = false, error = response.Error });
            }

            return Ok(new
            {
                success = true,
                message = response.Message,
                file = response.File
            });
        }
    }
}
