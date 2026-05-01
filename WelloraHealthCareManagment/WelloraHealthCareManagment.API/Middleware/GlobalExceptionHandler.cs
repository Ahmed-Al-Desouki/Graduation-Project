// File: Middleware/GlobalExceptionMiddleware.cs
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagement.Domain.Exceptions;

namespace HealthCare_.Middleware
{
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;
        public GlobalExceptionMiddleware(
            RequestDelegate next,
            ILogger<GlobalExceptionMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context, IAppLocalizationService localizationService)
        {
            try
            {
                await _next(context);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unhandled exception occurred");

                context.Response.ContentType = "application/json";

                // الشكل القديم بالظبط
                var errorResponse = new
                {
                    message = GetFriendlyMessage(ex, localizationService),
                    inner = (object?)null
                };

                // كل الـ Exceptions المشهورة + Status Code صحيح
                context.Response.StatusCode = ex switch
                {
                    // Validation
                    FluentValidation.ValidationException => 400,

                    // Authentication / Authorization
                    UnauthorizedAccessException when ex.Message.Contains("claim", StringComparison.OrdinalIgnoreCase)
                        => 401,
                    UnauthorizedAccessException
                        => 403,

                    // Not Found
                    NotFoundException or
                    KeyNotFoundException
                        => 404,

                    // Bad Request
                    DomainException or
                    ArgumentException or
                    ArgumentNullException or
                    ArgumentOutOfRangeException or
                    InvalidOperationException or
                    FormatException or
                    JsonException
                        => 400,

                    // Conflict
                    DbUpdateConcurrencyException
                        => 409,

                    // Database errors
                    DbUpdateException or
                    SqlException
                        => 500, // أو 503 لو عايز تفرق

                    // External services
                    HttpRequestException or
                    TaskCanceledException or
                    TimeoutException
                        => 502, // أو 504

                    // Too Many Requests (Rate limiting)
                    // RateLimitException (لو عندك) => 429,

                    // Everything else
                    _ => 500
                };

                var json = JsonSerializer.Serialize(errorResponse, new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
                });

                await context.Response.WriteAsync(json);
            }
        }

        private static string GetFriendlyMessage(Exception ex, IAppLocalizationService localizationService)
        {
            return ex switch
            {
                FluentValidation.ValidationException => localizationService.Localize("Common.ValidationFailed"),
                UnauthorizedAccessException when ex.Message.Contains("claim") => localizationService.Localize("Common.AuthenticationRequired"),
                UnauthorizedAccessException => localizationService.TranslateText(ex.Message),
                NotFoundException => ex.Message,
                DomainException => ex.Message,
                KeyNotFoundException => ex.Message ?? "The requested resource was not found.",
                ArgumentException or ArgumentNullException => ex.Message,
                InvalidOperationException => ex.Message,
                DbUpdateConcurrencyException => localizationService.Localize("Common.RecordModified"),
                SqlException => localizationService.Localize("Common.DatabaseError"),
                HttpRequestException => localizationService.Localize("Common.ExternalServiceFailed"),
                TimeoutException => localizationService.Localize("Common.Timeout"),
                _ => localizationService.Localize("Common.AnUnexpectedErrorOccurred")
            };
        }
    }
}
