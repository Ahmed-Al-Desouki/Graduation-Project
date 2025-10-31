using Microsoft.AspNetCore.Mvc;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/auth/external")]
    public class ExternalAuthController : ControllerBase
    {
        private readonly IExternalAuthService _externalAuthService;
        private readonly SignInManager<ApplicationUser> _signInManager;

        public ExternalAuthController(
            IExternalAuthService externalAuthService,
            SignInManager<ApplicationUser> signInManager)
        {
            _externalAuthService = externalAuthService;
            _signInManager = signInManager;
        }

        [HttpGet("login")]
        public IActionResult Login([FromQuery] string provider = "Google")
        {
            var host = Request.Headers["X-Forwarded-Host"].FirstOrDefault() ?? Request.Host.Value;
            var scheme = Request.Headers["X-Forwarded-Proto"].FirstOrDefault() ?? Request.Scheme;
            var callbackUrl = $"{scheme}://{host}/api/auth/external/callback";

            var properties = _signInManager.ConfigureExternalAuthenticationProperties(provider, callbackUrl);
            return Challenge(properties, provider);
        }

        [HttpGet("callback")]
        public async Task<IActionResult> Callback()
        {
            var deviceInfo = Request.Headers["User-Agent"].FirstOrDefault() ?? "Google";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            var result = await _externalAuthService.ExternalLoginAsync(deviceInfo, ipAddress);
            if (!string.IsNullOrEmpty(result.Error))
                return BadRequest(new { success = false, error = result.Error });

            Response.Cookies.Append("refresh_token", result.RefreshToken, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.None,
                Expires = DateTimeOffset.UtcNow.AddDays(7)
            });

            return Ok(new { success = true, accessToken = result.AccessToken });
        }
    }
}