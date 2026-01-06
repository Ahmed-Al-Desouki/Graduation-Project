//using HealthCare_.Interfaces.Email;
//using HealthCare_.Interfaces.IAuth.MFA;
//using HealthCare_.Interfaces.IAuth.PKeyAndPassowrd;
//using HealthCare_.Interfaces.IAuth.QrCodeToken;
//using HealthCare_.Interfaces.IAuth.TokenAndCoreAuth;
//using HealthCare_.Interfaces.Patient.AppointmentAndRecords;
//using HealthCare_.Models.sharedModels.ApplicationsAndSession;
//using HealthCare_.Services.Auth.Tokens;

//var builder = WebApplication.CreateBuilder(args);

//// ====================== LOGGING ======================
//builder.Logging.ClearProviders();
//builder.Logging.AddConsole();
//builder.Logging.SetMinimumLevel(LogLevel.Information);

//// ====================== DATABASE ======================
//builder.Services.AddDbContext<HealthCarePlusContext>(options =>
//    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")
//        ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.")));

//// ====================== HANGFIRE ======================
//builder.Services.AddHangfire(config =>
//    config.UseSqlServerStorage(builder.Configuration.GetConnectionString("DefaultConnection")));
//builder.Services.AddHangfireServer();

//FirebaseApp.Create(new AppOptions
//{
//    Credential = GoogleCredential.FromFile(".Config/firebase-service-account.json")
//});

//// ====================== IDENTITY ======================
//builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
//{
//    options.Password.RequiredLength = 6;
//    options.Password.RequireDigit = false;
//    options.Password.RequireUppercase = false;
//    options.Password.RequireNonAlphanumeric = false;
//    options.User.RequireUniqueEmail = true;
//    options.SignIn.RequireConfirmedAccount = false;
//})
//.AddEntityFrameworkStores<HealthCarePlusContext>()
//.AddDefaultTokenProviders();

//// ====================== DATA PROTECTION ======================
//builder.Services.AddDataProtection()
//    .PersistKeysToFileSystem(new DirectoryInfo(Path.Combine(builder.Environment.ContentRootPath, "DataProtectionKeys")))
//    .SetApplicationName("HealthCarePlus")
//    .SetDefaultKeyLifetime(TimeSpan.FromDays(90));

//// ====================== MEMORY CACHE ======================
//builder.Services.AddMemoryCache();

//// ====================== RATE LIMITING ======================
//builder.Services.Configure<IpRateLimitOptions>(builder.Configuration.GetSection("IpRateLimiting"));
//builder.Services.AddSingleton<IIpPolicyStore, MemoryCacheIpPolicyStore>();
//builder.Services.AddSingleton<IRateLimitCounterStore, MemoryCacheRateLimitCounterStore>();
//builder.Services.AddSingleton<IRateLimitConfiguration, RateLimitConfiguration>();
//builder.Services.AddSingleton<IProcessingStrategy, AsyncKeyLockProcessingStrategy>();

//// ====================== FIDO2 ======================
//builder.Services.AddFido2(options =>
//{
//    options.ServerDomain = builder.Configuration["WebAuthn:RpId"] ?? "localhost";
//    options.ServerName = "HealthCare App";
//    options.Origins = new HashSet<string> { builder.Configuration["WebAuthn:Origin"] ?? "http://localhost:7092" };
//    options.TimestampDriftTolerance = 300000;
//});
//builder.Services.AddScoped<IFido2, Fido2>();

//// ====================== JWT ======================
//var jwtSecret = builder.Configuration["Jwt:Key"] ?? throw new InvalidOperationException("Missing Jwt:Key");
//var key = Encoding.UTF8.GetBytes(jwtSecret);

