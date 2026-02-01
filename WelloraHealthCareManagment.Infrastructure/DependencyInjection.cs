using HealthCare.Application.Interfaces;
using HealthCare.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Infrastructure.Configuration;
using WelloraHealthCareManagement.Infrastructure.Services;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Services;


namespace WelloraHealthCareManagement.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(
            this IServiceCollection services,
            IConfiguration configuration)
        {

            var cloudName = configuration["Cloudinary:CloudName"];
            var apiKey = configuration["Cloudinary:ApiKey"];
            Console.WriteLine($"DEBUG - CloudName: {cloudName}");
            Console.WriteLine($"DEBUG - ApiKey: {apiKey}");

            // Configure Cloudinary settings first
            services.Configure<CloudinarySettings>(
                configuration.GetSection("Cloudinary"));

            // Repositories
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IPatientRepository, PatientRepository>(); 
            services.AddScoped<IDoctorRepository, DoctorRepository>(); 
            services.AddScoped<IMedicalHistoryRepository, MedicalHistoryRepository>(); 
            services.AddScoped<IExternalFileRepository, ExternalFileRepository>(); 
            services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
            services.AddScoped<IRevokedTokenRepository, RevokedTokenRepository>();
            services.AddScoped<IUserSessionRepository, UserSessionRepository>();
            services.AddScoped<IUserDeviceRepository, UserDeviceRepository>();
            services.AddScoped<IPrescriptionRepository, PrescriptionRepository>();
            services.AddScoped<ICurrentMedicationRepository, CurrentMedicationRepository>();
            services.AddScoped<IFamilyHistoryRepository, FamilyHistoryRepository>();
            services.AddScoped<ISelfMedicationRepository, SelfMedicationRepository>();
            services.AddScoped<ISocialHistoryRepository, SocialHistoryRepository>();
            services.AddScoped<ISurgeryRepository, SurgeryRepository>();
            services.AddScoped<IOtpRepository, OtpRepository>();
            services.AddScoped<IMedicalFileRepository, MedicalFileRepository>();


            // Services
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<ICloudStorageService, CloudinaryService>(); 
            services.AddScoped<IAvatarService, AvatarService>();
            services.AddScoped<IPasswordService, PasswordService>();
            services.AddScoped<IGoogleAuthService, GoogleAuthService>();
            services.AddScoped<IAuthCoreService, AuthCoreService>();
            services.AddScoped<IDeviceService, DeviceService>();
            services.AddScoped<IFileUploadService, FileUploadService>();
            services.AddScoped<ICurrentUserService, CurrentUserService>();
            services.AddScoped<IShareTokenService, ShareTokenService>();
            services.AddHttpContextAccessor(); // ضروري للـ CurrentUserService



            return services;
        }
    }
}