// File: Controllers/ProfileController.cs
using HealthCare_.Interfaces.IProfile;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers.SharedControllers.UsersProfileController
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly IProfilePictureService _profilePictureService;
        private readonly ILogger<UserProfileController> _logger;

        public UserProfileController(
            IProfilePictureService profilePictureService,
            ILogger<UserProfileController> logger)
        {
            _profilePictureService = profilePictureService;
            _logger = logger;
        }

        [HttpGet("picture")]
        public async Task<IActionResult> GetProfilePicture()
        {
            _logger.LogInformation("GetProfilePicture: Endpoint called");

            var userId = GetCurrentUserId();
            if (userId == null)
            {
                _logger.LogWarning("GetProfilePicture: Unauthorized - No user ID in token");
                return Unauthorized(new { success = false, error = "User not authenticated" });
            }

            var (success, imageUrl, error) = await _profilePictureService.GetProfilePictureAsync(userId.Value);

            if (!success)
            {
                _logger.LogWarning("GetProfilePicture: Failed for UserId={UserId}, Error={Error}", userId, error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("GetProfilePicture: Retrieved for UserId={UserId}", userId);
            return Ok(new
            {
                success = true,
                imageUrl
            });
        }

        [HttpDelete("picture")]
        public async Task<IActionResult> DeleteProfilePicture()
        {
            _logger.LogInformation("DeleteProfilePicture: Endpoint called");

            var userId = GetCurrentUserId();
            if (userId == null)
            {
                _logger.LogWarning("DeleteProfilePicture: Unauthorized - No user ID in token");
                return Unauthorized(new { success = false, error = "User not authenticated" });
            }

            var (success, error) = await _profilePictureService.DeleteProfilePictureAsync(userId.Value);

            if (!success)
            {
                _logger.LogWarning("DeleteProfilePicture: Failed for UserId={UserId}, Error={Error}", userId, error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("DeleteProfilePicture: Deleted for UserId={UserId}", userId);
            return Ok(new
            {
                success = true,
                message = "Profile picture deleted successfully"
            });
        }

        #region Helper Methods

        private int? GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? User.FindFirst("UserID")?.Value;

            if (string.IsNullOrEmpty(userIdClaim))
                return null;

            return int.TryParse(userIdClaim, out var userId) ? userId : null;
        }

        #endregion
    }
}