using HealthCare_.Models.DTOs.AuthModels.ForgetPassword;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagement.API.Controllers.Authintecation
{
    [ApiController]
    [Route("api/[controller]")]
    public class PasswordController : ControllerBase
    {
        private readonly IPasswordService _passwordService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<PasswordController> _logger;

        public PasswordController(
            IPasswordService passwordService,
            IConfiguration configuration,
            ILogger<PasswordController> logger)
        {
            _passwordService = passwordService;
            _configuration = configuration;
            _logger = logger;
        }

        [HttpPost("forgot")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            //  Get origin in this order:
            // 1. AppUrl from config (production URL)
            // 2. Origin header from request
            // 3. Fallback
            var origin = _configuration["AppUrl"]
                         ?? Request.Headers["Origin"].FirstOrDefault()
                         ?? "https://medicare-plus.runasp.net";

            _logger.LogInformation("ForgotPassword: Using origin: {Origin}", origin);

            var (succeeded, error) = await _passwordService.ForgotPasswordAsync(request.Email, origin);

            if (!succeeded)
                return StatusCode(500, new { success = false, error });

            return Ok(new
            {
                success = true,
                message = "If your email exists in our system, you will receive a password reset link."
            });
        }

        [HttpPost("reset")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var (succeeded, error) = await _passwordService.ResetPasswordAsync(request);

            if (!succeeded)
                return BadRequest(new { success = false, error });

            return Ok(new
            {
                success = true,
                message = "Password has been reset successfully. Please login with your new password."
            });
        }
    }
}