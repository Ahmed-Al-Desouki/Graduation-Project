using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys; // ← هنا
using System.Security.Claims;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/passkey")]
    public class PasskeyController : ControllerBase
    {
        private readonly IPasskeyService _passkeyService;

        public PasskeyController(IPasskeyService passkeyService)
        {
            _passkeyService = passkeyService;
        }

        [Authorize]
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] PasskeyRegisterRequest request)
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (string.IsNullOrEmpty(userIdClaim)) return Unauthorized();

            var userId = int.Parse(userIdClaim);

            var result = await _passkeyService.RegisterPasskeyAsync(
                userId,
                request.CredentialId,
                request.PublicKey
            );

            if (!result.Succeeded)
                return BadRequest(new { error = result.Error });

            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                expiresInDays = 30,
                message = "Passkey Active! You can log in without internet for 30 days."
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] PasskeyLoginRequest request) // ← من Models
        {
            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var result = await _passkeyService.LoginWithPasskeyAsync(request, deviceInfo, ipAddress);
            if (result.AccessToken == null)
                return Unauthorized(new { success = false, error = result.Error });

            SetRefreshTokenCookie(result.RefreshToken);
            return Ok(new { success = true, accessToken = result.AccessToken });
        }

        [Authorize]
        [HttpPost("challenge")]
        public async Task<IActionResult> GenerateChallenge([FromBody] GenerateChallengeRequest request) // ← من Models
        {
            if (User.FindFirst("UserID")?.Value != request.UserId)
                return Unauthorized();

            var challenge = await _passkeyService.GeneratePasskeyChallengeAsync(request.UserId);
            return Ok(new { success = true, challenge });
        }

        public class GenerateChallengeRequest
        {
            public string UserId { get; set; } = null!;
        }

        private void SetRefreshTokenCookie(string token)
        {
            Response.Cookies.Append("refresh_token", token, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });
        }

        private int GetUserId() =>
            int.TryParse(User.FindFirst("UserID")?.Value, out int id) ? id : 0;
    }
}