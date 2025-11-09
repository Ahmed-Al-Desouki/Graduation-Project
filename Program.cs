using AspNetCoreRateLimit;
using Hangfire;
using HealthCare_.Interfaces.IAuth;
using HealthCare_.Interfaces.ReminderInterface;
using HealthCare_.Middleware;
using HealthCare_.Models.sharedModels;
using HealthCare_.Services;
using HealthCare_.Services.Auth;
using HealthCare_.Services.Auth.Interfaces;
using HealthCare_.Services.Background;
using HealthCare_.Services.BackGround;
using HealthCare_.Services.Cloud;
using HealthCare_.Services.DoctorDervice;
using HealthCare_.Services.PatientService;
using HealthCare_.Services.Reminder;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.FileProviders;
using System.Net.Http.Headers;
using System.Reflection;
using System.Text.Json.Serialization;



var builder = WebApplication.CreateBuilder(args);

// ====================== LOGGING ======================
builder.Logging.AddConsole();
builder.Logging.SetMinimumLevel(LogLevel.Debug);

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
//builder.Services.AddDataProtection()
// .PersistKeysToFileSystem(new DirectoryInfo(@"C:\temp\dpkeys"))
// .SetApplicationName("HealthCarePlus")
// .SetDefaultKeyLifetime(TimeSpan.FromDays(90));

// ====================== MEMORY CACHE ======================
builder.Services.AddMemoryCache();

// ====================== RATE LIMITING (IP + Device) ======================
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
// === External Cookie ===
.AddCookie("External", o =>
{
    o.Cookie.Name = ".AspNetCore.External";
    o.Cookie.SameSite = SameSiteMode.None;
    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    o.Cookie.HttpOnly = true;
    o.Cookie.Domain = "nonvolitional-unstuccoed-wilfred.ngrok-free.dev";
    o.Cookie.Path = "/";
    o.ExpireTimeSpan = TimeSpan.FromMinutes(15);
    o.DataProtectionProvider = null;
})
// === Cookie للـ Session ===
.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, o =>
{
    o.Cookie.SameSite = SameSiteMode.None;
    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    o.Cookie.HttpOnly = true;
    o.ExpireTimeSpan = TimeSpan.FromMinutes(60);
    o.SlidingExpiration = true;
    o.Cookie.Domain = "nonvolitional-unstuccoed-wilfred.ngrok-free.dev";
    o.Cookie.Path = "/";
})
// === JWT Bearer ===
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

    // === التعديل: التحقق من RevokedTokens في كل طلب ===
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

            if (isRevoked)
            {
                context.Fail("Token has been revoked");
            }
        }
    };
    // === نهاية التعديل ===
})
// === Google OAuth2 ===
.AddGoogle(o =>
{
    o.ClientId = builder.Configuration["Google:ClientId"]
        ?? throw new InvalidOperationException("Missing Google:ClientId");
    o.ClientSecret = builder.Configuration["Google:ClientSecret"]
        ?? throw new InvalidOperationException("Missing Google:ClientSecret");
    o.CallbackPath = "/api/auth/external/callback";
    o.SignInScheme = "External";
    o.SaveTokens = true;
    o.Scope.Add("email");
    o.Scope.Add("profile");
    o.Events.OnRedirectToAuthorizationEndpoint = context =>
    {
        var scheme = "https";
        var host = context.Request.Host;
        var redirectUri = $"{scheme}://{host}{o.CallbackPath}";
        var uri = new Uri(context.RedirectUri);
        var query = System.Web.HttpUtility.ParseQueryString(uri.Query);
        query["redirect_uri"] = redirectUri;
        var newUri = $"{uri.Scheme}://{uri.Authority}{uri.LocalPath}?{query}";
        context.Response.Redirect(newUri);
        return Task.CompletedTask;
    };
});

// ====================== SERVICES ======================
builder.Services.AddScoped<SignInManager<ApplicationUser>>();
builder.Services.AddScoped<RoleManager<ApplicationRole>>();
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IDoctorService, DoctorServices>();
builder.Services.AddScoped<IPatientService, PatientServices>();
builder.Services.AddHostedService<RevokedTokensCleanupService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IAuthCoreService, AuthCoreService>();
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IMfaService, MfaService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<IPasskeyService, PasskeyService>();
builder.Services.AddScoped<IExternalAuthService, ExternalAuthService>();
builder.Services.AddScoped<IAvatarService, AvatarService>();
builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("Cloudinary"));
builder.Services.AddScoped<CloudinaryService>();
builder.Services.AddScoped<FileUploadService>();

// بعد AddIdentity
builder.Services.AddScoped<UserManager<ApplicationUser>>();
builder.Services.AddScoped<ITokenService, TokenService>();

// ====================== REMINDER SERVICE ======================
builder.Services.AddScoped<IReminderService, ReminderService>();

// ====================== CONTROLLERS & SWAGGER ======================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "HealthCare+ API", Version = "v1" });
    c.CustomSchemaIds(x => x.FullName);
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
        c.IncludeXmlComments(xmlPath);
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
    });


// ====================== CORS ======================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader());
});

// ====================== AUTHORIZATION ======================
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
});

var app = builder.Build();

app.UseStaticFiles();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
    ServeUnknownFileTypes = true,
    DefaultContentType = "application/json",
    RequestPath = ""
});

// ====================== HANGFIRE DASHBOARD ======================
app.UseHangfireDashboard("/admin-secret-reminders-2025-xyz", new DashboardOptions
{
    Authorization = new[] { new HangfireAuthorizationFilter() }
});

// ====================== MIDDLEWARE ======================
app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor |
                       ForwardedHeaders.XForwardedProto |
                       ForwardedHeaders.XForwardedHost,
    RequireHeaderSymmetry = false,
});

// === Rate Limiting ===
app.UseIpRateLimiting(); // ← أضف هنا

app.UseCookiePolicy(new CookiePolicyOptions
{
    MinimumSameSitePolicy = SameSiteMode.None,
    HttpOnly = Microsoft.AspNetCore.CookiePolicy.HttpOnlyPolicy.Always,
    Secure = CookieSecurePolicy.Always
});

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "HealthCare+ API v1");
    c.RoutePrefix = string.Empty;
});

app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/api/patient/files/upload"))
    {
        Console.WriteLine($"Content-Type: {context.Request.ContentType}");
        Console.WriteLine($"Content-Length: {context.Request.ContentLength}");
        foreach (var file in context.Request.Form.Files)
        {
            Console.WriteLine($"Form File: {file.Name}, Size: {file.Length}, Type: {file.ContentType}");
        }
    }
    await next();
});

app.UseCookiePolicy(new CookiePolicyOptions
{
    MinimumSameSitePolicy = SameSiteMode.None,
    Secure = CookieSecurePolicy.Always
});

app.UseCors("AllowAll");

// === Update LastActivity Middleware ===
app.UseAuthentication();
app.UseMiddleware<UpdateLastActivityMiddleware>();
app.UseAuthorization();

app.MapControllers();

// ====================== HANGFIRE JOBS ======================
RecurringJob.AddOrUpdate<ReminderService>(
    "expire-reminders-daily",
    service => service.ExpireRemindersAsync(),
    "0 0 0 * * *");
RecurringJob.AddOrUpdate<ReminderService>(
    "mark-overdue-hourly",
    service => service.MarkOverdueAsync(),
    "0 0 * * *");

app.Run();