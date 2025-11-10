// File: Controllers/PasskeyController.cs
using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.DTOs.AuthModels.Login_register;
using HealthCare_.Services.Auth;
using HealthCare_.Services.Auth.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace HealthCare_.Controllers
{
    [ApiController]
    [Route("api/passkey")]
    public class PasskeyController : ControllerBase
    {
        private readonly IPasskeyService _passkeyService;
        private readonly ILogger<PasskeyController> _logger;

        public PasskeyController(IPasskeyService passkeyService, ILogger<PasskeyController> logger)
        {
            _passkeyService = passkeyService;
            _logger = logger;
        }

        [HttpPost("BiometricLogin")]
        public async Task<IActionResult> BiometricLogin([FromBody] BiometricLoginRequest request)
        {
            _logger.LogInformation("BiometricRefresh endpoint called | DeviceId: {DeviceId}", request.DeviceId);

            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Invalid model state");
                return BadRequest(ModelState);
            }

            var deviceInfo = request.DeviceId;
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";

            _logger.LogInformation("Calling PasskeyService.BiometricRefreshAsync...");

            var result = await _passkeyService.BiometricRefreshAsync(request, deviceInfo, ipAddress);

            if (!string.IsNullOrEmpty(result.Error))
            {
                _logger.LogWarning("Biometric login failed: {Error}", result.Error);
                return Unauthorized(new { success = false, error = result.Error });
            }

            _logger.LogInformation("Biometric login SUCCESS");
            return Ok(new
            {
                success = true,
                accessToken = result.AccessToken,
                refreshToken = result.RefreshToken
            });
        }

        [HttpPost("disable")]
        public async Task<IActionResult> DisableBiometric([FromBody] DisableBiometricRequest request)
        {
            _logger.LogInformation("DisableBiometric endpoint called | DeviceId: {DeviceId}", request.DeviceId);

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            var result = await _passkeyService.DisableBiometricAsync(request, ipAddress);

            if (!result.Success)
                return BadRequest(new { success = false, error = result.Error });

            return Ok(new
            {
                success = true,
                message = "تم تعطيل الدخول بالبصمة بنجاح"
            });
        }
    }
}