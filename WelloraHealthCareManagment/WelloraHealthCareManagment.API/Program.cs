//using AspNetCoreRateLimit;
//using Fido2NetLib;
//using FirebaseAdmin;
//using FluentValidation;
//using FluentValidation.AspNetCore;
//using Google.Apis.Auth.OAuth2;
//using Hangfire;
//using HealthCare_.Models.sharedModels.ApplicationsAndSession;

////using HealthCare_.Models.Context;
////using HealthCare_.Models.DTOs.CloudinaryDTO;
////using HealthCare_.Models.sharedModels.ApplicationsAndSession;
//using Microsoft.AspNetCore.Authentication.Cookies;
//using Microsoft.AspNetCore.Authentication.JwtBearer;
//using Microsoft.AspNetCore.DataProtection;
//using Microsoft.AspNetCore.HttpOverrides;
//using Microsoft.AspNetCore.Identity;
//using Microsoft.EntityFrameworkCore;
//using Microsoft.Extensions.FileProviders;
//using Microsoft.IdentityModel.Tokens;
//using Microsoft.OpenApi.Models;
//using System.Text;
//using System.Text.Json;
//using System.Text.Json.Serialization;
//using WelloraHealthCareManagement.Application;
//using WelloraHealthCareManagement.Infrastructure;
//using WelloraHealthCareManagment.API.Context;
//namespace WelloraHealthCareManagment.API
//{
//    public class Program
//    {
//        public static void Main(string[] args)
//        {
//            var builder = WebApplication.CreateBuilder(args);

