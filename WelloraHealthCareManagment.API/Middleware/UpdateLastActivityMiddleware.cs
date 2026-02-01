using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;

namespace HealthCare_.Middleware
{
    public class UpdateLastActivityMiddleware
    {
        private readonly RequestDelegate _next;

        public UpdateLastActivityMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, HealthCarePlusContext db)
        {
            var userIdClaim = context.User.FindFirst("UserID")?.Value;
            if (int.TryParse(userIdClaim, out int userId))
            {
                var session = await db.UserSessions
                    .FirstOrDefaultAsync(s => s.UserId == userId && s.IsActive);

                if (session != null)
                {
                    session.LastActivity = DateTime.UtcNow;
                    db.UserSessions.Update(session);
                    await db.SaveChangesAsync();
                }
            }

            await _next(context);
        }
    }
}
