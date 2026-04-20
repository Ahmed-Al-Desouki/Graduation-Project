using WelloraHealthCareManagment.Application.Interfaces;

namespace HealthCare_.Middleware
{
    public class UpdateLastActivityMiddleware
    {
        private readonly RequestDelegate _next;

        public UpdateLastActivityMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IUserActivityService userActivityService)
        {
            var userIdClaim = context.User.FindFirst("UserID")?.Value;
            if (int.TryParse(userIdClaim, out var userId))
            {
                await userActivityService.UpdateLastActivityAsync(userId, context.RequestAborted);
            }

            await _next(context);
        }
    }
}
