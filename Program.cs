using Hangfire;
using HealthCare_.Interfaces.IAuth;
using HealthCare_.Interfaces.ReminderInterface;
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
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Reflection;
using System.Text.Json.Serialization;
using HealthCare_.Models.EnumForModels; // <-- تم إضافته لدعم PatientFileCategory و DoctorFileCategory

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
builder.Services.AddDataProtection()
    .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(builder.Environment.ContentRootPath, "keys")))
    .SetApplicationName("HealthCarePlus");

// ====================== MEMORY CACHE ======================
builder.Services.AddMemoryCache();

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
    options.DefaultSignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
})
.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
{
    options.Cookie.SameSite = SameSiteMode.None;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.HttpOnly = true;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
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
})
.AddGoogle(options =>
{
    options.ClientId = builder.Configuration["Google:ClientId"]
        ?? throw new InvalidOperationException("Missing Google:ClientId");
    options.ClientSecret = builder.Configuration["Google:ClientSecret"]
        ?? throw new InvalidOperationException("Missing Google:ClientSecret");
    options.CallbackPath = "/api/auth/external-callback";
    options.SignInScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.SaveTokens = true;
    options.Scope.Add("email");
    options.Scope.Add("profile");
    options.Events.OnRedirectToAuthorizationEndpoint = context =>
    {
        context.Response.Redirect(context.RedirectUri);
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

// ====================== REMINDER SERVICE ======================
builder.Services.AddScoped<IReminderService, ReminderService>();

// ====================== CONTROLLERS & SWAGGER ======================
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// إعداد Swagger مع دعم GroupName وتجنب تضارب الأسماء
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "HealthCare+ API", Version = "v1" });

    // تجنب تضارب الأسماء في الـ DTOs
    c.CustomSchemaIds(x => x.FullName);

    // XML Comments (إذا كان مفعّل في csproj)
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
        c.IncludeXmlComments(xmlPath);

    // JWT Authorization
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
                       ForwardedHeaders.XForwardedHost
});

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

app.UseCors("AllowAll");
app.UseAuthentication();
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
    "0 0 * * * *");

app.Run();