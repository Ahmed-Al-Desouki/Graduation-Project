using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (succeeded, errors) = await _authService.RegisterAsync(request);
            if (!succeeded) return BadRequest(new { errors });

            return Ok(new { message = "User registered successfully" });
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();

            var (accessToken, refreshToken, error) = await _authService.RefreshTokenAsync(request, deviceInfo, ipAddress);
            if (accessToken == null)
                return Unauthorized(new { error });

            return Ok(new
            {
                accessToken,
                refreshToken
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString();

            var (accessToken, refreshToken, error) = await _authService.LoginAsync(request, deviceInfo, ipAddress);
            if (accessToken == null) return Unauthorized(new { error });

            return Ok(new
            {
                accessToken,
                refreshToken
            });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            var (succeeded, error) = await _authService.LogoutAsync(request);
            if (!succeeded)
                return BadRequest(new { error });

            return Ok(new { message = "Logout successful" });
        }
    }

}
