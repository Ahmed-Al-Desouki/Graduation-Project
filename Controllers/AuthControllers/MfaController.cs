using HealthCare_.Interfaces.Email;
using HealthCare_.Interfaces.IAuth.MFA;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Authorization;

namespace HealthCare_.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/mfa")]
    public class MfaController : ControllerBase
    {
        private readonly IMfaService _mfaService;
        private readonly IEmailService _emailService;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IConfiguration _configuration;

        public MfaController(
            IMfaService mfaService,
            IEmailService emailService,
            UserManager<ApplicationUser> userManager,
            IConfiguration configuration)
        {
            _mfaService = mfaService;
            _emailService = emailService;
            _userManager = userManager;
            _configuration = configuration;
        }

        [HttpPost("enable")]
        public async Task<IActionResult> Enable()
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var result = await _mfaService.EnableMfaAsync(userId, _emailService);
            return result.Succeeded
                ? Ok(new { success = true, message = result.Message })
                : BadRequest(new { success = false, error = result.Error });
        }

        [HttpPost("verify")]
        public async Task<IActionResult> Verify([FromBody] VerifyMfaRequest request)
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var result = await _mfaService.VerifyMfaAsync(userId, request.OtpCode);
            return result.Succeeded
                ? Ok(new { success = true })
                : BadRequest(new { success = false, error = result.Error });
        }

        [HttpPost("resend")]
        [AllowAnonymous]
        public async Task<IActionResult> Resend([FromBody] ResendMfaRequest request)
        {
            //  تحقق من mfa_token (اللي رجع من Login)
            var principal = ValidateMfaToken(request.MfaToken);
            if (principal == null)
                return Unauthorized(new { success = false, error = "Invalid or expired token" });

            var userIdClaim = principal.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
                return Unauthorized();

            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null) return NotFound();

            await _mfaService.GenerateAndSendOtpAsync(user, _emailService);

            return Ok(new { success = true, message = "OTP sent again" });
        }

        private ClaimsPrincipal? ValidateMfaToken(string? token)
        {
            if (string.IsNullOrEmpty(token)) return null;

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]);

            try
            {
                return tokenHandler.ValidateToken(token, new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = _configuration["Jwt:Issuer"],
                    ValidAudience = _configuration["Jwt:Audience"],
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                }, out _);
            }
            catch
            {
                return null;
            }
        }

        private int GetUserId()
        {
            var claim = User.FindFirst("UserID") ?? User.FindFirst(ClaimTypes.NameIdentifier);
            return int.TryParse(claim?.Value, out int id) ? id : 0;
        }
    }
}