using System.Security.Claims;
using WelloraHealthCareManagment.Application.Interfaces.Services;

namespace WelloraHealthCareManagment.API.Middleware
{
    public class AccountStatusMiddleware
    {
        private readonly RequestDelegate _next;

        public AccountStatusMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, IUserManagementService userManagementService)
        {
            if (context.User.Identity?.IsAuthenticated != true)
            {
                await _next(context);
                return;
            }

            var userIdClaim = context.User.FindFirst("UserID")?.Value
                ?? context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!int.TryParse(userIdClaim, out var userId))
            {
                await _next(context);
                return;
            }

            if (await userManagementService.IsUserActiveAsync(userId))
            {
                await _next(context);
                return;
            }

            var inactiveReasonResult = await userManagementService.GetInactiveReasonAsync(userId);
            var inactiveReason = inactiveReasonResult.IsSuccess
                ? inactiveReasonResult.Data ?? "Your account is not allowed to access the system."
                : "Your account is not allowed to access the system.";

            context.Response.StatusCode = StatusCodes.Status403Forbidden;
            context.Response.ContentType = "application/json";

            await context.Response.WriteAsJsonAsync(new
            {
                success = false,
                error = inactiveReason
            });
        }
    }
}
