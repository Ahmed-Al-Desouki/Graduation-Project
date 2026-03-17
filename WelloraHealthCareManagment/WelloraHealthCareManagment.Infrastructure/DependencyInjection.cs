using HealthCare.Application.Interfaces;
using HealthCare.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagement.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagement.Infrastructure.Configuration;
using WelloraHealthCareManagement.Infrastructure.Repositories;
using WelloraHealthCareManagement.Infrastructure.Services;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories.Search;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Application.Interfaces.Search;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs;
using WelloraHealthCareManagment.Infrastructure.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.Tokens;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication.UserSessions;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking;
using WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.ReminderRepo;
using WelloraHealthCareManagment.Infrastructure.Repositories.Search;
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

            services.AddHttpContextAccessor();  

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
            services.AddScoped<ICurrentMedicationRepository, CurrentMedicationRepository>();
            services.AddScoped<IFamilyHistoryRepository, FamilyHistoryRepository>();
            services.AddScoped<ISelfMedicationRepository, SelfMedicationRepository>();
            services.AddScoped<ISocialHistoryRepository, SocialHistoryRepository>();
            services.AddScoped<ISurgeryRepository, SurgeryRepository>();
            services.AddScoped<IOtpRepository, OtpRepository>();
            services.AddScoped<IMedicalFileRepository, MedicalFileRepository>();
            services.AddScoped<IReminderRepository, ReminderRepository>();
            services.AddScoped<IReminderOccurrencesCacheRepository, ReminderOccurrencesCacheRepository>();
            services.AddScoped<IReminderOccurrenceLogRepository, ReminderOccurrenceLogRepository>();
            services.AddScoped<IDoctorScheduleRepository, DoctorScheduleRepository>();
            services.AddScoped<IScheduleExceptionRepository, ScheduleExceptionRepository>();
            services.AddScoped<ITimeSlotRepository, TimeSlotRepository>();
            services.AddScoped<IAppointmentRepository, AppointmentRepository>();
            services.AddScoped<IMedicalHistoryAccessRepository, MedicalHistoryAccessRepository>();
            services.AddScoped<IUnitOfWork, UnitOfWork>();
            services.AddScoped<IMedicalRecordRepository, MedicalRecordRepository>();
            services.AddScoped<IPrescriptionRepository, PrescriptionRepository>();
            services.AddScoped<IDoctorSearchRepository, DoctorSearchRepository>();
            services.AddScoped<IPaymentRepository, PaymentRepository>();
            services.AddScoped<IDoctorVerificationRepository, DoctorVerificationRepository>();
            services.AddScoped<IDoctorAchievementRepository, DoctorAchievementRepository>();
            services.AddScoped<IReviewRepository, ReviewRepository>();


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
            services.AddScoped<IReminderV2Service, ReminderV2Service>();
            services.AddScoped<IReminderOccurrenceGenerator, ReminderOccurrenceGenerator>();
            services.AddScoped<ITimezoneHelper, TimezoneHelper>();
            services.AddScoped<IRevokedTokenCleanupService, RevokedTokenCleanupService>();
            services.AddScoped<IDoctorScheduleService, DoctorScheduleService>();
            services.AddScoped<ITimeSlotService, TimeSlotService>();
            services.AddScoped<IAppointmentService, AppointmentService>();
            services.AddScoped<IAppointmentReminderService, AppointmentReminderService>();
            services.AddScoped<IMedicalRecordService, MedicalRecordService>();
            services.AddScoped<IPrescriptionService, PrescriptionService>();
            services.AddScoped<IPrescriptionReminderService, PrescriptionReminderService>();
            services.AddScoped<PrescriptionReminderOccurrenceGenerator>();
            services.AddScoped<IDoctorSearchService, DoctorSearchService>();
            services.AddSingleton<IDoctorSearchIndex, DoctorSearchIndex>();
            services.AddScoped<IServiceProvider, ServiceProvider>();
            services.AddScoped<IPaymobService, PaymobService>();
            services.AddScoped<IPaymentService, PaymentService>();
            services.AddScoped<IDoctorProfileService, DoctorProfileService>();
            services.AddScoped<IReviewService, ReviewService>();




            // Background Jobs 
            services.AddScoped<ReminderJobOrchestrator>();
            services.AddHostedService<ReminderCacheHealthCheckService>();
            services.AddHostedService<RevokedTokensCleanupBackgroundService>();
            services.AddHostedService<SlotGenerationJob>();

            //Domain Factories
            services.AddScoped<IAppointmentFactory, AppointmentFactory>();
            services.AddScoped<ITimeSlotGeneratorFactory, TimeSlotGeneratorFactory>();



            return services;
        }
    }
}