using HealthCare_.Services.BackGround;
using HealthCare_.Services.DoctorDervice;
using HealthCare_.Services.PatientService;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Diagnostics;
using System.Text;
using Fido2NetLib;
using Microsoft.OpenApi.Models;
var builder = WebApplication.CreateBuilder(args);

// Add detailed logging
builder.Services.AddLogging(logging =>
{
    logging.AddConsole();
    logging.SetMinimumLevel(LogLevel.Debug);
});

// Database
builder.Services.AddDbContext<HealthCarePlusContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.")));

// Identity
builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
{
    options.Password.RequiredLength = 6;
    options.Password.RequireDigit = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
    options.SignIn.RequireConfirmedAccount = true;
})
.AddEntityFrameworkStores<HealthCarePlusContext>()
.AddDefaultTokenProviders();

// Add Memory Cache for challenge storage
builder.Services.AddMemoryCache();

// FIDO2 Configuration
builder.Services.AddFido2(options =>
{
    options.ServerDomain = builder.Configuration["WebAuthn:RpId"] ?? "localhost";
    options.ServerName = "HealthCare App";
    options.Origins = new HashSet<string> { builder.Configuration["WebAuthn:Origin"] ?? "https://localhost:7092" };
    options.TimestampDriftTolerance = 300000; // 5 minutes in milliseconds
});
builder.Services.AddScoped<IFido2, Fido2>();

// JWT
var jwtSecret = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
var key = Encoding.UTF8.GetBytes(jwtSecret);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = true; // Enforce HTTPS in production
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
        RoleClaimType = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
    };

    options.Events = new JwtBearerEvents
    {
        OnTokenValidated = async context =>
        {
            var logger = context.HttpContext.RequestServices.GetService<ILogger<Program>>();
            logger?.LogInformation("Token validated successfully for UserID: {UserId}, Role: {Role}",
                context.Principal?.FindFirst("UserID")?.Value,
                context.Principal?.FindFirst("http://schemas.microsoft.com/ws/2008/06/identity/claims/role")?.Value);
        },
        OnAuthenticationFailed = context =>
        {
            var logger = context.HttpContext.RequestServices.GetService<ILogger<Program>>();
            var token = context.HttpContext.Request.Headers["Authorization"].FirstOrDefault()?.Replace("Bearer ", "") ?? "No token";
            logger?.LogError("Authentication failed. Exception: {Exception}, Full Token: {Token}", context.Exception, token);
            return Task.CompletedTask;
        },
        OnMessageReceived = context =>
        {
            var logger = context.HttpContext.RequestServices.GetService<ILogger<Program>>();
            var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
            logger?.LogDebug("Message received. Authorization Header: {AuthHeader}", authHeader);
            return Task.CompletedTask;
        }
    };
});

builder.Services.AddScoped<RoleManager<ApplicationRole>>();

// HTTP Context
builder.Services.AddHttpContextAccessor();

// Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IDoctorService, DoctorServices>();
builder.Services.AddScoped<IPatientService, PatientServices>();
builder.Services.AddHostedService<RevokedTokensCleanupService>();

// Cloudinary
builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("Cloudinary"));
builder.Services.AddScoped<CloudinaryService>();

// Controllers + Swagger
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "HealthCare+ API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token in the text input below.\n\nExample: 'Bearer eyJhbGciOiJIUzI1Ni...'",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
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
                }
            },
            new string[] {}
        }
    });
    c.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());
});

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSwaggerUI", policy =>
        policy.WithOrigins("http://localhost:5240", "https://localhost:7092", "http://localhost:3000")
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials());
});

// Authorization Policy
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
});

var app = builder.Build();

// Middleware
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "HealthCare+ API v1");
        c.RoutePrefix = string.Empty;
    });

    try
    {
        Process.Start(new ProcessStartInfo
        {
            FileName = "https://localhost:7092",
            UseShellExecute = true
        });
    }
    catch { }
}

app.UseCors("AllowSwaggerUI");
app.UseHttpsRedirection();
app.UseHsts(); // Added for production security
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();