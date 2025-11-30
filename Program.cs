using AspNetCoreRateLimit;
using Hangfire;
using HealthCare_.Interfaces.IAuth;
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Middleware;
using HealthCare_.Models.Context;
using HealthCare_.Models.sharedModels;
using HealthCare_.Services;
using HealthCare_.Services.Auth;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Services.Background;
using HealthCare_.Services.BackGround;
using HealthCare_.Services.Cloud;
using HealthCare_.Services.DoctorDervice;
using HealthCare_.Services.Patient;
using HealthCare_.Services.Reminder;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;  // الصحيح
using System.Text;
using System.Text.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// ====================== LOGGING ======================
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(LogLevel.Information);

// ====================== DATABASE ======================
builder.Services.AddDbContext<HealthCarePlusContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.")));

// ====================== HANGFIRE ======================
builder.Services.AddHangfire(config =>
    config.UseSqlServerStorage(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddHangfireServer();

// ====================== IDENTITY ======================
builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
{
    options.Password.RequiredLength = 6;
    options.Password.RequireDigit = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedAccount = false;
})
.AddEntityFrameworkStores<HealthCarePlusContext>()
.AddDefaultTokenProviders();

// ====================== DATA PROTECTION ======================
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(builder.Environment.ContentRootPath, "DataProtectionKeys")))
    .SetApplicationName("HealthCarePlus")
    .SetDefaultKeyLifetime(TimeSpan.FromDays(90));

// ====================== MEMORY CACHE ======================
builder.Services.AddMemoryCache();

// ====================== RATE LIMITING ======================
builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
builder.Services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
builder.Services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
builder.Services.AddSingleton<IProcessingStrategy, AsyncKeyLockProcessingStrategy>();

// ====================== FIDO2 ======================
builder.Services.AddFido2(options =>
{
    options.ServerDomain = builder.Configuration["WebAuthn:RpId"] ?? "localhost";
    options.ServerName = "HealthCare App";
    options.Origins = new HashSet<string> { builder.Configuration["WebAuthn:Origin"] ?? "http://localhost:7092" };
    options.TimestampDriftTolerance = 300000;
});
builder.Services.AddScoped<IFido2, Fido2>();

// ====================== JWT ======================
var jwtSecret = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
var key = Encoding.UTF8.GetBytes(jwtSecret);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultSignInScheme = "External";
})
.AddCookie("External", o =>
{
    o.Cookie.Name = ".AspNetCore.External";
    o.Cookie.SameSite = SameSiteMode.None;
    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    o.Cookie.HttpOnly = true;
    o.ExpireTimeSpan = TimeSpan.FromMinutes(15);
})
.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, o =>
{
    o.Cookie.SameSite = SameSiteMode.None;
    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    o.Cookie.HttpOnly = true;
    o.ExpireTimeSpan = TimeSpan.FromMinutes(60);
    o.SlidingExpiration = true;
})
.AddJwtBearer(o =>
{
    o.RequireHttpsMetadata = false;
    o.SaveToken = true;
    o.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ClockSkew = TimeSpan.Zero,
        NameClaimType = "UserID",
        RoleClaimType = "Role"
    };
    o.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var jti = context.Principal?.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
            if (string.IsNullOrEmpty(jti)) return;
            var scope = context.HttpContext.RequestServices.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
            var isRevoked = await db.RevokedTokens
                .AnyAsync(rt => rt.Jti == jti && rt.Expires > DateTime.UtcNow);
            if (isRevoked) context.Fail("Token has been revoked");
        }
    };
});

// ====================== SERVICES ======================
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IDoctorService, DoctorServices>();
builder.Services.AddHostedService<RevokedTokensCleanupService>();
builder.Services.AddScoped<IEmailService, HealthCare_.Services.EmailService>();
builder.Services.AddScoped<IAuthCoreService, AuthCoreService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IMfaService, MfaService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<IPasskeyService, PasskeyService>();
builder.Services.AddScoped<IAvatarService, AvatarService>();
builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("Cloudinary"));
builder.Services.AddScoped<CloudinaryService>();
builder.Services.AddScoped<FileUploadService>();
builder.Services.AddScoped<UserManager<ApplicationUser>>();
builder.Services.AddScoped<SignInManager<ApplicationUser>>();
builder.Services.AddScoped<RoleManager<ApplicationRole>>();
builder.Services.AddScoped<IReminderService, ReminderService>();
builder.Services.AddScoped<IReminderV2Service, ReminderV2Service>();
builder.Services.AddScoped<IMedicalProfileService, PatientMedicalProfileService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IMedicalRecordService, MedicalRecordService>();

// ====================== CONTROLLERS & SWAGGER (الجزء الجديد) ======================
builder.Services.AddControllers()
    .AddJsonOptions(options =>
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

builder.Services.AddEndpointsApiExplorer();

// SWAGGER 6.5.0 – شغال 100% بدون أي خطأ
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v2", new OpenApiInfo
    {
        Title = "HealthCarePlus API V2",
        Version = "v2",
        Description = ""
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header: Bearer {your token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                },
                Scheme = "oauth2",
                Name = "Bearer",
                In = ParameterLocation.Header
            },
            new List<string>()
        }
    });
});

// ====================== CORS ======================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials());
});

// ====================== AUTHORIZATION ======================
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
});

var app = builder.Build();

// Global Exception Handler
app.UseExceptionHandler(errorApp =>
{
    errorApp.Run(async context =>
    {
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        var error = context.Features.Get<Microsoft.AspNetCore.Diagnostics.IExceptionHandlerFeature>();
        if (error != null)
        {
            await context.Response.WriteAsJsonAsync(new
            {
                message = error.Error.Message,
                inner = error.Error.InnerException?.Message
            });
        }
    });
});

// SWAGGER UI – يفتح على الـ root تلقائيًا
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v2/swagger.json", "HealthCare+ API V2");
    c.RoutePrefix = string.Empty; // السطر السحري
    c.DocumentTitle = "HealthCare+ API";
});

// Redirect root to Swagger
app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

app.UseStaticFiles();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
    RequestPath = "/static"
});

app.UseHangfireDashboard("/admin-secret-reminders-2025-xyz", new DashboardOptions
{
    Authorization = new[] { new HangfireAuthorizationFilter() }
});

app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost,
    RequireHeaderSymmetry = false
});

app.Use((context, next) =>
{
    if (context.Request.Headers.ContainsKey("X-Forwarded-Proto"))
        context.Request.Scheme = context.Request.Headers["X-Forwarded-Proto"];
    if (context.Request.Headers.ContainsKey("X-Forwarded-Host"))
        context.Request.Host = HostString.FromUriComponent(context.Request.Headers["X-Forwarded-Host"]);
    return next();
});

app.UseIpRateLimiting();
app.UseCookiePolicy(new CookiePolicyOptions
{
    MinimumSameSitePolicy = SameSiteMode.None,
    Secure = CookieSecurePolicy.Always
});

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseMiddleware<UpdateLastActivityMiddleware>();
app.UseAuthorization();

app.MapControllers();

// ====================== HANGFIRE JOBS ======================
RecurringJob.AddOrUpdate<ReminderService>("expire-reminders-daily",
    service => service.ExpireRemindersAsync(), "0 0 0 * * *");
RecurringJob.AddOrUpdate<ReminderService>("mark-overdue-hourly",
    service => service.MarkOverdueAsync(), "0 0 * * *");

app.Run();