using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.DTOs.AuthModels.Login_register;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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
        private readonly HealthCarePlusContext _context;
        private readonly IConfiguration _configuration;

        public AuthController(
            IAuthCoreService authCoreService,
            ITokenService tokenService,
            IEmailService emailService,
            ILogger<AuthController> logger,
            HealthCarePlusContext context,
            IConfiguration configuration)
        {
            _authCoreService = authCoreService;
            _tokenService = tokenService;
            _emailService = emailService;
            _logger = logger;
            _context = context;
            _configuration = configuration;
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
            return Ok(new { success = true, accessToken = result.AccessToken, refreshToken = result.RefreshToken });
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest? request)
        {
            //  نتأكد من أن فيه Refresh Token سواء من البودي أو الكوكي
            var refreshToken = request?.RefreshToken ?? Request.Cookies["refresh_token"];

            if (string.IsNullOrEmpty(refreshToken))
                return BadRequest(new { success = false, error = "Missing refresh token" });

            //  نتأكد من فك أي URL Encoding حصل (في Flutter ممكن يحصل تلقائي)
            refreshToken = Uri.UnescapeDataString(refreshToken);

            //  معلومات الجهاز والآيبي (اختياري)
            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            //  نمرر القيم بوضوح للخدمة
            var result = await _tokenService.RefreshTokenAsync(
                new RefreshRequest
                {
                    AccessToken = request?.AccessToken,
                    RefreshToken = refreshToken
                },
                deviceInfo, ipAddress);

            if (!string.IsNullOrEmpty(result.Error))
                return Unauthorized(new { success = false, error = result.Error });

            //  نحدث الكوكي لو حبيت تدعم الويب كمان
            SetRefreshTokenCookie(result.RefreshToken);

            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken // ← نرجعه في الـ body عشان Flutter يخزنه
            });
        }


        [HttpGet("devices")]
        [Authorize]
        public async Task<IActionResult> GetActiveDevices()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? User.FindFirst("UserID")?.Value
                           ?? User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;

            if (!int.TryParse(userIdClaim, out int userId) || userId <= 0)
                return Unauthorized(new { success = false, error = "Invalid user" });

            var currentDeviceInfo = HttpContext.Request.Headers["User-Agent"].ToString();
            var currentIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var maxDevices = Convert.ToInt32(_configuration["Auth:MaxActiveDevices"] ?? "3");

            var activeSessions = await _context.UserSessions
                .Where(s =>
                    s.UserId == userId &&
                    s.IsActive &&
                    !s.IsRevoked &&
                    s.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(s => s.LastActivity)
                .Select(s => new ActiveDeviceDto
                {
                    DeviceInfo = s.DeviceInfo ?? "Unknown Device",
                    IpAddress = s.IpAddress,
                    LastActivity = s.LastActivity,
                    IsCurrentDevice = s.DeviceInfo == currentDeviceInfo && s.IpAddress == currentIp
                })
                .ToListAsync();

            var response = new GetActiveDevicesResponse
            {
                TotalActiveDevices = activeSessions.Count,
                MaxAllowedDevices = maxDevices,
                Devices = activeSessions
            };

            return Ok(response);
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