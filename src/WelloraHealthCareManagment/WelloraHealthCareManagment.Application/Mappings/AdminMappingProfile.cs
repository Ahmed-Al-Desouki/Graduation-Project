// Application/Mappings/AdminMappingProfile.cs
using HealthCare_.Models.sharedModels.Reviews;
using System.Text.Json;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Domain.Entities.AdminLogs;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Entities.Notifications;
using WelloraHealthCareManagment.Domain.Entities.Support;
using WelloraHealthCareManagment.Domain.Entities.UserManagement;
using AutoMapper;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace WelloraHealthCareManagment.Application.Mappings
{
    public class AdminMappingProfile : Profile
    {
        public AdminMappingProfile()
        {
            // UserStatus mappings
            CreateMap<UserStatus, UserStatusDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.FullName))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.BlockedByAdminName, opt => opt.MapFrom(src => src.BlockedByAdmin != null ? src.BlockedByAdmin.FullName : null))
                .ForMember(dest => dest.SuspendedByAdminName, opt => opt.MapFrom(src => src.SuspendedByAdmin != null ? src.SuspendedByAdmin.FullName : null));

            // Notification mappings
            CreateMap<Notification, NotificationDto>()
                .ForMember(
                    dest => dest.NavigationPayload,
                    opt => opt.MapFrom(src => DeserializeNavigationPayload(src.NavigationPayloadJson)));

            // Ticket mappings
            CreateMap<Ticket, TicketDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.FullName))
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ClosedByAdminName, opt => opt.MapFrom(src => src.ClosedByAdmin != null ? src.ClosedByAdmin.FullName : null))
                .ForMember(dest => dest.MessageCount, opt => opt.MapFrom(src => src.Messages.Count));

            CreateMap<Ticket, TicketDetailsDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.FullName))
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ClosedByAdminName, opt => opt.MapFrom(src => src.ClosedByAdmin != null ? src.ClosedByAdmin.FullName : null))
                .ForMember(dest => dest.Messages, opt => opt.MapFrom(src => src.Messages));

            CreateMap<TicketMessage, TicketMessageDto>()
                .ForMember(dest => dest.Content, opt => opt.MapFrom(src => src.Message))
                .ForMember(dest => dest.SenderName, opt => opt.MapFrom(src => src.Sender.FullName));

            // DoctorVerification mappings
            CreateMap<DoctorVerification, DoctorVerificationDto>()
                .ForMember(dest => dest.DoctorName, opt => opt.MapFrom(src => src.Doctor.User.FullName))
                .ForMember(dest => dest.DoctorEmail, opt => opt.MapFrom(src => src.Doctor.User.Email))
                .ForMember(dest => dest.Specialization, opt => opt.MapFrom(src => src.Doctor.Specialization))
                .ForMember(dest => dest.FileUrl, opt => opt.MapFrom(src => src.File != null ? src.File.FileUrl : null))
                .ForMember(dest => dest.ReviewedByAdminName, opt => opt.MapFrom(src => src.ReviewedByAdminId.HasValue ? "Admin" : null)); // You'll need to join with ApplicationUser to get actual name

            // Review mappings
            CreateMap<Review, ReviewModerationDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.User.FullName))
                .ForMember(dest => dest.UserEmail, opt => opt.MapFrom(src => src.User.Email))
                .ForMember(dest => dest.ReviewerProfileImageUrl, opt => opt.MapFrom(src => src.User.ProfileImagePath != null ? src.User.ProfileImagePath.FileUrl : null))
                .ForMember(dest => dest.DoctorName, opt => opt.Ignore()) // Will be set manually in service
                .ForMember(dest => dest.DeletedByAdminName, opt => opt.MapFrom(src => src.DeletedByAdmin != null ? src.DeletedByAdmin.FullName : null));

            // AdminActionLog mappings
            CreateMap<AdminActionLog, AdminAuditLogDto>()
                .ForMember(dest => dest.AdminName, opt => opt.MapFrom(src => src.Admin.FullName));
        }
        private static Dictionary<string, string>? DeserializeNavigationPayload(string? json)
        {
            if (string.IsNullOrWhiteSpace(json))
            {
                return null;
            }

            try
            {
                return JsonSerializer.Deserialize<Dictionary<string, string>>(json);
            }
            catch
            {
                return null;
            }
        }
    }
}
