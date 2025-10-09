
using HealthCare_.Services.DoctorDervice;
using HealthCare_.Services.PatientService;

using Microsoft.AspNetCore.Authentication.JwtBearer;

using Microsoft.IdentityModel.Tokens;

using System.Diagnostics;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Database
builder.Services.AddDbContext<HealthCarePlusContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole<int>>(options =>
{
    options.Password.RequiredLength = 6;
    options.Password.RequireDigit = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<HealthCarePlusContext>()
.AddDefaultTokenProviders();

// JWT Authentication
var jwtSecret = builder.Configuration["Jwt:Key"];
var key = Encoding.ASCII.GetBytes(jwtSecret);

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
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ClockSkew = TimeSpan.Zero
    };
});

// Services
builder.Services.AddScoped<IAuthService, AuthService>(); // الحقن عبر Interface
builder.Services.AddScoped<IPrescriptionService, PrescriptionServices>();
builder.Services.AddScoped<IMedicationsIntakeService, MedicationsIntakeServices>();
builder.Services.AddScoped<IReminderService, ReminderServices>();
builder.Services.AddScoped<IDoctorService, DoctorServices>();
builder.Services.AddScoped<IPatientService, PatientServices>();
builder.Services.AddScoped<IAppointmentService, AppointmentServices>();
builder.Services.AddScoped<IMedicalHistoryService, MedicalHistoryServices>();
builder.Services.AddScoped<IMedicalRecordService, MedicalRecordServices>();
builder.Services.AddScoped<IDoctorSlotService, DoctorSlotServices>();
builder.Services.AddScoped<ISessionTypeService, SessionTypeServices>();
builder.Services.AddScoped<IDoctorWeeklyScheduleService, DoctorWeeklyScheduleServices>();
builder.Services.AddScoped<IReviewService, ReviewServices>();
builder.Services.AddScoped<IPrescriptionMedService, PrescriptionMedServices>();
builder.Services.AddScoped<IDosingScheduleService, DosingScheduleServices>();

builder.Services.Configure<CloudinarySettings>(
    builder.Configuration.GetSection("Cloudinary"));
builder.Services.AddScoped<CloudinaryService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "HealthCare+ API", Version = "v1" });
    c.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
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
            FileName = "http://localhost:5240/",
            UseShellExecute = true
        });
    }
    catch { }
}

app.UseCors("AllowAll");
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
