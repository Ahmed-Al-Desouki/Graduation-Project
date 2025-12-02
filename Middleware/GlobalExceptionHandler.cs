// File: Middleware/GlobalExceptionMiddleware.cs
using Microsoft.Data.SqlClient;
using System.Text.Json;

namespace HealthCare_.Middleware
{
    public class GlobalExceptionMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger<GlobalExceptionMiddleware> _logger;
        private readonly IHostEnvironment _env;

        public GlobalExceptionMiddleware(
            RequestDelegate next,
            ILogger<GlobalExceptionMiddleware> logger,
            IHostEnvironment env)
        {
            _next = next;
            _logger = logger;
            _env = env;
        }

        public async Task InvokeAsync(HttpContext context)
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
                    message = GetFriendlyMessage(ex),
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
                    KeyNotFoundException
                        => 404,

                    // Bad Request
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

        private static string GetFriendlyMessage(Exception ex)
        {
            return ex switch
            {
                FluentValidation.ValidationException => "Validation failed. Please check your input.",
                UnauthorizedAccessException when ex.Message.Contains("claim") => "Authentication required.",
                UnauthorizedAccessException => ex.Message, // "History does not belong..."
                KeyNotFoundException => ex.Message ?? "The requested resource was not found.",
                ArgumentException or ArgumentNullException => ex.Message,
                InvalidOperationException => ex.Message,
                DbUpdateConcurrencyException => "The record was modified by another user. Please refresh and try again.",
                SqlException sqlEx => "Database error occurred. Please try again later.",
                HttpRequestException => "Failed to connect to an external service.",
                TimeoutException => "The operation timed out.",
                _ => "An unexpected error occurred. Please try again later."
            };
        }
    }
}