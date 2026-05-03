using Microsoft.AspNetCore.SignalR;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.Infrastructure.SignalR
{
    public class AppRealtimeService : IRealtimeService
    {
        private readonly IHubContext<AppHub> _hubContext;

        public AppRealtimeService(IHubContext<AppHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public Task BroadcastToUserAsync(
            int userId,
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            return _hubContext.Clients
                .Group(AppHubGroups.User(userId))
                .SendAsync(eventName, payload, ct);
        }

        public Task BroadcastToUsersAsync(
            IEnumerable<int> userIds,
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            var groups = userIds.Distinct().Select(AppHubGroups.User).ToList();
            if (groups.Count == 0)
            {
                return Task.CompletedTask;
            }

            return _hubContext.Clients
                .Groups(groups)
                .SendAsync(eventName, payload, ct);
        }

        public Task BroadcastToAdminsAsync(
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            return _hubContext.Clients
                .Group(AppHubGroups.Admins)
                .SendAsync(eventName, payload, ct);
        }

        public Task BroadcastToEntityAsync(
            string entityType,
            string entityId,
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            return _hubContext.Clients
                .Group(AppHubGroups.Entity(entityType, entityId))
                .SendAsync(eventName, payload, ct);
        }

        public Task BroadcastToUsersAndAdminsAsync(
            IEnumerable<int> userIds,
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            var groups = userIds
                .Distinct()
                .Select(AppHubGroups.User)
                .Append(AppHubGroups.Admins)
                .ToList();

            return _hubContext.Clients
                .Groups(groups)
                .SendAsync(eventName, payload, ct);
        }

        public Task BroadcastToUsersAdminsAndEntityAsync(
            IEnumerable<int> userIds,
            string entityType,
            string entityId,
            string eventName,
            object payload,
            CancellationToken ct = default)
        {
            var groups = userIds
                .Distinct()
                .Select(AppHubGroups.User)
                .Append(AppHubGroups.Admins)
                .Append(AppHubGroups.Entity(entityType, entityId))
                .ToList();

            return _hubContext.Clients
                .Groups(groups)
                .SendAsync(eventName, payload, ct);
        }
    }
}
