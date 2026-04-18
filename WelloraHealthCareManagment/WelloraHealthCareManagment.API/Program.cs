using Hangfire;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using WelloraHealthCareManagement.Application;
using WelloraHealthCareManagement.Infrastructure;
using WelloraHealthCareManagement.Infrastructure.Data.Interceptors;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs;


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
            });

            // ====================== CONTROLLERS & SWAGGER ======================
            builder.Services.AddControllers()
                .AddJsonOptions(options =>
                {
                    options.JsonSerializerOptions.Converters.Add(new System.Text.Json.Serialization.JsonStringEnumConverter());
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
                    policy.WithOrigins("https://healthcare-9dd79.web.app")
                          .AllowAnyHeader()
                          .AllowAnyMethod()
                          .AllowCredentials();
                });
            });


            var app = builder.Build();

            // ====================== MIDDLEWARE ======================
            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseCors("AllowFrontend");

            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
            });

            app.UseAuthentication();
            app.UseAuthorization();
            // ====================== HANGFIRE CONFIG ======================
            app.UseHangfireDashboard("/hangfire");
            var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();

            recurringJobManager.AddOrUpdate<ReminderOccurrenceGenerator>(
             "generate-reminder-occurrences",
             job => job.GenerateForAllPatientsAsync(),
             Cron.Daily(2));

            recurringJobManager.AddOrUpdate<ReminderJobOrchestrator>(
             "ReminderJobOrchestrator-RunDailyGenerationAsync",
             job => job.RunDailyGenerationAsync(),
             Cron.Daily(3));

            recurringJobManager.AddOrUpdate<ReminderJobOrchestrator>(
             "ReminderJobOrchestrator-CacheHealthCheckAsync",
             job => job.CacheHealthCheckAsync(),
             Cron.Daily(3));

            RecurringJob.AddOrUpdate<IReminderOccurrenceGenerator>(
                "generate-doctor-cache",
                j => j.GenerateForAllDoctorsAsync(),
                "0 2 * * *");

            RecurringJob.AddOrUpdate<ReminderCleanupJob>(
                "daily-reminder-cleanup",
                job => job.CleanupAllExpiredRemindersAsync(),
                "0 2 * * *"); // Cron: every day at 2 AM UTC

            RecurringJob.AddOrUpdate<SlotRollingWindowJob>(
                recurringJobId: "slot-rolling-window",
                methodCall: job => job.ExecuteAsync(CancellationToken.None),
                cronExpression: Cron.Daily(hour: 2),
                options: new RecurringJobOptions
                {
                    TimeZone = TimeZoneInfo.Utc
                });

            app.UseExceptionHandler(errorApp =>
            {
                errorApp.Run(async context =>
                {
                    var exception = context.Features
                        .Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>()?
                        .Error;

                    if (exception != null)
                    {
                        Console.WriteLine("🚨 GLOBAL EXCEPTION CAUGHT IN REQUEST:");
                        Console.WriteLine($"Message: {exception.Message}");
                        Console.WriteLine($"StackTrace: {exception.StackTrace}");
                        Console.WriteLine($"Inner Exception: {exception.InnerException?.Message}");
                        Console.WriteLine($"Source: {exception.Source}");
                        Console.WriteLine("==================================================");
                    }

                    context.Response.StatusCode = 500;
                    await context.Response.WriteAsync("Internal Server Error - check the latest stdout log file");
                });
            });

            app.Use(async (context, next) =>
            {
                context.Request.EnableBuffering();
                await next();
            });

            app.MapControllers();

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