//builder.Services.AddAuthentication(options =>
//{
//    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
//    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
//    options.DefaultSignInScheme = "External";
//})
//.AddCookie("External", o =>
//{
//    o.Cookie.Name = ".AspNetCore.External";
//    o.Cookie.SameSite = SameSiteMode.None;
//    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
//    o.Cookie.HttpOnly = true;
//    o.ExpireTimeSpan = TimeSpan.FromMinutes(15);
//})
//.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, o =>
//{
//    o.Cookie.SameSite = SameSiteMode.None;
//    o.Cookie.SecurePolicy = CookieSecurePolicy.Always;
//    o.Cookie.HttpOnly = true;
//    o.ExpireTimeSpan = TimeSpan.FromMinutes(60);
//    o.SlidingExpiration = true;
//})
//.AddJwtBearer(o =>
//{
//    o.RequireHttpsMetadata = false;
//    o.SaveToken = true;
//    o.TokenValidationParameters = new TokenValidationParameters
//    {
//        ValidateIssuerSigningKey = true,
//        IssuerSigningKey = new SymmetricSecurityKey(key),
//        ValidateIssuer = true,
//        ValidateAudience = true,
//        ValidIssuer = builder.Configuration["Jwt:Issuer"],
//        ValidAudience = builder.Configuration["Jwt:Audience"],
//        ClockSkew = TimeSpan.Zero,
//        NameClaimType = "UserID",
//        RoleClaimType = "Role"
//    };
//    o.Events = new JwtBearerEvents
//    {
//        OnTokenValidated = async context =>
//        {
//            var jti = context.Principal?.FindFirst(JwtRegisteredClaimNames.Jti)?.Value;
//            if (string.IsNullOrEmpty(jti)) return;
//            var scope = context.HttpContext.RequestServices.CreateScope();
//            var db = scope.ServiceProvider.GetRequiredService<HealthCarePlusContext>();
//            var isRevoked = await db.RevokedTokens
//                .AnyAsync(rt => rt.Jti == jti && rt.Expires > DateTime.UtcNow);
//            if (isRevoked) context.Fail("Token has been revoked");
//        }
//    };
//});

//// ====================== SERVICES ======================
//builder.Services.AddHttpContextAccessor();
//builder.Services.AddHostedService<RevokedTokensCleanupService>();
//builder.Services.AddScoped<IEmailService,EmailService>();
//builder.Services.AddScoped<IAuthCoreService, AuthCoreService>();
//builder.Services.AddScoped<ITokenService, TokenService>();
//builder.Services.AddScoped<IMfaService, MfaService>();
//builder.Services.AddScoped<IPasswordService, PasswordService>();
//builder.Services.AddScoped<IPasskeyService, PasskeyService>();
//builder.Services.AddScoped<IAvatarService, AvatarService>();
//builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("Cloudinary"));
//builder.Services.AddScoped<CloudinaryService>();
//builder.Services.AddScoped<FileUploadService>();
//builder.Services.AddScoped<UserManager<ApplicationUser>>();
//builder.Services.AddScoped<SignInManager<ApplicationUser>>();
//builder.Services.AddScoped<RoleManager<ApplicationRole>>();
//builder.Services.AddScoped<IReminderV2Service, ReminderV2Service>();
//builder.Services.AddScoped<IMedicalProfileService, MedicalProfileService>();
//builder.Services.AddScoped<ISurgeryService, SurgeryService>();
//builder.Services.AddScoped<IFamilyHistoryService, FamilyHistoryService>();
//builder.Services.AddScoped<ISocialHistoryService, SocialHistoryService>();
//builder.Services.AddScoped<ISelfMedicationService, SelfMedicationService>();
//builder.Services.AddScoped<ICurrentMedicationService, CurrentMedicationService>();
//builder.Services.AddScoped<IAppointmentService, AppointmentService>();
//builder.Services.AddScoped<IMedicalRecordService, MedicalRecordService>();
//builder.Services.AddScoped<AuthHelperService>();
//builder.Services.AddFluentValidationAutoValidation();
//builder.Services.AddFluentValidationClientsideAdapters();
//builder.Services.AddValidatorsFromAssemblyContaining<Program>();
//builder.Services.AddScoped<ReminderOccurrencesGeneratorJob>();
//builder.Services.AddScoped<ReminderJobOrchestrator>();
//builder.Services.AddHostedService<ReminderCacheHealthCheckService>();
////builder.Services.AddScoped<ReminderNotificationDispatcherJob>();
////builder.Services.AddScoped<FirebaseNotificationService>();
//builder.Services.AddSingleton<HangfireAuthorizationFilter>();
//builder.Services.AddScoped<IShareTokenService, ShareTokenService>();


