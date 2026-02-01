using HealthCare_.Services.Auth;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagement.API.Controllers.Authintecation
{
    [ApiController]
    [Route("api/[controller]")]
    public class ExternalAuthController : ControllerBase
    {
        private readonly IGoogleAuthService _googleAuthService;
        private readonly ILogger<ExternalAuthController> _logger;

        public ExternalAuthController(
            IGoogleAuthService googleAuthService,
            ILogger<ExternalAuthController> logger)
        {
            _googleAuthService = googleAuthService;
            _logger = logger;
        }

        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Extract device info and IP
            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            if (deviceInfo.Length > 256)
                deviceInfo = deviceInfo[..256];

            var ipAddress = Request.Headers.ContainsKey("X-Forwarded-For")
                ? Request.Headers["X-Forwarded-For"].ToString().Split(',').FirstOrDefault()?.Trim() ?? "unknown"
                : HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            // Call service
            var (accessToken, refreshToken, error) = await _googleAuthService.GoogleLoginAsync(
                request.IdToken,
                request.Role,
                deviceInfo,
                ipAddress);

            if (!string.IsNullOrEmpty(error))
                return BadRequest(new { success = false, error });

            return Ok(new
            {
                success = true,
                accessToken,
                refreshToken
            });
        }
    }
}