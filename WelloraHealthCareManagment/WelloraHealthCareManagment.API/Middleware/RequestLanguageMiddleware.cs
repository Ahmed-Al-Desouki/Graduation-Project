using System.Globalization;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Application.Common.Localization;
using WelloraHealthCareManagment.Infrastructure.Context;

namespace WelloraHealthCareManagment.API.Middleware
{
    public class RequestLanguageMiddleware
    {
        private const string HeaderName = "X-App-Language";
        private readonly RequestDelegate _next;

        public RequestLanguageMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context, HealthCarePlusContext dbContext)
        {
            var language = await ResolveLanguageAsync(context, dbContext);
            using var languageScope = BeginLanguageScope(language);

            context.Items["CurrentLanguage"] = language;
            context.Response.Headers["Content-Language"] = language;

            await _next(context);
        }

        private static async Task<string> ResolveLanguageAsync(HttpContext context, HealthCarePlusContext dbContext)
        {
            var userIdClaim = context.User.FindFirst("UserID")?.Value
                ?? context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

            if (int.TryParse(userIdClaim, out var userId))
            {
                var preferredLanguage = await dbContext.Users
                    .AsNoTracking()
                    .Where(u => u.Id == userId)
                    .Select(u => u.PreferredLanguage)
                    .FirstOrDefaultAsync(context.RequestAborted);

                if (!string.IsNullOrWhiteSpace(preferredLanguage))
                {
                    return AppLanguages.Normalize(preferredLanguage);
                }
            }

            if (context.Request.Query.TryGetValue("lang", out var queryLanguage))
            {
                return AppLanguages.Normalize(queryLanguage.ToString());
            }

            if (context.Request.Headers.TryGetValue(HeaderName, out var headerLanguage))
            {
                return AppLanguages.Normalize(headerLanguage.ToString());
            }

            var acceptLanguage = context.Request.Headers.AcceptLanguage.ToString();
            return AppLanguages.Normalize(acceptLanguage);
        }

        private static IDisposable BeginLanguageScope(string language)
        {
            return AppLanguageContext.BeginScope(language);
        }
    }
}
