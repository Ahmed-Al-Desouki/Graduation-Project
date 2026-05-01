using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Hangfire;
using HealthCare_.Middleware;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using System.Text;
using WelloraHealthCareManagement.Application;
using WelloraHealthCareManagement.Infrastructure;
using WelloraHealthCareManagement.Infrastructure.Data.Interceptors;
using WelloraHealthCareManagment.API;
using WelloraHealthCareManagment.API.Middleware;
using WelloraHealthCareManagment.Application.Common.Security;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Infrastructure.SignalR;


internal class Program
{
    private static void Main(string[] args)
    {
        try
        {
            var builder = WebApplication.CreateBuilder(args);
            // ====================== Enable Detailed Errors ======================
            builder.WebHost.CaptureStartupErrors(true);
            builder.WebHost.UseSetting(WebHostDefaults.DetailedErrorsKey, "true");

            // ====================== CONFIGURATION ======================
            builder.Configuration.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                                 .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
                                 .AddJsonFile("appsettings.Local.json", optional: true, reloadOnChange: true)
                                 .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.Local.json", optional: true, reloadOnChange: true)
                                 .AddEnvironmentVariables();

            // ====================== LOGGING ======================
            builder.Logging.ClearProviders();
            builder.Logging.AddConsole();
            builder.Logging.AddDebug();
            builder.Logging.SetMinimumLevel(LogLevel.Information);


            // ====================== DATABASE ======================
            builder.Services.AddDbContext<HealthCarePlusContext>(options =>
            {
                var connectionString = builder.Configuration.GetConnectionString("DefaultConnection")
                    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
                options.UseSqlServer(connectionString)
                       .AddInterceptors(new UpdateTimestampsInterceptor());
            });
            //builder.Services.AddDbContext<HealthCarePlusContext>(options =>
            //{
            //    options.UseSqlServer(
            //        builder.Configuration.GetConnectionString("DefaultConnection"),
            //        sqlOptions =>
            //        {


            //            sqlOptions.CommandTimeout(60);
            //            sqlOptions.MigrationsAssembly("WelloraHealthCareManagment.Infrastructure");
            //        });
            //});

            // ====================== HANGFIRE ======================
            builder.Services.AddHangfire(config =>
                config.UseSqlServerStorage(builder.Configuration.GetConnectionString("DefaultConnection")));
            builder.Services.AddHangfireServer();

            // ====================== APPLICATION & INFRASTRUCTURE ======================
            builder.Services.AddInfrastructure(builder.Configuration); // DI من Infrastructure.cs
            builder.Services.AddApplication();
            builder.Services.AddSingleton<FirebaseDiagnostic>();

            //// ====================== FIREBASE INITIALIZATION ======================
            //FirebaseApp.Create(new AppOptions()
            //{
            //    Credential = GoogleCredential.FromFile("C:\\Users\\pc\\Desktop\\Graduation Project\\Onion Architecture\\WelloraHealthCareManagment\\WelloraHealthCareManagment.API\\keys\\key-fc7e23a9-dea4-419a-824a-8e630ad16184.xml")
            //});


            // ====================== IDENTITY ======================
            builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
            {
                options.Password.RequiredLength = 6;
                options.Password.RequireDigit = false;
                options.Password.RequireUppercase = false;
                options.Password.RequireNonAlphanumeric = false;
                options.User.RequireUniqueEmail = true;
            })
            .AddEntityFrameworkStores<HealthCarePlusContext>()
            .AddDefaultTokenProviders();

            // ====================== AUTHENTICATION (JWT + Cookies) ======================
            var jwtKey = builder.Configuration["Jwt:Key"]
                ?? throw new InvalidOperationException("Jwt:Key is missing");
            var keyBytes = Encoding.UTF8.GetBytes(jwtKey);

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.RequireHttpsMetadata = false;
                options.SaveToken = true;
                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];
                        var path = context.HttpContext.Request.Path;

