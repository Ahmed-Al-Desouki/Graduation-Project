//// Services/Background/TokenCheckerService.cs
//using HealthCare_.Models.DTOs.AuthModels.Login_register;
//using HealthCare_.Models.sharedModels;
//using Microsoft.Extensions.DependencyInjection;
//using Microsoft.Extensions.Hosting;
//using Microsoft.Extensions.Logging;
//using System.Net.Http.Headers;
//using System.Text.Json;

//namespace HealthCare_.Services.Background
//{
//    public class TokenCheckerService : BackgroundService
//    {
//        private readonly IServiceScopeFactory _scopeFactory;
//        private readonly ILogger<TokenCheckerService> _logger;
//        private readonly IHttpClientFactory _httpClientFactory;

//        public TokenCheckerService(
//            IServiceScopeFactory scopeFactory,
//            ILogger<TokenCheckerService> logger,
//            IHttpClientFactory httpClientFactory)
//        {
//            _scopeFactory = scopeFactory;
//            _logger = logger;
//            _httpClientFactory = httpClientFactory;
//        }

//        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
//        {
//            _logger.LogInformation("TokenCheckerService started.");

//            while (!stoppingToken.IsCancellationRequested)
//            {
//                try
//                {
//                    using var scope = _scopeFactory.CreateScope();
//                    var context = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
//                    var httpClient = _httpClientFactory.CreateClient("ApiClient");

//                    // 1. جيب أي جلسة نشطة
//                    var activeSession = await context.UserSessions
//                        .FirstOrDefaultAsync(s => s.IsActive && !s.IsRevoked, stoppingToken);

//                    if (activeSession == null)
//                    {
//                        _logger.LogWarning("No active session found.");
//                        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
//                        continue;
//                    }

//                    // 2. اعمل token-status-v2
//                    var statusResponse = await httpClient.GetAsync("api/auth/token-status-v2", stoppingToken);
//                    if (!statusResponse.IsSuccessStatusCode)
//                    {
//                        _logger.LogError("Failed to check token status: {Status}", statusResponse.StatusCode);
//                        await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
//                        continue;
//                    }

//                    var json = await statusResponse.Content.ReadAsStringAsync(stoppingToken);
//                    var status = JsonSerializer.Deserialize<TokenStatusResponse>(json, new JsonSerializerOptions
//                    {
//                        PropertyNameCaseInsensitive = true
//                    });

//                    if (status?.Summary == "access_expired" || status?.Summary == "all_invalid")
//                    {
//                        _logger.LogInformation("Access token expired. Refreshing...");

//                        // 3. اعمل refresh-token (بدون body)
//                        var refreshResponse = await httpClient.PostAsync("api/auth/refresh-token", null, stoppingToken);

//                        if (refreshResponse.IsSuccessStatusCode)
//                        {
//                            var refreshJson = await refreshResponse.Content.ReadAsStringAsync(stoppingToken);
//                            var refreshResult = JsonSerializer.Deserialize<RefreshResponse>(refreshJson, new JsonSerializerOptions
//                            {
//                                PropertyNameCaseInsensitive = true
//                            });

//                            _logger.LogInformation("Token refreshed successfully. New Access Token expires in {Seconds}s",
//                                GetExpiresIn(refreshResult?.AccessToken));

//                            // تحديث الـ LastActivity
//                            activeSession.LastActivity = DateTime.UtcNow;
//                            await context.SaveChangesAsync(stoppingToken);
//                        }
//                        else
//                        {
//                            _logger.LogError("Refresh failed: {Status}", refreshResponse.StatusCode);
//                            // ممكن تعمل Logout هنا
//                        }
//                    }
//                    else
//                    {
//                        _logger.LogDebug("Tokens are valid. Summary: {Summary}", status?.Summary);
//                    }
//                }
//                catch (Exception ex)
//                {
//                    _logger.LogError(ex, "Error in TokenCheckerService");
//                }

//                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
//            }
//        }

//        private int GetExpiresIn(string? token)
//        {
//            if (string.IsNullOrEmpty(token)) return 0;
//            try
//            {
//                var payload = token.Split('.')[1];
//                var json = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(payload + "=="));
//                using var doc = JsonDocument.Parse(json);
//                var exp = doc.RootElement.GetProperty("exp").GetInt64();
//                return (int)(exp - DateTimeOffset.UtcNow.ToUnixTimeSeconds());
//            }
//            catch { return 0; }
//        }
//    }

//    // DTOs
//    public class TokenStatusResponse
//    {
//        public string? Summary { get; set; }
//        public List<TokenCheckResult>? Tokens { get; set; }
//    }

//    public class RefreshResponse
//    {
//        public string? AccessToken { get; set; }
//    }
//}