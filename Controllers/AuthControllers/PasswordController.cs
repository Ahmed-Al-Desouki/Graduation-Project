using HealthCare_.Models.DTOs.ForgetPassword;
using HealthCare_.Services.Auth.Interfaces;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/password")]
    public class PasswordController : ControllerBase
    {
        private readonly IPasswordService _passwordService;
        private readonly IConfiguration _configuration;

        public PasswordController(
            IPasswordService passwordService,
            IConfiguration configuration)
        {
            _passwordService = passwordService;
            _configuration = configuration;
        }

        [HttpPost("forgot")]
        public async Task<IActionResult> Forgot([FromBody] ForgotPasswordRequest request) 
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var origin = _configuration["AppUrl"]
                         ?? Request.Headers["Origin"].FirstOrDefault()
                         ?? "http://localhost:3000";

            var result = await _passwordService.ForgotPasswordAsync(request.Email, origin);
            return result.Succeeded
                ? Ok(new { success = true, message = "Check your email" })
                : StatusCode(500, new { success = false, error = result.Error });
        }

        [HttpPost("reset")]
        public async Task<IActionResult> Reset([FromBody] ResetPasswordRequest request) 
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var result = await _passwordService.ResetPasswordAsync(request);
            return result.Succeeded
                ? Ok(new { success = true, message = "Password reset" })
                : BadRequest(new { success = false, error = result.Error });
        }
    }
}