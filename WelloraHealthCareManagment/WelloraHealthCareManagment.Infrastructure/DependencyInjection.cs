using HealthCare.Application.Interfaces;
using HealthCare.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using WelloraHealthCareManagement.Application.Interfaces;
using WelloraHealthCareManagement.Domain.Factories;
using WelloraHealthCareManagement.Infrastructure.Repositories;
using WelloraHealthCareManagement.Infrastructure.Services;
using WelloraHealthCareManagement.Infrastructure.Services.Admin;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories.Search;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.Interfaces.Email;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;
using WelloraHealthCareManagment.Application.Interfaces.Search;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Repositories;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs;
using WelloraHealthCareManagment.Infrastructure.BackgroundJobs.ReminderJobs;
using WelloraHealthCareManagment.Infrastructure.Configuration;
using WelloraHealthCareManagment.Infrastructure.Repositories;
using WelloraHealthCareManagment.Infrastructure.Repositories.AdminRepo;
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
using WelloraHealthCareManagment.Infrastructure.Services.Admin;
using WelloraHealthCareManagment.Infrastructure.SignalR;

namespace WelloraHealthCareManagement.Infrastructure
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddInfrastructure(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            // ====================== CONFIGURATION ======================
            services.Configure<CloudinarySettings>(
                configuration.GetSection("Cloudinary"));
            services.Configure<LocationLookupOptions>(
                configuration.GetSection("LocationLookup"));

            services.AddHttpContextAccessor();
            var firebaseSection = configuration.GetSection("Firebase");
            var firebasePath = firebaseSection.GetValue<string>("ServiceAccountPath");

            if (string.IsNullOrWhiteSpace(firebasePath))
            {
                firebaseSection = configuration.GetSection("FCM");
            }

            services.Configure<FirebaseSettings>(firebaseSection);
            services.Configure<FirebaseSettings>(configuration.GetSection("Firebase"));
            services.AddSignalR();

            services.AddAutoMapper(cfg =>
            {
            }, typeof(WelloraHealthCareManagment.Application.Mappings.AdminMappingProfile).Assembly);

            // ====================== REPOSITORIES ======================
            services.AddScoped<IUnitOfWork, UnitOfWork>();

            // Auth
            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
            services.AddScoped<IRevokedTokenRepository, RevokedTokenRepository>();
            services.AddScoped<IUserSessionRepository, UserSessionRepository>();
            services.AddScoped<IUserDeviceRepository, UserDeviceRepository>();
            services.AddScoped<IOtpRepository, OtpRepository>();
            services.AddScoped<IUserStatusRepository, UserStatusRepository>();

            // Patient
            services.AddScoped<IPatientRepository, PatientRepository>();

            // Doctor
            services.AddScoped<IDoctorRepository, DoctorRepository>();
            services.AddScoped<IDoctorAchievementRepository, DoctorAchievementRepository>();
            services.AddScoped<IDoctorSearchRepository, DoctorSearchRepository>();
            services.AddScoped<IDoctorVerificationRepository, DoctorVerificationRepository>();
            services.AddScoped<IDoctorSlotConfigRepository, DoctorSlotConfigRepository>();

            // Medical History
            services.AddScoped<IMedicalHistoryRepository, MedicalHistoryRepository>();
            services.AddScoped<IMedicalHistoryAccessRepository, MedicalHistoryAccessRepository>();
            services.AddScoped<IMedicalRecordRepository, MedicalRecordRepository>();
            services.AddScoped<ICurrentMedicationRepository, CurrentMedicationRepository>();
            services.AddScoped<IFamilyHistoryRepository, FamilyHistoryRepository>();
            services.AddScoped<ISelfMedicationRepository, SelfMedicationRepository>();
            services.AddScoped<ISocialHistoryRepository, SocialHistoryRepository>();
            services.AddScoped<ISurgeryRepository, SurgeryRepository>();
            services.AddScoped<IMedicalFileRepository, MedicalFileRepository>();

            // Appointments & Slots
            services.AddScoped<IAppointmentRepository, AppointmentRepository>();
            services.AddScoped<ITimeSlotRepository, TimeSlotRepository>();
            services.AddScoped<IScheduleExceptionRepository, ScheduleExceptionRepository>();

            // Prescriptions & Reviews
            services.AddScoped<IPrescriptionRepository, PrescriptionRepository>();
            services.AddScoped<IReviewRepository, ReviewRepository>();

            // Reminders
            services.AddScoped<IReminderRepository, ReminderRepository>();
            services.AddScoped<IReminderOccurrencesCacheRepository, ReminderOccurrencesCacheRepository>();
            services.AddScoped<IReminderOccurrenceLogRepository, ReminderOccurrenceLogRepository>();

            // Files & Payments
            services.AddScoped<IExternalFileRepository, ExternalFileRepository>();
            services.AddScoped<IPaymentRepository, PaymentRepository>();

            // Admin
            services.AddScoped<INotificationRepository, NotificationRepository>();// from admi to doctor
            services.AddScoped<ITicketRepository, TicketRepository>();
            services.AddScoped<ITicketMessageRepository, TicketMessageRepository>();
            services.AddScoped<IAdminActionLogRepository, AdminActionLogRepository>();

            // ====================== SERVICES ======================
            // Auth
            services.AddScoped<ITokenService, TokenService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<IPasswordService, PasswordService>();
            services.AddScoped<IGoogleAuthService, GoogleAuthService>();
            services.AddScoped<IAuthCoreService, AuthCoreService>();
            services.AddScoped<IDeviceService, DeviceService>();
            services.AddScoped<ICurrentUserService, CurrentUserService>();
            services.AddScoped<IUserActivityService, UserActivityService>();
            services.AddScoped<IShareTokenService, ShareTokenService>();
            services.AddScoped<IRevokedTokenCleanupService, RevokedTokenCleanupService>();

            // Storage & Files
            services.AddScoped<ICloudStorageService, CloudinaryService>();
            services.AddScoped<IAvatarService, AvatarService>();
            services.AddScoped<IFileUploadService, FileUploadService>();
            services.AddHttpClient<ILocationLookupService, OpenStreetMapLocationLookupService>((serviceProvider, client) =>
            {
                var options = serviceProvider
                    .GetRequiredService<Microsoft.Extensions.Options.IOptions<LocationLookupOptions>>()
                    .Value;

                client.BaseAddress = new Uri(options.BaseUrl);
                client.DefaultRequestHeaders.UserAgent.ParseAdd(options.UserAgent);
                client.DefaultRequestHeaders.Accept.ParseAdd("application/json");
            });

            // Appointments & Slots
            services.AddScoped<IAppointmentService, AppointmentService>();
            services.AddScoped<IAppointmentReminderService, AppointmentReminderService>();
            services.AddScoped<ITimeSlotService, TimeSlotService>();
            services.AddScoped<IDoctorSlotConfigService, DoctorSlotConfigService>();
            services.AddScoped<ISlotGenerationService, SlotGenerationService>();

            // Medical
            services.AddScoped<IMedicalRecordService, MedicalRecordService>();
            services.AddScoped<IPrescriptionService, PrescriptionService>();
            services.AddScoped<IPrescriptionReminderService, PrescriptionReminderService>();
            services.AddScoped<PrescriptionReminderOccurrenceGenerator>();

            // Reminders
            services.AddScoped<IReminderV2Service, ReminderV2Service>();
            services.AddScoped<IReminderOccurrenceGenerator, ReminderOccurrenceGenerator>();
            services.AddScoped<ITimezoneHelper, TimezoneHelper>();

            // Doctors
            services.AddScoped<IDoctorSearchService, DoctorSearchService>();
            services.AddSingleton<IDoctorSearchIndex, DoctorSearchIndex>();
            services.AddScoped<IDoctorProfileService, DoctorProfileService>();
            services.AddScoped<IPatientProfileService, PatientProfileService>();
            services.AddScoped<IReviewService, ReviewService>();

            // Payment
            services.AddScoped<IPaymobService, PaymobService>();
            services.AddScoped<IPaymentService, PaymentService>();

            // Admin Services
            services.AddScoped<IAdminAuditService, AdminAuditService>();
            services.AddScoped<IAdminDashboardService, AdminDashboardService>();
            services.AddScoped<IReviewModerationService, ReviewModerationService>();
            services.AddScoped<IDoctorVerificationService, DoctorVerificationService>();
            services.AddScoped<ITicketService, TicketService>();
            services.AddScoped<IUserManagementService, UserManagementService>();
            services.AddScoped<IUserSearchService, UserSearchService>();
            services.AddScoped<IRealtimeService, AppRealtimeService>();

            services.AddScoped<IMfaService, MfaService>();



            //NOTIFICATION
            services.AddSingleton<IFirebaseNotificationService, FirebaseNotificationService>();
            services.AddScoped<INotificationService, NotificationService>();

            // ====================== BACKGROUND JOBS ======================
            services.AddTransient<SlotRollingWindowJob>();
            services.AddTransient<ReminderJobOrchestrator>();
            services.AddHostedService<RevokedTokensCleanupBackgroundService>();

            // ====================== DOMAIN FACTORIES ======================
            services.AddScoped<IAppointmentFactory, AppointmentFactory>();



            return services;
        }
    }
}
