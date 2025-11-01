//using Microsoft.AspNetCore.Authorization;
//using Microsoft.AspNetCore.Identity;
//using Microsoft.AspNetCore.Mvc;
//using System.Security.Claims;
//using HealthCare_.Models.DTOs.AuthModels;
//using Microsoft.Extensions.Configuration;
//using HealthCare_.Interfaces.IAuth; // <-- مطلوب

//namespace HealthCare_.Controllers
//{
//    [ApiController]
//    [Route("api/[controller]")]
//    public class AuthController : ControllerBase
//    {
//        private readonly IAuthService _authService;
//        private readonly IEmailService _emailService;
//        private readonly UserManager<ApplicationUser> _userManager;
//        private readonly HealthCarePlusContext _context;
//        private readonly SignInManager<ApplicationUser> _signInManager;
//        private readonly ILogger<AuthController> _logger;
//        private readonly IConfiguration _configuration; // <-- أضفناه هنا

//        public AuthController(
//            IAuthService authService,
//            IEmailService emailService,
//            UserManager<ApplicationUser> userManager,
//            HealthCarePlusContext context,
//            SignInManager<ApplicationUser> signInManager,
//            ILogger<AuthController> logger,
//            IConfiguration configuration) // <-- أضفناه في الـ Constructor
//        {
//            _authService = authService;
//            _emailService = emailService;
//            _userManager = userManager;
//            _context = context;
//            _signInManager = signInManager;
//            _logger = logger;
//            _configuration = configuration; // <-- خزّنه
//        }

//        // ====================== REGISTER ======================
//        [HttpPost("register")]
//        public async Task<IActionResult> Register([FromForm] RegisterRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var result = await _authService.RegisterAsync(request);
//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = string.Join(", ", result.Errors) });

//            return Ok(new { success = true, data = new { message = "User registered successfully" } });
//        }

//        // ====================== LOGIN ======================
//        [HttpPost("login")]
//        public async Task<IActionResult> Login([FromBody] LoginRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
//            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

//            var result = await _authService.LoginAsync(request, deviceInfo, ipAddress, _emailService);

//            if (result.Error == "MFA_OTP_SENT")
//                return Ok(new { success = true, requiresMfa = true, message = "Check your email for the login code" });

//            if (result.AccessToken == null)
//                return Unauthorized(new { success = false, error = result.Error });

//            Response.Cookies.Append("refresh_token", result.RefreshToken, new CookieOptions
//            {
//                HttpOnly = true,
//                Secure = true,
//                SameSite = SameSiteMode.Strict,
//                Expires = DateTimeOffset.UtcNow.AddDays(7)
//            });

//            return Ok(new { success = true, data = new { accessToken = result.AccessToken, refreshToken = result.RefreshToken } });
//        }

//        // ====================== GOOGLE LOGIN CHALLENGE ======================
//        [HttpGet("external-login")]
//        public IActionResult ExternalLogin([FromQuery] string provider = "Google", [FromQuery] string? returnUrl = null)
//        {
//            var host = Request.Headers["X-Forwarded-Host"].FirstOrDefault() ?? Request.Host.Value;
//            var scheme = Request.Headers["X-Forwarded-Proto"].FirstOrDefault() ?? Request.Scheme;
//            var callbackUrl = $"{scheme}://{host}/api/auth/external-callback";

//            var properties = _signInManager.ConfigureExternalAuthenticationProperties(provider, callbackUrl);
//            properties.Items["scheme"] = provider;

//            return Challenge(properties, provider);
//        }

//        // ====================== GOOGLE CALLBACK ======================
//        [HttpGet("external-callback")]
//        public async Task<IActionResult> ExternalCallback([FromQuery] string? returnUrl = null)
//        {
//            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "Google Login";
//            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

//            var result = await _authService.ExternalLoginAsync(deviceInfo, ipAddress);

//            if (!string.IsNullOrEmpty(result.Error))
//                return BadRequest(new { success = false, error = result.Error });

//            Response.Cookies.Append("refresh_token", result.RefreshToken, new CookieOptions
//            {
//                HttpOnly = true,
//                Secure = true,
//                SameSite = SameSiteMode.None,
//                Expires = DateTimeOffset.UtcNow.AddDays(7)
//            });

//            return Ok(new { success = true, data = new { accessToken = result.AccessToken, refreshToken = result.RefreshToken } });
//        }

//        // ====================== REFRESH TOKEN ======================
//        [HttpPost("refresh-token")]
//        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
//            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

//            var result = await _authService.RefreshTokenAsync(request, deviceInfo, ipAddress);
//            if (!string.IsNullOrEmpty(result.Error))
//                return Unauthorized(new { success = false, error = result.Error });

//            Response.Cookies.Append("refresh_token", result.RefreshToken, new CookieOptions
//            {
//                HttpOnly = true,
//                Secure = true,
//                SameSite = SameSiteMode.Strict,
//                Expires = DateTimeOffset.UtcNow.AddDays(7)
//            });

//            return Ok(new { success = true, data = new { accessToken = result.AccessToken, refreshToken = result.RefreshToken } });
//        }

//        // ====================== LOGOUT ======================
//        [HttpPost("logout")]
//        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var result = await _authService.LogoutAsync(request);
//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = result.Error });

//            Response.Cookies.Delete("refresh_token");
//            return Ok(new { success = true, data = new { message = "Logout successful" } });
//        }