//            builder.Services.AddInfrastructure(builder.Configuration);
//            builder.Services.AddApplication();
//            // ====================== LOGGING ======================
//            builder.Logging.ClearProviders();
//            builder.Logging.AddConsole();
//            builder.Logging.SetMinimumLevel(LogLevel.Information);
//            // ====================== DATABASE ======================
//            builder.Services.AddDbContext<HealthCarePlusContext>(options =>
//             options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")
//             ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.")));
//            // ====================== HANGFIRE ======================
//            builder.Services.AddHangfire(config =>
//                config.UseSqlServerStorage(builder.Configuration.GetConnectionString("DefaultConnection")));
//            builder.Services.AddHangfireServer();
//            //FirebaseApp.Create(new AppOptions
//            //{
//            //    Credential = GoogleCredential.FromFile(".Config/firebase-service-account.json")
//            //});
//            // ====================== IDENTITY ======================
//            //builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
//            //{
//            //    options.Password.RequiredLength = 6;
//            //    options.Password.RequireDigit = false;
//            //    options.Password.RequireUppercase = false;
//            //    options.Password.RequireNonAlphanumeric = false;
//            //    options.User.RequireUniqueEmail = true;
//            //    options.SignIn.RequireConfirmedAccount = false;
//            //})
//            //// .AddEntityFrameworkStores<HealthCarePlusContext>()
//            //.AddDefaultTokenProviders();
//            // ====================== DATA PROTECTION ======================
//            builder.Services.AddDataProtection()
//                .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(builder.Environment.ContentRootPath, "DataProtectionKeys")))
//                .SetApplicationName("HealthCarePlus")
//                .SetDefaultKeyLifetime(TimeSpan.FromDays(90));
//            // ====================== MEMORY CACHE ======================
//            builder.Services.AddMemoryCache();
//            // ====================== RATE LIMITING ======================
//            builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
//            builder.Services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
//            builder.Services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
//            builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
//            builder.Services.AddSingleton<IProcessingStrategy, AsyncKeyLockProcessingStrategy>();
//            // ====================== FIDO2 ======================
//            builder.Services.AddFido2(options =>
//            {
//                options.ServerDomain = builder.Configuration["WebAuthn:RpId"] ?? "localhost";
//                options.ServerName = "HealthCare App";
//                options.Origins = new HashSet<string> { builder.Configuration["WebAuthn:Origin"] ?? "http://localhost:7092" };
//                options.TimestampDriftTolerance = 300000;
//            });
//            builder.Services.AddScoped<IFido2, Fido2>();
//            // ====================== JWT ======================
//            var jwtSecret = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
//            var key = Encoding.UTF8.GetBytes(jwtSecret);
//            builder.Services.AddAuthentication(options =>
//            {
//                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
//                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
//                options.DefaultSignInScheme = "External";
//            })
//            .AddCookie("External", o =>
//            {
//                o.Cookie.Name = ".AspNetCore.External";
//                o.Cookie.SameSite = SameSiteMode.None;
//                o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
//                o.Cookie.HttpOnly = true;
//                o.ExpireTimeSpan = TimeSpan.FromMinutes(15);
//            })
//            .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, o =>
//            {
//                o.Cookie.SameSite = SameSiteMode.None;
//                o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
//                o.Cookie.HttpOnly = true;
//                o.ExpireTimeSpan = TimeSpan.FromMinutes(60);
//                o.SlidingExpiration = true;
//            })
//            .AddJwtBearer(o =>
//            {
//                o.RequireHttpsMetadata = false;
//                o.SaveToken = true;
//                o.TokenValidationParameters = new TokenValidationParameters
//                {
//                    ValidateIssuerSigningKey = true,
//                    IssuerSigningKey = new SymmetricSecurityKey(key),
//                    ValidateIssuer = true,
//                    ValidateAudience = true,
//                    ValidIssuer = builder.Configuration["Jwt:Issuer"],
//                    ValidAudience = builder.Configuration["Jwt:Audience"],
//                    ClockSkew = TimeSpan.Zero,
//                    NameClaimType = "UserID",
//                    RoleClaimType = "Role"
//                };
//                o.Events = new JwtBearerEvents
//                {
//                    //OnTokenValidated = async context =>
//                    //{
//                    // var jti = context.Principal?.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
//                    // if (string.IsNullOrEmpty(jti)) return;
//                    // var scope = context.HttpContext.RequestServices.CreateScope();
//                    // var db = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
//                    // var isRevoked = await db.RevokedTokens
//                    // .AnyAsync(rt => rt.Jti == jti && rt.Expires > DateTime.UtcNow);
//                    // if (isRevoked) context.Fail("Token has been revoked");
//                    //}
//                };
//            });
//            // ====================== SERVICES ======================
//            builder.Services.AddHttpContextAccessor();
//            //builder.Services.AddHostedService<RevokedTokensCleanupService>();
//            //builder.Services.AddScoped<IEmailService, EmailService>();
//            //builder.Services.AddScoped<IAuthCoreService, AuthCoreService>();
//            //builder.Services.AddScoped<ITokenService, TokenService>();
//            //builder.Services.AddScoped<IMfaService, MfaService>();
//            //builder.Services.AddScoped<IPasswordService, PasswordService>();
//            //builder.Services.AddScoped<IPasskeyService, PasskeyService>();
//            //builder.Services.AddScoped<IAvatarService, AvatarService>();
//            //builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("Cloudinary"));
//            //builder.Services.AddScoped<CloudinaryService>();
//            //builder.Services.AddScoped<FileUploadService>();
//            //builder.Services.AddScoped<UserManager<ApplicationUser>>();
//            //builder.Services.AddScoped<SignInManager<ApplicationUser>>();
//            //builder.Services.AddScoped<RoleManager<ApplicationRole>>();
//            //builder.Services.AddScoped<IReminderV2Service, ReminderV2Service>();
//            //builder.Services.AddScoped<IMedicalProfileService, MedicalProfileService>();
//            //builder.Services.AddScoped<ISurgeryService, SurgeryService>();
//            //builder.Services.AddScoped<IFamilyHistoryService, FamilyHistoryService>();
//            //builder.Services.AddScoped<ISocialHistoryService, SocialHistoryService>();
//            //builder.Services.AddScoped<ISelfMedicationService, SelfMedicationService>();
//            //builder.Services.AddScoped<ICurrentMedicationService, CurrentMedicationService>();
//            //builder.Services.AddScoped<IAppointmentService, AppointmentService>();
//            //builder.Services.AddScoped<IMedicalRecordService, MedicalRecordService>();
//            //builder.Services.AddScoped<AuthHelperService>();
//            builder.Services.AddFluentValidationAutoValidation();
//            builder.Services.AddFluentValidationClientsideAdapters();
//            builder.Services.AddValidatorsFromAssemblyContaining<Program>();
//            //builder.Services.AddScoped<ReminderOccurrencesGeneratorJob>();
//            //builder.Services.AddScoped<ReminderJobOrchestrator>();
//            //builder.Services.AddHostedService<ReminderCacheHealthCheckService>();
//            //builder.Services.AddSingleton<HangfireAuthorizationFilter>();
//            //builder.Services.AddScoped<IShareTokenService, ShareTokenService>();
//            //builder.Services.AddScoped<IGoogleAuthService, GoogleAuthService>();
//            //builder.Services.AddScoped<IProfilePictureService, ProfilePictureService>();
//            builder.Services.AddHttpClient("fcm");

