using Google.Apis.Auth.OAuth2.Requests;
using HealthCare_.Models.AuthModels;
using HealthCare_.Models.DTOs.AuthModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using WelloraHealthCareManagement.Infrastructure.Services;
using WelloraHealthCareManagment.Application.DTOs.AuthModels.Login_register.Tokens;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;

namespace WelloraHealthCareManagement.API.Controllers.Authintecation
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthCoreService _authService;
        private readonly ITokenService _tokenService;
        private readonly ILogger<AuthController> _logger;
        private readonly IDeviceService _deviceService;
        private readonly IRevokedTokenRepository _revokedTokenRepository;

        public AuthController(
            IAuthCoreService authService,
            ITokenService tokenService,
            IDeviceService deviceService,
            IRevokedTokenRepository revokedTokenRepository,
            ILogger<AuthController> logger)
        {
            _authService = authService;
            _tokenService = tokenService;
            _logger = logger;
            _deviceService = deviceService;
            _revokedTokenRepository = revokedTokenRepository;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromForm] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (succeeded, errors) = await _authService.RegisterAsync(request);

            if (!succeeded)
                return BadRequest(new { success = false, errors });

            return Ok(new { success = true, message = "User registered successfully" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var result = await _authService.LoginAsync(request, deviceInfo, ipAddress);

            // Handle MFA required
            if (result.RequiresMfa)
            {
                return Ok(new
                {
                    success = true,
                    status = "pending",
                    requiresMfa = true,
                    mfaToken = result.MfaToken,
                    message = "Check your email for the login code"
                });
            }

            // Handle error
            if (!string.IsNullOrEmpty(result.Error))
            {
                return BadRequest(new { success = false, error = result.Error });
            }

            // Success
            SetRefreshTokenCookie(result.RefreshToken!);
            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var userIdClaim = User.FindFirst("UserID")?.Value;
            var jti = User.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;

            if (!int.TryParse(userIdClaim, out int userId) || string.IsNullOrEmpty(jti))
            {
                return Unauthorized();
            }

            var request = new LogoutRequest
            {
                UserId = userId,
                Jti = jti
            };

            var (succeeded, error) = await _authService.LogoutAsync(request);

            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true, message = "Logged out successfully" });
        }

        private void SetRefreshTokenCookie(string token)
        {
            Response.Cookies.Append("refresh_token", token, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTimeOffset.UtcNow.AddDays(30)
            });
        }
        #region helper endpoint auth
        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshRequest? request)
        {
            // Get refresh token from body or cookie
            var refreshToken = request?.RefreshToken ?? Request.Cookies["refresh_token"];

            if (string.IsNullOrEmpty(refreshToken))
            {
                return BadRequest(new { success = false, error = "Missing refresh token" });
            }

            // URL decode if needed
            refreshToken = Uri.UnescapeDataString(refreshToken);

            // Get device info
            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            // Create request
            var refreshRequest = new RefreshRequest
            {
                AccessToken = request?.AccessToken,
                RefreshToken = refreshToken
            };

            // Call service
            var result = await _tokenService.RefreshTokenAsync(refreshRequest, deviceInfo, ipAddress);

            if (!string.IsNullOrEmpty(result.Error))
            {
                return Unauthorized(new { success = false, error = result.Error });
            }

            // Update cookie
            SetRefreshTokenCookie(result.RefreshToken);

            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
        }

        [HttpGet("token-status-v2")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTokenStatusV2(
            [FromHeader(Name = "Authorization")] string? authorization,
            [FromHeader(Name = "RefreshToken")] string? refreshTokenHeader)
        {
            var accessToken = authorization?.StartsWith("Bearer ") == true
                ? authorization["Bearer ".Length..].Trim()
                : null;

            var refreshToken = refreshTokenHeader ?? Request.Cookies["refresh_token"];

            var results = new List<TokenCheckResult>();

            // Check Access Token
            if (!string.IsNullOrEmpty(accessToken))
            {
                var accessResult = await CheckAccessTokenAsync(accessToken);
                results.Add(accessResult);
            }

            // Check Refresh Token
            if (!string.IsNullOrEmpty(refreshToken))
            {
                var refreshResult = await CheckRefreshTokenAsync(refreshToken);
                results.Add(refreshResult);
            }

            var summary = results.Any() ?
                (results.All(r => r.Valid) ? "all_valid" :
                 results.Any(r => r.Valid) ? "partially_valid" : "all_invalid")
                : "no_tokens_provided";

            return Ok(new TokenStatusResponse
            {
                CheckedAt = DateTime.UtcNow,
                Tokens = results.Any() ? results : null,
                Summary = summary
            });
        }

        [HttpGet("devices")]
        [Authorize]
        public async Task<IActionResult> GetActiveDevices()
        {
            var userId = GetUserId();
            if (userId == 0)
                return Unauthorized();

            var currentDeviceInfo = Request.Headers["User-Agent"].ToString();
            var currentIp = HttpContext.Connection.RemoteIpAddress?.ToString();

            var result = await _deviceService.GetActiveDevicesAsync(userId, currentDeviceInfo, currentIp);

            return Ok(result);
        }

        [HttpPost("register-device")]
        [Authorize]
        public async Task<IActionResult> RegisterDevice([FromBody] RegisterDeviceRequest request)
        {
            var userId = GetUserId();
            if (userId == 0)
                return Unauthorized();

            var success = await _deviceService.RegisterDeviceAsync(userId, request.FcmToken);

            if (!success)
                return StatusCode(500, new { success = false, error = "Failed to register device" });

            return Ok(new { success = true });
        }

        [HttpDelete("unregister-device")]
        [Authorize]
        public async Task<IActionResult> UnregisterDevice([FromBody] RegisterDeviceRequest request)
        {
            var userId = GetUserId();
            if (userId == 0)
                return Unauthorized();

            var success = await _deviceService.UnregisterDeviceAsync(userId, request.FcmToken);

            if (!success)
                return StatusCode(500, new { success = false, error = "Failed to unregister device" });

            return Ok(new { success = true });
        }

        // ===== Private Helper Methods =====

        private int GetUserId()
        {
            var claim = User.FindFirst("UserID") ?? User.FindFirst(ClaimTypes.NameIdentifier);
            return int.TryParse(claim?.Value, out int id) ? id : 0;
        }

        private async Task<TokenCheckResult> CheckAccessTokenAsync(string accessToken)
        {
            var result = new TokenCheckResult { Type = "access", Valid = false };

            var principal = _tokenService.ValidateJwtToken(accessToken);
            if (principal != null)
            {
                var jti = principal.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
                var expClaim = principal.FindFirst("exp")?.Value;

                if (long.TryParse(expClaim, out long exp))
                {
                    var expiry = DateTimeOffset.FromUnixTimeSeconds(exp);
                    var now = DateTime.UtcNow;

                    result.Valid = expiry > now;
                    result.ExpiresAt = expiry.UtcDateTime;
                    result.ExpiresIn = (int)(expiry - now).TotalSeconds;

                    if (result.Valid && !string.IsNullOrEmpty(jti))
                    {
                        var isRevoked = await _revokedTokenRepository.IsTokenRevokedAsync(jti);
                        result.Valid = !isRevoked;
                        result.Revoked = isRevoked;
                    }
                }
            }

            return result;
        }

        private async Task<TokenCheckResult> CheckRefreshTokenAsync(string refreshToken)
        {
            var result = new TokenCheckResult { Type = "refresh", Valid = false };

            var hash = _tokenService.ComputeHmacSha256Base64(refreshToken);

            // You'll need to add a method to get refresh token by hash
            // For now, let's return a basic check
            // TODO: Implement proper refresh token validation

            return result;
        }
        #endregion
    }
}