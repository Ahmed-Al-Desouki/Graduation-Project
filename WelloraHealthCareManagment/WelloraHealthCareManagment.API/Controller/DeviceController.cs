// Presentation/Controllers/DeviceController.cs
using HealthCare_.Models.DTOs.AuthModels;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.AuthModels;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;

namespace WelloraHealthCareManagment.Presentation.Controllers
{
    [ApiController]
    [Route("api/devices")]
    [Authorize]
    public class DeviceController : ControllerBase
    {
        private readonly IUserDeviceRepository _userDeviceRepository;

        public DeviceController(IUserDeviceRepository userDeviceRepository)
        {
            _userDeviceRepository = userDeviceRepository;
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
                // Remove old token if exists
                await _userDeviceRepository.RemoveDeviceAsync(userId, request.FcmToken);

                // Add new token
                await _userDeviceRepository.AddDeviceAsync(userId, request.FcmToken);

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
            var tokens = await _userDeviceRepository.GetAllActiveDeviceTokensAsync(userId);
            return Ok(tokens);
        }
    }
}