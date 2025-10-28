// Controllers/AuthController.cs
using HealthCare_.Interfaces;
using HealthCare_.Models;
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys;
using HealthCare_.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IEmailService _emailService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            IAuthService authService,
            IEmailService emailService,
            UserManager<ApplicationUser> userManager,
            HealthCarePlusContext context,
            ILogger<AuthController> logger)
        {
            _authService = authService;
            _emailService = emailService;
            _userManager = userManager;
            _context = context;
            _logger = logger;
        }

        // ====================== REGISTER ======================
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromForm] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var (succeeded, errors) = await _authService.RegisterAsync(request);
            if (!succeeded)
                return BadRequest(new { success = false, error = string.Join(", ", errors) });

            return Ok(new { success = true, data = new { message = "User registered successfully" } });
        }

        // ====================== LOGIN (مع Email OTP) ======================
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.LoginAsync(request, deviceInfo, ipAddress, _emailService);

            if (error == "MFA_OTP_SENT")
                return Ok(new { success = true, requiresMfa = true, message = "Check your email for the login code" });

            if (accessToken == null)
                return Unauthorized(new { success = false, error });

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }

        // ====================== REFRESH TOKEN ======================
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.RefreshTokenAsync(request, deviceInfo, ipAddress);
            if (!string.IsNullOrEmpty(error))
                return Unauthorized(new { success = false, error });

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }

        // ====================== LOGOUT ======================
        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var (succeeded, error) = await _authService.LogoutAsync(request);
            if (!succeeded)
                return BadRequest(new { success = false, error });

            Response.Cookies.Delete("refresh_token");
            return Ok(new { success = true, data = new { message = "Logout successful" } });
        }

        // ====================== ENABLE MFA (Email OTP) ======================
        [Authorize]
        [HttpPost("enable-2fa")]
        public async Task<IActionResult> EnableMfa()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { success = false, error = "Invalid user" });

            (bool succeeded, string message, string error) = await _authService.EnableMfaAsync(userId, _emailService);

            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true, data = new { message } });
        }

        // ====================== VERIFY MFA (Email OTP) ======================
        [Authorize]
        [HttpPost("verify-2fa")]
        public async Task<IActionResult> VerifyMfa([FromBody] VerifyMfaRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { success = false, error = "Invalid user" });

            var (succeeded, error) = await _authService.VerifyMfaAsync(userId, request.OtpCode);
            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true, data = new { message = "MFA verified successfully" } });
        }

        // ====================== RESEND OTP (اختياري) ======================
        [Authorize]
        [HttpPost("resend-otp")]
        public async Task<IActionResult> ResendOtp()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return Unauthorized();

            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null) return NotFound();

            await _authService.GenerateAndSendOtpAsync(user, _emailService);
            return Ok(new { success = true, message = "New OTP sent to your email" });
        }

        // ====================== REGISTER PASSKEY ======================
        [Authorize]
        [HttpPost("register-passkey")]
        public async Task<IActionResult> RegisterPasskey([FromBody] PasskeyRegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return Unauthorized(new { success = false, error = "Invalid user" });

            var (succeeded, error) = await _authService.RegisterPasskeyAsync(userId, request.CredentialId, request.PublicKey);
            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true, data = new { message = "Passkey registered successfully" } });
        }

        // ====================== LOGIN WITH PASSKEY ======================
        [HttpPost("login-passkey")]
        public async Task<IActionResult> LoginPasskey([FromBody] PasskeyLoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.LoginWithPasskeyAsync(request, deviceInfo, ipAddress);
            if (accessToken == null)
                return Unauthorized(new { success = false, error });

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }

        // ====================== GENERATE PASSKEY CHALLENGE ======================
        [Authorize]
        [HttpPost("generate-passkey-challenge")]
        public async Task<IActionResult> GeneratePasskeyChallenge([FromBody] GenerateChallengeRequest request)
        {
            if (!ModelState.IsValid || string.IsNullOrEmpty(request?.UserId))
                return BadRequest(new { success = false, error = "Invalid request data" });

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (userIdClaim != request.UserId)
                return Unauthorized(new { success = false, error = "Invalid user" });

            var challenge = await _authService.GeneratePasskeyChallengeAsync(request.UserId);
            return Ok(new { success = true, data = new { challenge } });
        }
    }

    // DTO للـ Challenge
    public class GenerateChallengeRequest
    {
        public string UserId { get; set; } = null!;
    }
}