                        if (!string.IsNullOrWhiteSpace(accessToken) &&
                            (path.StartsWithSegments("/hubs/app") ||
                             path.StartsWithSegments("/hubs/support")))
                        {
                            context.Token = accessToken;
                        }

                        return Task.CompletedTask;
                    }
                };
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(keyBytes),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
                    ValidAudience = builder.Configuration["Jwt:Audience"],
                    ClockSkew = TimeSpan.Zero,
                    NameClaimType = "UserID",
                    RoleClaimType = "Role"
                };
            })
            .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
            {
                options.Cookie.HttpOnly = true;
                options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
                options.Cookie.SameSite = SameSiteMode.None;
                options.ExpireTimeSpan = TimeSpan.FromMinutes(60);
                options.SlidingExpiration = true;
            });




            // ====================== AUTHORIZATION ======================
            builder.Services.AddAuthorization(options =>
            {
                options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
                options.AddPolicy(
                    DoctorAuthorizationConstants.DoctorOnboardingAccessPolicy,
                    policy => policy.RequireRole("Doctor"));
                options.AddPolicy(
                    DoctorAuthorizationConstants.ApprovedDoctorOnlyPolicy,
                    policy => policy.RequireAssertion(context =>
                        context.User.IsInRole("Doctor") &&
                        string.Equals(
                            context.User.FindFirst(DoctorAuthorizationConstants.DoctorAccessLevelClaimType)?.Value,
                            DoctorAuthorizationConstants.FullAccessLevel,
                            StringComparison.OrdinalIgnoreCase)));
                options.AddPolicy(
                    DoctorAuthorizationConstants.ApprovedDoctorOrAdminPolicy,
                    policy => policy.RequireAssertion(context =>
                        context.User.IsInRole("Admin") ||
                        (context.User.IsInRole("Doctor") &&
                         string.Equals(
                             context.User.FindFirst(DoctorAuthorizationConstants.DoctorAccessLevelClaimType)?.Value,
                             DoctorAuthorizationConstants.FullAccessLevel,
                             StringComparison.OrdinalIgnoreCase))));
                options.AddPolicy(
                    DoctorAuthorizationConstants.PatientAdminOrApprovedDoctorPolicy,
                    policy => policy.RequireAssertion(context =>
                        context.User.IsInRole("Patient") ||
                        context.User.IsInRole("Admin") ||
                        (context.User.IsInRole("Doctor") &&
                         string.Equals(
                             context.User.FindFirst(DoctorAuthorizationConstants.DoctorAccessLevelClaimType)?.Value,
                             DoctorAuthorizationConstants.FullAccessLevel,
                             StringComparison.OrdinalIgnoreCase))));
            });

            // ====================== CONTROLLERS & SWAGGER ======================
            builder.Services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
                });
            builder.Services.Configure<ApiBehaviorOptions>(options =>
            {
                options.InvalidModelStateResponseFactory = context =>
                {
                    var localizationService = context.HttpContext.RequestServices
                        .GetRequiredService<WelloraHealthCareManagment.Application.Interfaces.Services.IAppLocalizationService>();

                    var errors = context.ModelState
                        .Where(x => x.Value?.Errors.Count > 0)
                        .ToDictionary(
                            kvp => kvp.Key,
                            kvp => kvp.Value!.Errors
                                .Select(error => localizationService.TranslateText(
                                    string.IsNullOrWhiteSpace(error.ErrorMessage)
                                        ? localizationService.Localize("Common.ValidationFailed")
                                        : error.ErrorMessage))
                                .ToArray());

                    return new BadRequestObjectResult(new
                    {
                        message = localizationService.Localize("Common.ValidationFailed"),
                        errors
                    });
                };
            });

            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
                {
                    Title = "Wellora HealthCare API",
                    Version = "v1"
                });

                // تعريف الـ Bearer token
                c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                {
                    Name = "Authorization",
                    Type = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
                    Scheme = "Bearer",
                    BearerFormat = "JWT",
                    In = Microsoft.OpenApi.Models.ParameterLocation.Header,
                    Description = "Enter 'Bearer {your JWT token}'"
                });

                c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
                {
                    {
                        new Microsoft.OpenApi.Models.OpenApiSecurityScheme
                        {
                            Reference = new Microsoft.OpenApi.Models.OpenApiReference
                            {
                                Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        new string[] {}
                    }
                });
                c.CustomSchemaIds(type =>
                {
                    return type.FullName?
                        .Replace("WelloraHealthCareManagment.", "")
                        .Replace("+", ".")
                        ?? type.Name;
                });
            });


            // ====================== CORS ======================
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowFrontend", policy =>
                {
                    policy.WithOrigins(
                            "https://healthcare-9dd79.web.app",
                            "https://wellora-dashboard.web.app"
                        )
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .AllowCredentials();
                });
            });


            var app = builder.Build();

            // ====================== MIDDLEWARE ======================
            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseMiddleware<GlobalExceptionMiddleware>();
            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseCors("AllowFrontend");

            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });

            app.UseAuthentication();
            app.UseMiddleware<RequestLanguageMiddleware>();
            app.UseMiddleware<LocalizedJsonResponseMiddleware>();
            app.UseMiddleware<AccountStatusMiddleware>();
            app.UseMiddleware<UpdateLastActivityMiddleware>();
            app.UseAuthorization();
            // ====================== HANGFIRE CONFIG ======================
            app.UseHangfireDashboard("/hangfire");

            try
            {
                var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();

                recurringJobManager.AddOrUpdate<ReminderJobOrchestrator>(
                 "ReminderJobOrchestrator-CacheHealthCheckAsync",
                 job => job.CacheHealthCheckAsync(),
                 "0 */6 * * *");

                recurringJobManager.AddOrUpdate<ReminderOccurrenceGenerator>(
                 "generate-reminder-occurrences",
                 job => job.GenerateForAllPatientsAsync(),
                 "15 2 * * *");

                RecurringJob.AddOrUpdate<IReminderOccurrenceGenerator>(
                    "generate-doctor-cache",
                    j => j.GenerateForAllDoctorsAsync(),
                    "45 2 * * *");

                RecurringJob.AddOrUpdate<ReminderCleanupJob>(
                    "daily-reminder-cleanup",
                    job => job.CleanupAllExpiredRemindersAsync(),
                    "30 1 * * *"); // Cron: every day at 1:30 AM UTC

                RecurringJob.AddOrUpdate<SlotRollingWindowJob>(
                    recurringJobId: "slot-rolling-window",
                    methodCall: job => job.ExecuteAsync(CancellationToken.None),
                    cronExpression: "15 3 * * *",
                    options: new RecurringJobOptions
                    {
                        TimeZone = TimeZoneInfo.Utc
                    });
            }
            catch (Exception ex)
            {
                app.Logger.LogError(ex, "Hangfire recurring jobs could not be registered during startup. The API will continue running, but background jobs are currently unavailable.");
            }

            app.Use(async (context, next) =>
            {
                context.Request.EnableBuffering();
                await next();
            });

            app.MapControllers();
            app.MapHub<AppHub>("/hubs/app");
            app.MapHub<AppHub>("/hubs/support");

            // Firebase diagnostic endpoint
            app.MapGet("/api/test/firebase", async (FirebaseDiagnostic diagnostic) =>
            {
                var result = await diagnostic.TestFirebaseConnectionAsync();
                return Results.Ok(new { Success = result, Message = result ? "Firebase connection successful" : "Firebase connection failed" });
            });

            app.Run();
        }
        catch (Exception ex)
        {
            // Log startup errors
            Console.WriteLine($"STARTUP ERROR: {ex.Message}");
            Console.WriteLine($"Stack Trace: {ex.StackTrace}");
            throw;
        }
    }
}

