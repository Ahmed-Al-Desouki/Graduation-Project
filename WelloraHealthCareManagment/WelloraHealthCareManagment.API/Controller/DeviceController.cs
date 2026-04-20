// Presentation/Controllers/DeviceController.cs
using HealthCare_.Models.DTOs.AuthModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;

namespace WelloraHealthCareManagment.Presentation.Controllers
{
    [ApiController]
    [Route("api/devices")]
    [Authorize]
    public class DeviceController : ControllerBase
    {
        private readonly IDeviceService _deviceService;

        public DeviceController(IDeviceService deviceService)
        {
            _deviceService = deviceService;
        }

        /// <summary>
        /// Register or Update FCM Token from Flutter App
        /// </summary>
        [HttpPost("register")]
        public async Task<IActionResult> RegisterDevice([FromBody] RegisterDeviceRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.FcmToken))
                return BadRequest("FCM Token is required");

            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");

            try
            {
                var success = await _deviceService.RegisterDeviceAsync(userId, request.FcmToken);
                if (!success)
                    return BadRequest("Failed to register device");

                return Ok(new { message = "Device registered successfully" });
            }
            catch (Exception)
            {
                return BadRequest("Failed to register device");
            }
        }

        /// <summary>
        /// Get all active device tokens for current user (for testing)
        /// </summary>
        [HttpGet("my-devices")]
        public async Task<IActionResult> GetMyDevicesTest()
        {
            var userId = int.Parse(User.FindFirst("UserID")?.Value ?? "0");
            var currentDeviceInfo = Request.Headers["User-Agent"].ToString();
            var currentIp = HttpContext.Connection.RemoteIpAddress?.ToString();
            var devices = await _deviceService.GetActiveDevicesAsync(userId, currentDeviceInfo, currentIp);
            return Ok(devices);
        }
    }
}
