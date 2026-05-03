using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication
{
    public interface IUserDeviceRepository
    {
        Task<bool> DeviceExistsAsync(int patientId, string fcmToken);
        Task AddDeviceAsync(int patientId, string fcmToken);
        Task RemoveDeviceAsync(int patientId, string fcmToken);
        Task<List<string>> GetDeviceTokensAsync(int patientId);
        Task<List<string>> GetAllActiveDeviceTokensAsync(int userId, CancellationToken ct = default);
    }
}