//// HttpClient for FCM
//builder.Services.AddHttpClient("fcm")
//    .ConfigurePrimaryHttpMessageHandler(() => new HttpClientHandler
//    {
//        // خيارات handler إن احتجت (proxy, certs ...)
//    });

//// ====================== CONTROLLERS & SWAGGER ======================
////builder.Services.AddControllers()
////    .AddJsonOptions(options =>
////        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));
////builder.Services.AddControllers()
////    .AddJsonOptions(options =>
////    {
////        options.JsonSerializerOptions.Converters.Add(new DateTimeConverter());
////    });
//builder.Services.AddControllers()
//    .AddJsonOptions(options =>
//    {
//        // Enum as string (بدل أرقام)
//        options.JsonSerializerOptions.Converters.Add(
//            new JsonStringEnumConverter()
//        );

//        // Custom DateTime format
//        options.JsonSerializerOptions.Converters.Add(
//            new DateTimeConverter()
//        );
//    });

//builder.Services.AddEndpointsApiExplorer();

//// SWAGGER 6.5.0
//builder.Services.AddSwaggerGen(c =>
//{
//    c.SwaggerDoc("v2", new OpenApiInfo
//    {
//        Title = "HealthCarePlus API V2",
//        Version = "v2",
//        Description = ""
//    });

//    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
//    {
//        Description = "JWT Authorization header: Bearer {your token}",
//        Name = "Authorization",
//        In = ParameterLocation.Header,
//        Type = SecuritySchemeType.ApiKey,
//        Scheme = "Bearer"
//    });

//    c.AddSecurityRequirement(new OpenApiSecurityRequirement
//    {
//        {
//            new OpenApiSecurityScheme
//            {
//                Reference = new OpenApiReference
//                {
//                    Type = ReferenceType.SecurityScheme,
//                    Id = "Bearer"
//                },
//                Scheme = "oauth2",
//                Name = "Bearer",
//                In = ParameterLocation.Header
//            },
//            new List<string>()
//        }
//    });
//});

//// ====================== CORS ======================

//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("AllowFrontend", policy =>
//        policy.WithOrigins(
//            "https://healthcare-9dd79.web.app"
//        )
//        .AllowAnyHeader()
//        .AllowAnyMethod()
//        .AllowCredentials()
//    );
//});

//// ====================== AUTHORIZATION ======================
//builder.Services.AddAuthorization(options =>
//{
//    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
//});


//var app = builder.Build();

//// SWAGGER UI
//app.UseSwagger();
//app.UseSwaggerUI(c =>
//{
//    c.SwaggerEndpoint("/swagger/v2/swagger.json", "HealthCare+ API V2");
//    c.RoutePrefix = string.Empty;
//    c.DocumentTitle = "HealthCare+ API";
//});

//// Redirect root to Swagger
//app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

//app.UseStaticFiles();
//app.UseStaticFiles(new StaticFileOptions
//{
//    FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
//    RequestPath = "/static"
//});

////  Hangfire Dashboard - بدون DI
//app.UseHangfireDashboard("/hangfire", new DashboardOptions
//{
//    Authorization = new[]
//    {
//        app.Services.GetRequiredService<HangfireAuthorizationFilter>()
//    },
//    DashboardTitle = "HealthCare+ Reminders Dashboard",
//    IsReadOnlyFunc = (DashboardContext context) => false
//});

//var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();
////  1. Dispatch notifications every minute
////recurringJobManager.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "dispatch-due-notifications",
////    job => job.DispatchDueRemindersAsync(),
////    Cron.Minutely);

////  2. NEW: Sync missing notifications every 5 minutes
//// This ensures all devices get notifications for all occurrences
////recurringJobManager.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "sync-missing-notifications",
////    job => job.SyncMissingNotificationsAsync(),
////    Cron.MinuteInterval(5));

