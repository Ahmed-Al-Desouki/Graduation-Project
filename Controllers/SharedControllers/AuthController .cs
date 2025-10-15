using HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys;
using Microsoft.AspNetCore.Authorization;
using QRCoder;


namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly HealthCarePlusContext _context;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, HealthCarePlusContext context, ILogger<AuthController> logger)
        {
            _authService = authService;
            _context = context;
            _logger = logger;
        }

        /// Registers a new user.
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Register failed: Invalid model state for email: {Email}", request?.Email);
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var (succeeded, errors) = await _authService.RegisterAsync(request);
            if (!succeeded)
            {
                _logger.LogWarning("Register failed for email: {Email}, errors: {Errors}", request?.Email, string.Join(", ", errors));
                return BadRequest(new { success = false, error = string.Join(", ", errors) });
            }

            _logger.LogInformation("User registered successfully for email: {Email}", request?.Email);
            return Ok(new { success = true, data = new { message = "User registered successfully" } });
        }

        /// Logs in a user and returns access and refresh tokens.
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Login failed: Invalid model state for email: {Email}", request?.Email);
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.LoginAsync(request, deviceInfo, ipAddress);
            if (accessToken == null)
            {
                _logger.LogWarning("Login failed for email: {Email}, error: {Error}", request?.Email, error);
                return Unauthorized(new { success = false, error });
            }

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            _logger.LogInformation("Login successful for email: {Email}", request?.Email);
            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }


        /// Refreshes access token using a refresh token.
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("RefreshToken failed: Invalid model state");
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.RefreshTokenAsync(request, deviceInfo, ipAddress);
            if (!string.IsNullOrEmpty(error))
            {
                _logger.LogWarning("RefreshToken failed: {Error}", error);
                return Unauthorized(new { success = false, error });
            }

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            _logger.LogInformation("RefreshToken successful");
            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }


        /// Logs out a user and invalidates their session.
        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Logout failed: Invalid model state for userId: {UserId}", request?.UserId);
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var (succeeded, error) = await _authService.LogoutAsync(request);
            if (!succeeded)
            {
                _logger.LogWarning("Logout failed for userId: {UserId}, error: {Error}", request?.UserId, error);
                return BadRequest(new { success = false, error });
            }

            Response.Cookies.Delete("refresh_token");
            _logger.LogInformation("Logout successful for userId: {UserId}", request?.UserId);
            return Ok(new { success = true, data = new { message = "Logout successful" } });
        }

        /// Enables MFA for a user and returns QR code image and recovery codes.
        [Authorize]
        [HttpPost("enable-mfa")]
        public async Task<IActionResult> EnableMfa()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
            {
                _logger.LogWarning("EnableMfa failed: Invalid user ID in token");
                return Unauthorized(new { success = false, error = "Invalid user" });
            }

            var (succeeded, qrCodeUrl, recoveryCodes, error) = await _authService.EnableMfaAsync(userId);
            if (!succeeded)
            {
                _logger.LogWarning("EnableMfa failed for userId: {UserId}, error: {Error}", userId, error);
                return BadRequest(new { success = false, error });
            }

            // Generate QR Code image
            using var qrGenerator = new QRCodeGenerator();
            var qrCodeData = qrGenerator.CreateQrCode(qrCodeUrl, QRCodeGenerator.ECCLevel.Q);
            using var qrCode = new PngByteQRCode(qrCodeData);
            var qrCodeImage = qrCode.GetGraphic(20);
            var qrCodeBase64 = Convert.ToBase64String(qrCodeImage);

            _logger.LogInformation("MFA enabled successfully for userId: {UserId}", userId);
            return Ok(new { success = true, data = new { qrCodeImage = qrCodeBase64, recoveryCodes } });
        }

        /// Verifies an MFA OTP code for a user.
        [Authorize]
        [HttpPost("verify-mfa")]
        public async Task<IActionResult> VerifyMfa([FromBody] VerifyMfaRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("VerifyMfa failed: Invalid model state");
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
            {
                _logger.LogWarning("VerifyMfa failed: Invalid user ID in token");
                return Unauthorized(new { success = false, error = "Invalid user" });
            }

            var (succeeded, error) = await _authService.VerifyMfaAsync(userId, request.OtpCode);
            if (!succeeded)
            {
                _logger.LogWarning("VerifyMfa failed for userId: {UserId}, error: {Error}", userId, error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("MFA verified successfully for userId: {UserId}", userId);
            return Ok(new { success = true, data = new { message = "MFA verified successfully" } });
        }

        /// Registers a passkey for a user.
        [Authorize]
        [HttpPost("register-passkey")]
        public async Task<IActionResult> RegisterPasskey([FromBody] PasskeyRegisterRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("RegisterPasskey failed: Invalid model state");
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
            {
                _logger.LogWarning("RegisterPasskey failed: Invalid user ID in token");
                return Unauthorized(new { success = false, error = "Invalid user" });
            }

            var (succeeded, error) = await _authService.RegisterPasskeyAsync(userId, request.CredentialId, request.PublicKey);
            if (!succeeded)
            {
                _logger.LogWarning("RegisterPasskey failed for userId: {UserId}, error: {Error}", userId, error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("Passkey registered successfully for userId: {UserId}", userId);
            return Ok(new { success = true, data = new { message = "Passkey registered successfully" } });
        }


        /// Logs in a user using a passkey.
        [HttpPost("login-passkey")]
        public async Task<IActionResult> LoginPasskey([FromBody] PasskeyLoginRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("LoginPasskey failed: Invalid model state");
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var (accessToken, refreshToken, error) = await _authService.LoginWithPasskeyAsync(request, deviceInfo, ipAddress);
            if (accessToken == null)
            {
                _logger.LogWarning("LoginPasskey failed: {Error}", error);
                return Unauthorized(new { success = false, error });
            }

            Response.Cookies.Append("refresh_token", refreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            _logger.LogInformation("LoginPasskey successful for credentialId: {CredentialId}", request?.CredentialId);
            return Ok(new { success = true, data = new { accessToken, refreshToken } });
        }


        /// Retrieves all roles (Admin only).
        [HttpGet("roles")]
        [Authorize(Policy = "RequireAdmin")]
        public async Task<IActionResult> GetRoles()
        {
            var userId = User.FindFirst("UserID")?.Value ?? "Unknown";
            _logger.LogInformation("GetRoles called by user: {UserId}", userId);

            var roles = await _context.Roles
                .Select(r => new { r.Id, r.Name, r.Description })
                .ToListAsync();

            return Ok(new { success = true, data = roles });
        }


        /// Creates a new role (Admin only).
        [HttpPost("create-role")]
        [Authorize(Policy = "RequireAdmin")]
        public async Task<IActionResult> CreateRole([FromBody] CreateRoleRequest request)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("CreateRole failed: Invalid model state for roleName: {RoleName}", request?.RoleName);
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var userId = User.FindFirst("UserID")?.Value ?? "Unknown";
            _logger.LogInformation("CreateRole called by user: {UserId} with role: {RoleName}", userId, request?.RoleName);

            var (succeeded, roleId, error) = await _authService.CreateRoleAsync(request.RoleName, request.Description);
            if (!succeeded)
            {
                _logger.LogWarning("CreateRole failed for roleName: {RoleName}, error: {Error}", request?.RoleName, error);
                return BadRequest(new { success = false, error });
            }

            _logger.LogInformation("Role created successfully: {RoleName} with Id: {RoleId}", request?.RoleName, roleId);
            return Ok(new { success = true, data = new { roleId } });
        }

        /// Generates a passkey challenge for a user.
        [Authorize]
        [HttpPost("generate-passkey-challenge")]
        public async Task<IActionResult> GeneratePasskeyChallenge([FromBody] GenerateChallengeRequest request)
        {
            if (!ModelState.IsValid || string.IsNullOrEmpty(request?.UserId))
            {
                _logger.LogWarning("GeneratePasskeyChallenge failed: Invalid model state or userId");
                return BadRequest(new { success = false, error = "Invalid request data", details = ModelState });
            }

            var userIdClaim = User.FindFirst("UserID")?.Value;
            if (userIdClaim != request.UserId)
            {
                _logger.LogWarning("GeneratePasskeyChallenge failed: Token userId {TokenUserId} does not match request userId {RequestUserId}", userIdClaim, request.UserId);
                return Unauthorized(new { success = false, error = "Invalid user" });
            }

            var challenge = await _authService.GeneratePasskeyChallengeAsync(request.UserId);
            _logger.LogInformation("Passkey challenge generated for userId: {UserId}", request.UserId);
            return Ok(new { success = true, data = new { challenge } });
        }
    }

    public class CreateRoleRequest
    {
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
    }

    public class GenerateChallengeRequest
    {
        public string UserId { get; set; } = null!;
    }
}