//        // ====================== ENABLE MFA ======================
//        [Authorize]
//        [HttpPost("enable-2fa")]
//        public async Task<IActionResult> EnableMfa()
//        {
//            var userIdClaim = User.FindFirst("UserID")?.Value;
//            if (!int.TryParse(userIdClaim, out int userId))
//                return Unauthorized(new { success = false, error = "Invalid user" });

//            var result = await _authService.EnableMfaAsync(userId, _emailService);

//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = result.Error });

//            return Ok(new { success = true, data = new { message = result.Message } });
//        }

//        // ====================== VERIFY MFA ======================
//        [Authorize]
//        [HttpPost("verify-2fa")]
//        public async Task<IActionResult> VerifyMfa([FromBody] VerifyMfaRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var userIdClaim = User.FindFirst("UserID")?.Value;
//            if (!int.TryParse(userIdClaim, out int userId))
//                return Unauthorized(new { success = false, error = "Invalid user" });

//            var result = await _authService.VerifyMfaAsync(userId, request.OtpCode);
//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = result.Error });

//            return Ok(new { success = true, data = new { message = "MFA verified successfully" } });
//        }

//        // ====================== RESEND OTP ======================
//        [Authorize]
//        [HttpPost("resend-otp")]
//        public async Task<IActionResult> ResendOtp()
//        {
//            var userIdClaim = User.FindFirst("UserID")?.Value;
//            if (!int.TryParse(userIdClaim, out int userId))
//                return Unauthorized();

//            var user = await _userManager.FindByIdAsync(userId.ToString());
//            if (user == null) return NotFound();

//            await _authService.GenerateAndSendOtpAsync(user, _emailService);
//            return Ok(new { success = true, message = "New OTP sent to your email" });
//        }

//        // ====================== REGISTER PASSKEY ======================
//        [Authorize]
//        [HttpPost("register-passkey")]
//        public async Task<IActionResult> RegisterPasskey([FromBody] PasskeyRegisterRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var userIdClaim = User.FindFirst("UserID")?.Value;
//            if (!int.TryParse(userIdClaim, out int userId))
//                return Unauthorized(new { success = false, error = "Invalid user" });

//            var result = await _authService.RegisterPasskeyAsync(userId, request.CredentialId, request.PublicKey);
//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = result.Error });

//            return Ok(new { success = true, data = new { message = "Passkey registered successfully" } });
//        }

//        // ====================== LOGIN WITH PASSKEY ======================
//        [HttpPost("login-passkey")]
//        public async Task<IActionResult> LoginPasskey([FromBody] PasskeyLoginRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });

//            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
//            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

//            var result = await _authService.LoginWithPasskeyAsync(request, deviceInfo, ipAddress);
//            if (result.AccessToken == null)
//                return Unauthorized(new { success = false, error = result.Error });

//            Response.Cookies.Append("refresh_token", result.RefreshToken, new CookieOptions
//            {
//                HttpOnly = true,
//                Secure = true,
//                SameSite = SameSiteMode.Strict,
//                Expires = DateTimeOffset.UtcNow.AddDays(7)
//            });

//            return Ok(new { success = true, data = new { accessToken = result.AccessToken, refreshToken = result.RefreshToken } });
//        }

//        // ====================== GENERATE PASSKEY CHALLENGE ======================
//        [Authorize]
//        [HttpPost("generate-passkey-challenge")]
//        public async Task<IActionResult> GeneratePasskeyChallenge([FromBody] GenerateChallengeRequest request)
//        {
//            if (!ModelState.IsValid || string.IsNullOrEmpty(request?.UserId))
//                return BadRequest(new { success = false, error = "Invalid request data" });

//            var userIdClaim = User.FindFirst("UserID")?.Value;
//            if (userIdClaim != request.UserId)
//                return Unauthorized(new { success = false, error = "Invalid user" });

//            var challenge = await _authService.GeneratePasskeyChallengeAsync(request.UserId);
//            return Ok(new { success = true, data = new { challenge } });
//        }

//        // ====================== FORGOT PASSWORD ======================
//        [HttpPost("forgot-password")]
//        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid email", details = ModelState });

//            var origin = _configuration["AppUrl"]
//                         ?? Request.Headers["Origin"].FirstOrDefault()
//                         ?? "http://localhost:3000";

//            var result = await _authService.ForgotPasswordAsync(request.Email, origin);

//            if (!result.Succeeded)
//                return StatusCode(500, new { success = false, error = result.Error });

//            return Ok(new
//            {
//                success = true,
//                message = "If your email is registered, a password reset link has been sent."
//            });
//        }

//        // ====================== RESET PASSWORD ======================
//        [HttpPost("reset-password")]
//        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
//        {
//            if (!ModelState.IsValid)
//                return BadRequest(new { success = false, error = "Invalid data", details = ModelState });

//            var result = await _authService.ResetPasswordAsync(request);

//            if (!result.Succeeded)
//                return BadRequest(new { success = false, error = result.Error });

//            return Ok(new
//            {
//                success = true,
//                message = "Password reset successfully. You can now log in with your new password."
//            });
//        }

//        // ====================== INNER CLASS ======================
//        public class GenerateChallengeRequest
//        {
//            public string UserId { get; set; } = null!;
//        }
//    }
//}