////  3. Generate occurrences daily at 2 AM
//recurringJobManager.AddOrUpdate<ReminderOccurrencesGeneratorJob>(
//    "generate-reminder-occurrences",
//    job => job.GenerateForAllPatientsAsync(),
//    Cron.Daily(2));

////  4. Cleanup old notifications daily at 3 AM
////recurringJobManager.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "cleanup-old-notifications",
////    job => job.CleanupOldNotificationsAsync(),
////    Cron.Daily(3));

//Console.WriteLine(" Hangfire Jobs Configured:");
//Console.WriteLine("   - Dispatch notifications: Every minute");
//Console.WriteLine("   - Sync missing notifications: Every 5 minutes");
//Console.WriteLine("   - Generate occurrences: Daily at 2:00 AM");
//Console.WriteLine("   - Cleanup old notifications: Daily at 3:00 AM");

//// 2. NEW: Sync missing notifications every 5 minutes
//// This ensures all devices get notifications for all occurrences
////recurringJobManager.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "sync-missing-notifications",
////    job => job.SyncMissingNotificationsAsync(),
////    Cron.MinuteInterval(5));
////// Schedule recurring jobs
////RecurringJob.AddOrUpdate<ReminderOccurrencesGeneratorJob>(
////    "generate-occurrences",
////    x => x.GenerateForAllPatientsAsync(),
////    Cron.Hourly);

////RecurringJob.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "dispatch-notifications",
////    x => x.DispatchDueRemindersAsync(),
////    Cron.Minutely);

////RecurringJob.AddOrUpdate<ReminderNotificationDispatcherJob>(
////    "cleanup-notifications",
////    x => x.CleanupOldNotificationsAsync(),
////    Cron.Daily(3));

////RecurringJob.AddOrUpdate<ReminderJobOrchestrator>(
////    "daily-reminder-generator",
////    j => j.RunDailyGenerationAsync(),
////    Cron.Daily(3));

//app.UseHttpsRedirection();

//app.UseForwardedHeaders(new ForwardedHeadersOptions
//{
//    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost,
//    RequireHeaderSymmetry = false
//});

//app.Use((context, next) =>
//{
//    if (context.Request.Headers.ContainsKey("X-Forwarded-Proto"))
//        context.Request.Scheme = context.Request.Headers["X-Forwarded-Proto"];
//    if (context.Request.Headers.ContainsKey("X-Forwarded-Host"))
//        context.Request.Host = HostString.FromUriComponent(context.Request.Headers["X-Forwarded-Host"]);
//    return next();
//});

//app.UseIpRateLimiting();
//app.UseCookiePolicy(new CookiePolicyOptions
//{
//    MinimumSameSitePolicy = SameSiteMode.None,
//    Secure = CookieSecurePolicy.Always
//});

//app.UseCors("AllowAll");
//app.UseAuthentication();
//app.UseMiddleware<UpdateLastActivityMiddleware>();
//app.UseAuthorization();

//app.MapControllers();

//app.Run();

//public class DateTimeConverter : JsonConverter<DateTime>
//{
//    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
//    {
//        return DateTime.Parse(reader.GetString()!);
//    }

//    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
//    {
//        writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss"));
//    }
//}
using HealthCare_.Interfaces.Email;
using HealthCare_.Interfaces.IAuth.MFA;
using HealthCare_.Interfaces.IAuth.PKeyAndPassowrd;
using HealthCare_.Interfaces.IAuth.QrCodeToken;
using HealthCare_.Interfaces.IAuth.TokenAndCoreAuth;
using HealthCare_.Interfaces.Patient.AppointmentAndRecords;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using HealthCare_.Services.Auth.Mfa;
using HealthCare_.Services.Auth.Tokens;

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