//            // ====================== CONTROLLERS & SWAGGER ======================
//            builder.Services.AddControllers()
//                .AddJsonOptions(options =>
//                {
//                    options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
//                    options.JsonSerializerOptions.Converters.Add(new DateTimeConverter());
//                });
//            builder.Services.AddEndpointsApiExplorer();
//            builder.Services.AddSwaggerGen(c =>
//            {
//                c.SwaggerDoc("v2", new OpenApiInfo { Title = "HealthCarePlus API V2", Version = "v2" });
//                c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
//                {
//                    Description = "JWT Authorization header: Bearer {your token}",
//                    Name = "Authorization",
//                    In = ParameterLocation.Header,
//                    Type = SecuritySchemeType.ApiKey,
//                    Scheme = "Bearer"
//                });
//                c.AddSecurityRequirement(new OpenApiSecurityRequirement
//            {
//                {
//            new OpenApiSecurityScheme
//            {
//                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
//                Scheme = "oauth2", Name = "Bearer", In = ParameterLocation.Header
//            },
//            new List<string>()
//            }
//                });
//            });
//            // ====================== CORS ======================
//            builder.Services.AddCors(options =>
//            {
//                options.AddPolicy("AllowFrontend", policy =>
//                    policy.WithOrigins("https://healthcare-9dd79.web.app")
//                    .AllowAnyHeader()
//                    .AllowAnyMethod()
//                    .AllowCredentials());
//            });
//            // ====================== AUTHORIZATION ======================
//            builder.Services.AddAuthorization(options =>
//            {
//                options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
//            });
//            var app = builder.Build();
//            // ====================== MIDDLEWARE PIPELINE (REORDERED) ======================
//            app.UseSwagger();
//            app.UseSwaggerUI(c =>
//            {
//                c.SwaggerEndpoint("/swagger/v2/swagger.json", "HealthCare+ API V2");
//                c.RoutePrefix = string.Empty;
//            });
//            app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();
//            app.UseStaticFiles();
//            app.UseStaticFiles(new StaticFileOptions
//            {
//                FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
//                RequestPath = "/static"
//            });
//            app.UseHttpsRedirection();
//            // 1. التوجيه
//            app.UseRouting();
//            // 2. تفعيل السياسة بالاسم الصحيح "AllowFrontend" وقبل الـ Auth
//            app.UseCors("AllowFrontend");
//            app.UseForwardedHeaders(new ForwardedHeadersOptions
//            {
//                ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost,
//                RequireHeaderSymmetry = false
//            });
//            app.UseIpRateLimiting();
//            app.UseCookiePolicy(new CookiePolicyOptions
//            {
//                MinimumSameSitePolicy = SameSiteMode.None,
//                Secure = CookieSecurePolicy.Always
//            });
//            // 3. التحقق والتصريح
//            app.UseAuthentication();
//            //app.UseMiddleware<UpdateLastActivityMiddleware>();
//            app.UseAuthorization();
//            // ====================== HANGFIRE CONFIG ======================
//            //app.UseHangfireDashboard("/hangfire", new DashboardOptions
//            //{
//            // Authorization = new[] { app.Services.GetRequiredService<HangfireAuthorizationFilter>() }
//            //});
//            var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();
//            //recurringJobManager.AddOrUpdate<ReminderOccurrencesGeneratorJob>(
//            // "generate-reminder-occurrences",
//            // job => job.GenerateForAllPatientsAsync(),
//            // Cron.Daily(2));
//            // ====================== MAP CONTROLLERS ======================
//            app.MapControllers();
//            app.Run();
//        }
//        // ====================== CUSTOM CONVERTER ======================
//        public class DateTimeConverter : JsonConverter<DateTime>
//        {
//            public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
//            {
//                return DateTime.Parse(reader.GetString()!);
//            }
//            public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
//            {
//                writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss"));
//            }
//        }
//    }
//}

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
using WelloraHealthCareManagement.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs;


internal class Program
{
    private static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

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
            options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.")));

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

        app.UseExceptionHandler(errorApp =>
        {
            errorApp.Run(async context =>
            {
                var exception = context.Features.Get<IExceptionHandlerFeature>()?.Error;
                await context.Response.WriteAsync(exception?.ToString() ?? "Unknown error");
            });
        });

        app.MapControllers();

        app.Run();
    }
}