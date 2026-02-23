using Microsoft.Extensions.DependencyInjection;
using WelloraHealthCareManagement.Application.Services;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.Authentication;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.SoftDeleteFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.Commands.UpsertFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.FamilyHistory.GetFamilyHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GenerateMedicalShareToken;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.GetMedicalProfileFromShareToken;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.Commands.UpdateMedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetCompleteMedicalProfileQueryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.MedicalProfile.GetMedicalProfile;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.SoftDeleteSelfMedication;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.Commands.UpsertSelfMedication;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedications;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SelfMedication.GetSelfMedicationsForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.Commands.UpsertSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistories.GetSocialHistoryForShare;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.SocialHistory.Commands.SoftDeleteSocialHistory;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.SoftDeleteSurgery;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.Commands.UpsertSurgery;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeries;
using WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.Surgery.GetSurgeriesForShare;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.ConfirmOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.CreateReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SkipOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SnoozeOccurrence;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.SoftDeleteReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Commands.UpdateReminder;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetAllReminders;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetReminderById;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetTodayReminders;
using WelloraHealthCareManagment.Application.UseCases.Reminder.Queries.GetUpcomingReminders;

namespace WelloraHealthCareManagement.Application
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplication(this IServiceCollection services)
        {
            // Current Medications Handlers
            //services.AddScoped<GetCurrentMedicationsForShareQueryHandler>();

            // Family History Handlers
            services.AddScoped<GetFamilyHistoryQueryHandler>();
            services.AddScoped<GetFamilyHistoryForShareQueryHandler>();
            services.AddScoped<UpsertFamilyHistoryCommandHandler>();
            services.AddScoped<SoftDeleteFamilyHistoryCommandHandler>();

            // Self Medication Handlers 
            services.AddScoped<GetSelfMedicationsQueryHandler>();
            services.AddScoped<GetSelfMedicationsForShareQueryHandler>();
            services.AddScoped<UpsertSelfMedicationCommandHandler>();
            services.AddScoped<SoftDeleteSelfMedicationCommandHandler>();

            // Social History Handlers 
            services.AddScoped<GetSocialHistoryQueryHandler>();
            services.AddScoped<GetSocialHistoryForShareQueryHandler>();
            services.AddScoped<UpsertSocialHistoryCommandHandler>();
            services.AddScoped<SoftDeleteSocialHistoryCommandHandler>();

            // Surgery Handlers 
            services.AddScoped<GetSurgeriesQueryHandler>();
            services.AddScoped<GetSurgeriesForShareQueryHandler>();
            services.AddScoped<UpsertSurgeryCommandHandler>();
            services.AddScoped<SoftDeleteSurgeryCommandHandler>();

            // Medical Profile Handlers 
            services.AddScoped<GetMedicalProfileQueryHandler>();
            services.AddScoped<GetCompleteMedicalProfileQueryHandler>();
            services.AddScoped<UpdateMedicalProfileCommandHandler>();

            // Share Token Handlers 
            services.AddScoped<GenerateShareTokenQueryHandler>();
            services.AddScoped<GetMedicalProfileFromShareTokenQueryHandler>();

            // doctor garant medical history handlers
            services.AddScoped<GetPatientMedicalProfileForDoctorQueryHandler>();

            // current medication handler
            services.AddScoped<GetCurrentMedicationsQueryHandler>();

            // Reminder Handlers 
            services.AddScoped<CreateReminderCommandHandler>();
            services.AddScoped<UpdateReminderCommandHandler>();
            services.AddScoped<SoftDeleteReminderCommandHandler>();
            services.AddScoped<ConfirmOccurrenceCommandHandler>();
            services.AddScoped<SnoozeOccurrenceCommandHandler>();
            services.AddScoped<SkipOccurrenceCommandHandler>();
            services.AddScoped<GetReminderByIdQueryHandler>();
            services.AddScoped<GetAllRemindersQueryHandler>();
            services.AddScoped<GetTodayRemindersQueryHandler>();
            services.AddScoped<GetUpcomingRemindersQueryHandler>();

            // Application Services
            services.AddScoped<IMfaService, MfaService>();


            return services;
        }
    }
}