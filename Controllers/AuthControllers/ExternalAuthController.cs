using HealthCare_.Models.sharedModels;
using HealthCare_.Services.Auth;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ExternalAuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly AuthCoreService _authCoreService;
        private readonly IEmailService _emailService;

        public ExternalAuthController(
            UserManager<ApplicationUser> userManager,
            AuthCoreService authCoreService,
            IEmailService emailService)
        {
            _userManager = userManager;
            _authCoreService = authCoreService;
            _emailService = emailService;
        }

        // Endpoint Flutter بعد ما يحصل Google login
        [HttpPost("google-login")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequest request)
        {
            if (request == null || string.IsNullOrEmpty(request.IdToken))
                return BadRequest(new { error = "Invalid request" });

            // 1. تحقق من Google token (Firebase أو Google API)
            var payload = await GoogleTokenValidator.ValidateAsync(request.IdToken);
            if (payload == null)
                return BadRequest(new { error = "Invalid Google token" });

            // 2. تحقق من وجود المستخدم
            var email = payload.Email!;
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    EmailConfirmed = true
                };
                await _userManager.CreateAsync(user);
            }

            // 3. احصل على Device info و IP
            var deviceInfo = Request.Headers["User-Agent"].ToString() ?? "unknown";
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            // 4. استخدم AuthCoreService لل unified login flow
            var result = await _authCoreService.ExternalLoginAsync(user, deviceInfo, ipAddress, _emailService);

            // 5. تحقق من MFA
            if (result.Error?.StartsWith("MFA_PENDING|") == true)
            {
                var mfaToken = result.Error.AsSpan("MFA_PENDING|".Length).ToString();
                return Ok(new
                {
                    success = true,
                    status = "pending",
                    requiresMfa = true,
                    mfaToken
                });
            }

            // 6. Return tokens لل Flutter
            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
        }
    }

    // DTO for Google login request
    public class GoogleLoginRequest
    {
        public string IdToken { get; set; } = string.Empty;
    }

    // Fake Google token validator (استبدل بـ Firebase أو Google API)
    public static class GoogleTokenValidator
    {
        public static async Task<GooglePayload?> ValidateAsync(string idToken)
        {
            // هنا المفروض Flutter يبعت IdToken و إحنا نتحقق منه
            await Task.Delay(10); // محاكاة async
            return new GooglePayload { Email = "user@example.com" }; // مثال فقط
        }
    }

    public class GooglePayload
    {
        public string Email { get; set; } = string.Empty;
    }
}


//using HealthCare_.Models.sharedModels;
//using HealthCare_.Services.Auth.Interfaces;
//using Microsoft.AspNetCore.Authentication;
//using Microsoft.AspNetCore.Identity;
//using Microsoft.AspNetCore.Mvc;
//using System.Security.Claims;

//namespace HealthCare_.Controllers
//{
//    [ApiController]
//    [Route("api/auth/external")]
//    public class ExternalAuthController : ControllerBase
//    {
//        private readonly SignInManager<ApplicationUser> _signInManager;
//        private readonly UserManager<ApplicationUser> _userManager;
//        private readonly ITokenService _tokenService;

//        public ExternalAuthController(
//            SignInManager<ApplicationUser> signInManager,
//            UserManager<ApplicationUser> userManager,
//            ITokenService tokenService)
//        {
//            _signInManager = signInManager;
//            _userManager = userManager;
//            _tokenService = tokenService;
//        }

//        [HttpGet("login")]
//        public IActionResult Login([FromQuery] string provider = "Google")
//        {
//            var redirectUrl = "https://nonvolitional-unstuccoed-wilfred.ngrok-free.dev/api/auth/external/callback";

//            var properties = _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);
//            properties.RedirectUri = redirectUrl; // مهم جدًا

//            return new ChallengeResult(provider, properties);
//        }
//        [HttpGet("callback")]
//        public async Task<IActionResult> Callback()
//        {
//            var info = await _signInManager.GetExternalLoginInfoAsync();
//            if (info == null)
//            {
//                return StatusCode(500, new { error = "External login failed", details = "State missing or invalid." });
//            }

//            var email = info.Principal.FindFirstValue(ClaimTypes.Email);
//            if (string.IsNullOrEmpty(email))
//                return BadRequest("Email not provided");

//            var user = await _userManager.FindByEmailAsync(email);
//            if (user == null)
//            {
//                user = new ApplicationUser { UserName = email, Email = email, EmailConfirmed = true };
//                var result = await _userManager.CreateAsync(user);
//                if (!result.Succeeded) return BadRequest(result.Errors);
//            }

//            var token = _tokenService.GenerateJwtToken(user);
//            return Ok(new { success = true, accessToken = token });
//        }
//    }
//}


