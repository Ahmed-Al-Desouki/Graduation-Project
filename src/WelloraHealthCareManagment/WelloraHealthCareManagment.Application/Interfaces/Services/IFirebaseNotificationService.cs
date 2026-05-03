using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IFirebaseNotificationService
    {
        Task SendPushAsync(
            string fcmToken,
            string title,
            string body,
            string? data = null,           // JSON string for custom payload
            CancellationToken ct = default);

        Task SendMulticastAsync(
            List<string> fcmTokens,
            string title,
            string body,
            string? data = null,
            CancellationToken ct = default);
    }
}
