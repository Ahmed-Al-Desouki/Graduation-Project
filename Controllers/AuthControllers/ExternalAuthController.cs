// File: Controllers/ExternalAuthController.cs
using HealthCare_.Interfaces.IAuth;
using HealthCare_.Services.Auth;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
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
            _logger.LogInformation("GoogleLogin: Endpoint called");

            if (request == null || string.IsNullOrEmpty(request.IdToken))
            {
                _logger.LogWarning("GoogleLogin: Invalid request - Missing IdToken");
                return BadRequest(new { success = false, error = "Invalid request" });
            }

            // Extract device info and IP address
            var rawDeviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var deviceInfo = rawDeviceInfo.Length > 256 ? rawDeviceInfo[..256] : rawDeviceInfo;

            string ipAddress;
            if (Request.Headers.ContainsKey("X-Forwarded-For"))
            {
                ipAddress = Request.Headers["X-Forwarded-For"].ToString().Split(',').FirstOrDefault()?.Trim() ?? "unknown";
            }
            else
            {
                ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            }

            _logger.LogInformation("GoogleLogin: DeviceInfo='{DeviceInfo}', IP='{IP}'", deviceInfo, ipAddress);

            // Call service to handle all logic
            var (accessToken, refreshToken, error) = await _googleAuthService.GoogleLoginAsync(
                request.IdToken,
                request.Role,
                deviceInfo,
                ipAddress);

            if (!string.IsNullOrEmpty(error))
            {
                _logger.LogWarning("GoogleLogin: Login failed - {Error}", error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("GoogleLogin: Login successful");
            return Ok(new
            {
                success = true,
                accessToken,
                refreshToken
            });
        }
    }
}