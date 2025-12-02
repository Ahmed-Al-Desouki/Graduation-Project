using HealthCare_.Models.DTOs.AuthModels.Login_register;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Authorization;

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
            if (!ModelState.IsValid)
                return BadRequest(ModelState);
            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var result = await _authCoreService.LoginAsync(request, deviceInfo, ipAddress, _emailService);

            // ===  MFA_PENDING| ===
            if (result.Error?.StartsWith("MFA_PENDING|") == true)
            {
                var mfaToken = result.Error.AsSpan("MFA_PENDING|".Length).ToString();
                return Ok(new
                {
                    success = true,
                    status = "pending",
                    requiresMfa = true,
                    mfaToken = mfaToken,
                    message = "Check your email for the login code"
                });
            }

            if (result.AccessToken == null)
                return Ok(new { success = false, error = result.Error });

            SetRefreshTokenCookie(result.RefreshToken);
            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
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
            var userIdClaim = User.FindFirst("UserID")?.Value;
            var jti = User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;

            if (!int.TryParse(userIdClaim, out int userId) || string.IsNullOrEmpty(jti))
                return Unauthorized();

            request.UserId = userId;
            request.Jti = jti;

            var result = await _authCoreService.LogoutAsync(request);
            return result.Succeeded
                ? Ok(new { success = true })
                : BadRequest(new { success = false, error = result.Error });
        }

        [HttpGet("token-status-v2")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTokenStatusV2(
            [FromHeader] string? Authorization,
            [FromHeader] string? RefreshToken)
        {
            var accessToken = Authorization?.StartsWith("Bearer ") == true
                ? Authorization["Bearer ".Length..].Trim()
                : null;

            var refreshTokenHeader = RefreshToken; // من Header: RefreshToken: abc123
            var refreshTokenCookie = Request.Cookies["refresh_token"];

            var refreshToken = refreshTokenHeader ?? refreshTokenCookie;

            var accessResult = new TokenCheckResult { Type = "access", Valid = false };
            var refreshResult = new TokenCheckResult { Type = "refresh", Valid = false };

            // === 1. فحص Access Token ===
            if (!string.IsNullOrEmpty(accessToken))
            {
                var principal = _tokenService.ValidateJwtToken(accessToken);
                if (principal != null)
                {
                    var jti = principal.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
                    var expClaim = principal.FindFirst("exp")?.Value;

                    if (long.TryParse(expClaim, out long exp))
                    {
                        var expiry = DateTimeOffset.FromUnixTimeSeconds(exp);
                        var now = DateTime.UtcNow;

                        accessResult.Valid = expiry > now;
                        accessResult.ExpiresAt = expiry.UtcDateTime;
                        accessResult.ExpiresIn = (int)(expiry - now).TotalSeconds;

                        if (accessResult.Valid && !string.IsNullOrEmpty(jti))
                        {
                            var isRevoked = await _context.RevokedTokens
                                .AnyAsync(rt => rt.Jti == jti && rt.Expires > now);
                            accessResult.Valid = !isRevoked;
                            accessResult.Revoked = isRevoked;
                        }
                    }
                }
            }

            // === 2. فحص Refresh Token ===
            if (!string.IsNullOrEmpty(refreshToken))
            {
                var hash = _tokenService.ComputeHmacSha256Base64(refreshToken);
                var stored = await _context.RefreshTokens
                    .Include(rt => rt.UserSession)
                    .FirstOrDefaultAsync(rt => rt.Token == hash);

                if (stored != null && !stored.IsRevoked && !stored.IsUsed && stored.Expires > DateTime.UtcNow)
                {
                    refreshResult.Valid = true;
                    refreshResult.ExpiresAt = stored.Expires;
                    refreshResult.ExpiresIn = (int)(stored.Expires - DateTime.UtcNow).TotalSeconds;
                }
                else
                {
                    refreshResult.Reason = stored == null ? "not_found" :
                                          stored.IsRevoked ? "revoked" :
                                          stored.IsUsed ? "used" : "expired";
                }
            }

            // === 3. النتيجة ===
            var results = new List<TokenCheckResult>();
            if (accessToken != null) results.Add(accessResult);
            if (refreshToken != null) results.Add(refreshResult);

            return Ok(new
            {
                checkedAt = DateTime.UtcNow,
                tokens = results.Any() ? results : null,
                summary = results.Any() ?
                    (results.All(r => r.Valid) ? "all_valid" :
                     results.Any(r => r.Valid) ? "partially_valid" : "all_invalid")
                    : "no_tokens_provided"
            });
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