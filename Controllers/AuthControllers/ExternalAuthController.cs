using HealthCare_.Models.sharedModels;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/auth/external")]
    public class ExternalAuthController : ControllerBase
    {
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly ITokenService _tokenService;

        public ExternalAuthController(
            SignInManager<ApplicationUser> signInManager,
            UserManager<ApplicationUser> userManager,
            ITokenService tokenService)
        {
            _signInManager = signInManager;
            _userManager = userManager;
            _tokenService = tokenService;
        }

        [HttpGet("login")]
        public IActionResult Login([FromQuery] string provider = "Google")
        {
            var redirectUrl = "https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/auth/external/callback";

            var properties = _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);
            properties.RedirectUri = redirectUrl; // مهم جدًا

            return new ChallengeResult(provider, properties);
        }
        [HttpGet("callback")]
        public async Task<IActionResult> Callback()
        {
            var info = await _signInManager.GetExternalLoginInfoAsync();
            if (info == null)
            {
                return StatusCode(500, new { error = "External login failed", details = "State missing or invalid." });
            }

            var email = info.Principal.FindFirstValue(ClaimTypes.Email);
            if (string.IsNullOrEmpty(email))
                return BadRequest("Email not provided");

            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser { UserName = email, Email = email, EmailConfirmed = true };
                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded) return BadRequest(result.Errors);
            }

            var token = _tokenService.GenerateJwtToken(user);
            return Ok(new { success = true, accessToken = token });
        }
    }
}