using Microsoft.AspNetCore.Mvc;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthCoreService _authCoreService;
        private readonly ITokenService _tokenService;
        private readonly IEmailService _emailService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IAuthCoreService authCoreService,
            ITokenService tokenService,
            IEmailService emailService,
            ILogger<AuthController> logger)
        {
            _authCoreService = authCoreService;
            _tokenService = tokenService;
            _emailService = emailService;
            _logger = logger;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromForm] RegisterRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var result = await _authCoreService.RegisterAsync(request);
            return result.Succeeded
                ? Ok(new { success = true, message = "User registered successfully" })
                : BadRequest(new { success = false, errors = result.Errors });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var result = await _authCoreService.LoginAsync(request, deviceInfo, ipAddress, _emailService);

            if (result.Error == "MFA_OTP_SENT")
                return Ok(new { success = true, requiresMfa = true, message = "Check your email" });

            if (result.AccessToken == null)
                return Unauthorized(new { success = false, error = result.Error });

            SetRefreshTokenCookie(result.RefreshToken);
            return Ok(new { success = true, accessToken = result.AccessToken });
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var result = await _tokenService.RefreshTokenAsync(request, deviceInfo, ipAddress);
            if (!string.IsNullOrEmpty(result.Error))
                return Unauthorized(new { success = false, error = result.Error });

            SetRefreshTokenCookie(result.RefreshToken);
            return Ok(new { success = true, accessToken = result.AccessToken });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var result = await _authCoreService.LogoutAsync(request);
            Response.Cookies.Delete("refresh_token");
            return result.Succeeded
                ? Ok(new { success = true, message = "Logged out" })
                : BadRequest(new { success = false, error = result.Error });
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
    }
}