using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Services.SharedService;
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

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (accessToken, refreshToken, error) = await _authService.LoginAsync(request);
            if (accessToken == null) return Unauthorized(new { error });

            return Ok(new
            {
                accessToken,
                refreshToken
            });
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> Refresh([FromBody] RefreshRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (newAccessToken, newRefreshToken, error) = await _authService.RefreshTokenAsync(request);
            if (newAccessToken == null) return Unauthorized(new { error });

            return Ok(new
            {
                accessToken = newAccessToken,
                refreshToken = newRefreshToken
            });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout([FromBody] LogoutRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (succeeded, error) = await _authService.LogoutAsync(request);
            if (!succeeded) return BadRequest(new { error });

            return Ok(new { message = "Logout successful" });
        }
    }
}
