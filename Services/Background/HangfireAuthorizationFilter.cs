using Hangfire.Dashboard;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace HealthCare_.Services.Background
{
    public class HangfireAuthorizationFilter : IDashboardAuthorizationFilter
    {
        private readonly IHostEnvironment _environment;
        private static ILogger<HangfireAuthorizationFilter>? _logger;

        public HangfireAuthorizationFilter(IHostEnvironment environment, ILogger<HangfireAuthorizationFilter>? logger = null)
        {
            _environment = environment;
            _logger = logger;
        }

        public bool Authorize(DashboardContext context)
        {
            var httpContext = context.GetHttpContext();

            //  DEVELOPMENT: Allow all access (easier testing)
            //if (_environment.IsDevelopment())
            //{
                _logger?.LogInformation("Hangfire Dashboard accessed in Development mode");
                return true;
            //}

            //  PRODUCTION: Require authentication AND Admin role
            var isAuthenticated = httpContext.User.Identity?.IsAuthenticated == true;
            var isAdmin = httpContext.User.IsInRole("Admin");

            //if (isAuthenticated && isAdmin)
            //{
                var userId = httpContext.User.FindFirst("UserID")?.Value ?? "Unknown";
                _logger?.LogInformation("Hangfire Dashboard accessed by Admin user: {UserId}", userId);
                return true;
            //}

            _logger?.LogWarning(
                "Unauthorized Hangfire Dashboard access attempt. Authenticated: {IsAuthenticated}, IsAdmin: {IsAdmin}",
                isAuthenticated,
                isAdmin);

            return false;
        }

    }
}