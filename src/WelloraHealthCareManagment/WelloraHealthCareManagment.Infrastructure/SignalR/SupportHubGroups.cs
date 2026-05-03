namespace WelloraHealthCareManagment.Infrastructure.SignalR
{
    public static class AppHubGroups
    {
        public const string Admins = "app:admins";

        public static string User(int userId) => $"app:user:{userId}";

        public static string Entity(string entityType, string entityId)
            => $"app:entity:{entityType.ToLowerInvariant()}:{entityId.ToLowerInvariant()}";
    }
}
