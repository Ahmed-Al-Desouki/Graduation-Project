using global::WelloraHealthCareManagement.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagment.API.Controller.Authintecation
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MfaController : ControllerBase
    {
        private readonly IMfaService _mfaService;
        private readonly ITokenService _tokenService;
        private readonly ILogger<MfaController> _logger;

        public MfaController(
            IMfaService mfaService,
            ITokenService tokenService,
            ILogger<MfaController> logger)
        {
            _mfaService = mfaService;
            _tokenService = tokenService;
            _logger = logger;
        }

        [HttpPost("enable")]
        public async Task<IActionResult> EnableMfa()
        {
            var userId = GetUserId();
            if (userId == 0)
                return Unauthorized();

            var (succeeded, message, error) = await _mfaService.EnableMfaAsync(userId);

            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true, message });
        }

        [HttpPost("verify")]
        public async Task<IActionResult> VerifyMfa([FromBody] VerifyMfaRequest request)
        {
            var userId = GetUserId();
            if (userId == 0)
                return Unauthorized();

            var (succeeded, error) = await _mfaService.VerifyOtpAsync(userId, request.OtpCode);

            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new { success = true });
        }

        [HttpPost("resend")]
        [AllowAnonymous]
        public async Task<IActionResult> ResendOtp([FromBody] ResendMfaRequest request)
        {
            // Validate MFA token
            var principal = _tokenService.ValidateJwtToken(request.MfaToken);
            if (principal == null)
            {
                return Unauthorized(new { success = false, error = "Invalid or expired MFA token" });
            }

            var userIdClaim = principal.FindFirst("UserID")?.Value;
            if (!int.TryParse(userIdClaim, out int userId))
            {
                return Unauthorized(new { success = false, error = "Invalid token" });
            }

            var (succeeded, error) = await _mfaService.ResendOtpAsync(userId);
            if (!succeeded)
            {
                return BadRequest(new { success = false, error });
            }

            return Ok(new { success = true, message = "OTP sent again" });
        }

        private int GetUserId()
        {
            var claim = User.FindFirst("UserID") ?? User.FindFirst(ClaimTypes.NameIdentifier);
            return int.TryParse(claim?.Value, out int id) ? id : 0;
        }
    }

    // DTOs
    public class VerifyMfaRequest
    {
        public string OtpCode { get; set; } = string.Empty;
    }

    public class ResendMfaRequest
    {
        public string MfaToken { get; set; } = string.Empty;
    }
}
