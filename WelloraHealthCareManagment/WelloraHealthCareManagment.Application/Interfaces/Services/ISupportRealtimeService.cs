namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IRealtimeService
    {
        Task BroadcastToUserAsync(
            int userId,
            string eventName,
            object payload,
            CancellationToken ct = default);

        Task BroadcastToUsersAsync(
            IEnumerable<int> userIds,
            string eventName,
            object payload,
            CancellationToken ct = default);

        Task BroadcastToAdminsAsync(
            string eventName,
            object payload,
            CancellationToken ct = default);

        Task BroadcastToEntityAsync(
            string entityType,
            string entityId,
            string eventName,
            object payload,
            CancellationToken ct = default);

        Task BroadcastToUsersAndAdminsAsync(
            IEnumerable<int> userIds,
            string eventName,
            object payload,
            CancellationToken ct = default);

        Task BroadcastToUsersAdminsAndEntityAsync(
            IEnumerable<int> userIds,
            string entityType,
            string entityId,
            string eventName,
            object payload,
            CancellationToken ct = default);
    }
}
