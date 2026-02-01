using HealthCare_.Models.DTOs.AuthModels;
using HealthCare_.Models.DTOs.AuthModels.Login_register;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;

namespace WelloraHealthCareManagement.Infrastructure.Services
{
    public class DeviceService : IDeviceService
    {
        private readonly IUserSessionRepository _sessionRepository;
        private readonly IUserDeviceRepository _deviceRepository;
        private readonly IConfiguration _configuration;
        private readonly ILogger<DeviceService> _logger;

        public DeviceService(
            IUserSessionRepository sessionRepository,
            IUserDeviceRepository deviceRepository,
            IConfiguration configuration,
            ILogger<DeviceService> logger)
        {
            _sessionRepository = sessionRepository;
            _deviceRepository = deviceRepository;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<GetActiveDevicesResponse> GetActiveDevicesAsync(
            int userId,
            string? currentDeviceInfo,
            string? currentIp)
        {
            var maxDevices = Convert.ToInt32(_configuration["Auth:MaxActiveDevices"] ?? "3");

            var activeSessions = await _sessionRepository.GetActiveSessionsByUserAsync(userId);

            var devices = activeSessions.Select(s => new ActiveDeviceDto
            {
                DeviceInfo = s.DeviceInfo ?? "Unknown Device",
                IpAddress = s.IpAddress,
                LastActivity = s.LastActivity,
                IsCurrentDevice = s.DeviceInfo == currentDeviceInfo && s.IpAddress == currentIp
            }).ToList();

            return new GetActiveDevicesResponse
            {
                TotalActiveDevices = devices.Count,
                MaxAllowedDevices = maxDevices,
                Devices = devices
            };
        }

        public async Task<bool> RegisterDeviceAsync(int userId, string fcmToken)
        {
            try
            {
                var exists = await _deviceRepository.DeviceExistsAsync(userId, fcmToken);
                if (exists)
                {
                    _logger.LogInformation("Device already registered for user {UserId}", userId);
                    return true;
                }

                await _deviceRepository.AddDeviceAsync(userId, fcmToken);
                _logger.LogInformation("Device registered for user {UserId}", userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to register device for user {UserId}", userId);
                return false;
            }
        }

        public async Task<bool> UnregisterDeviceAsync(int userId, string fcmToken)
        {
            try
            {
                await _deviceRepository.RemoveDeviceAsync(userId, fcmToken);
                _logger.LogInformation("Device unregistered for user {UserId}", userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to unregister device for user {UserId}", userId);
                return false;
            }
        }
    }
}