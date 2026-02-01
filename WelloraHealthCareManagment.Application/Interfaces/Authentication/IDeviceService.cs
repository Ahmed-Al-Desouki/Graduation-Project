using HealthCare_.Models.DTOs.AuthModels.Login_register;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Authentication
{
    public interface IDeviceService
    {
        Task<GetActiveDevicesResponse> GetActiveDevicesAsync(int userId, string? currentDeviceInfo, string? currentIp);
        Task<bool> RegisterDeviceAsync(int userId, string fcmToken);
        Task<bool> UnregisterDeviceAsync(int userId, string fcmToken);
    }
}