FirebaseApp.Create(new AppOptions
{
    Credential = GoogleCredential.FromFile(".Config/firebase-service-account.json")
});

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
builder.Services.AddHostedService<RevokedTokensCleanupService>();
builder.Services.AddScoped<IEmailService, EmailService>();
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
builder.Services.AddScoped<IReminderV2Service, ReminderV2Service>();
builder.Services.AddScoped<IMedicalProfileService, MedicalProfileService>();
builder.Services.AddScoped<ISurgeryService, SurgeryService>();
builder.Services.AddScoped<IFamilyHistoryService, FamilyHistoryService>();
builder.Services.AddScoped<ISocialHistoryService, SocialHistoryService>();
builder.Services.AddScoped<ISelfMedicationService, SelfMedicationService>();
builder.Services.AddScoped<ICurrentMedicationService, CurrentMedicationService>();
builder.Services.AddScoped<IAppointmentService, AppointmentService>();
builder.Services.AddScoped<IMedicalRecordService, MedicalRecordService>();
builder.Services.AddScoped<AuthHelperService>();
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddFluentValidationClientsideAdapters();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();
builder.Services.AddScoped<ReminderOccurrencesGeneratorJob>();
builder.Services.AddScoped<ReminderJobOrchestrator>();
builder.Services.AddHostedService<ReminderCacheHealthCheckService>();
builder.Services.AddSingleton<HangfireAuthorizationFilter>();
builder.Services.AddScoped<IShareTokenService, ShareTokenService>();

builder.Services.AddHttpClient("fcm");

// ====================== CONTROLLERS & SWAGGER ======================
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter());
        options.JsonSerializerOptions.Converters.Add(new DateTimeConverter());
    });

builder.Services.AddEndpointsApiExplorer();

builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v2", new OpenApiInfo { Title = "HealthCarePlus API V2", Version = "v2" });
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
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
                Scheme = "oauth2", Name = "Bearer", In = ParameterLocation.Header
            },
            new List<string>()
        }
    });
});

// ====================== CORS ======================
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
        policy.WithOrigins("https://healthcare-9dd79.web.app")
        .AllowAnyHeader()
        .AllowAnyMethod()
        .AllowCredentials());
});

// ====================== AUTHORIZATION ======================
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("RequireAdmin", policy => policy.RequireRole("Admin"));
});

var app = builder.Build();

// ====================== MIDDLEWARE PIPELINE (REORDERED) ======================

app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v2/swagger.json", "HealthCare+ API V2");
    c.RoutePrefix = string.Empty;
});

app.MapGet("/", () => Results.Redirect("/swagger")).ExcludeFromDescription();

app.UseStaticFiles();
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
    RequestPath = "/static"
});

app.UseHttpsRedirection();

// 1. التوجيه
app.UseRouting();

// 2. تفعيل السياسة بالاسم الصحيح "AllowFrontend" وقبل الـ Auth
app.UseCors("AllowFrontend");

app.UseForwardedHeaders(new ForwardedHeadersOptions
{
    ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto | ForwardedHeaders.XForwardedHost,
    RequireHeaderSymmetry = false
});

app.UseIpRateLimiting();

app.UseCookiePolicy(new CookiePolicyOptions
{
    MinimumSameSitePolicy = SameSiteMode.None,
    Secure = CookieSecurePolicy.Always
});

// 3. التحقق والتصريح
app.UseAuthentication();
app.UseMiddleware<UpdateLastActivityMiddleware>();
app.UseAuthorization();

// ====================== HANGFIRE CONFIG ======================
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    Authorization = new[] { app.Services.GetRequiredService<HangfireAuthorizationFilter>() }
});

var recurringJobManager = app.Services.GetRequiredService<IRecurringJobManager>();
recurringJobManager.AddOrUpdate<ReminderOccurrencesGeneratorJob>(
    "generate-reminder-occurrences",
    job => job.GenerateForAllPatientsAsync(),
    Cron.Daily(2));

// ====================== MAP CONTROLLERS ======================
app.MapControllers();

app.Run();

// ====================== CUSTOM CONVERTER ======================
public class DateTimeConverter : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        return DateTime.Parse(reader.GetString()!);
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss"));
    }
}