using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Models.DTOs.AuthModels; // ← هنا
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;
using HealthCare_.Models.sharedModels;

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

        public MfaController(
            IMfaService mfaService,
            IEmailService emailService,
            UserManager<ApplicationUser> userManager)
        {
            _mfaService = mfaService;
            _emailService = emailService;
            _userManager = userManager;
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
        public async Task<IActionResult> Verify([FromBody] VerifyMfaRequest request) // ← من Models
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var result = await _mfaService.VerifyMfaAsync(userId, request.OtpCode);
            return result.Succeeded
                ? Ok(new { success = true })
                : BadRequest(new { success = false, error = result.Error });
        }

        [HttpPost("resend")]
        public async Task<IActionResult> Resend()
        {
            var userId = GetUserId();
            if (userId == 0) return Unauthorized();

            var user = await _userManager.FindByIdAsync(userId.ToString());
            if (user == null) return NotFound();

            await _mfaService.GenerateAndSendOtpAsync(user, _emailService);
            return Ok(new { success = true, message = "OTP sent" });
        }

        private int GetUserId() =>
            int.TryParse(User.FindFirst("UserID")?.Value, out int id) ? id : 0;
    }
}