using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Responses;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class DoctorProfileResponse
    {
        // ─── بيانات ApplicationUser ───
        public int DoctorId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? ProfileImageUrl { get; set; }

        // ─── بيانات Doctor ───
        public DateTime? DateOfBirth { get; set; }
        public string? NationalId { get; set; }
        public string Specialization { get; set; } = string.Empty;
        public int YearsOfExperience { get; set; }
        public decimal ConsultationFee { get; set; }
        public string? Bio { get; set; }
        public double AverageRating { get; set; }
        public int PatientCount { get; set; }
        public bool IsActive { get; set; }
        public bool IsProfileCompleted { get; set; }
        public DoctorVerificationRequestStatus VerificationRequestStatus { get; set; }
        public string? VerificationAdminNotes { get; set; }
        public string? VerificationRejectionReason { get; set; }
        public int? VerificationReviewedByAdminId { get; set; }
        public string? VerificationReviewedByAdminName { get; set; }
        public DateTime? VerificationReviewedAt { get; set; }
        public DateTime? VerificationSubmittedAt { get; set; }
        public List<DoctorDocumentType> MissingRequiredVerificationDocuments { get; set; } = new();

        // ─── الموقع ───
        public string? ClinicAddress { get; set; }
        public double? ClinicLatitude { get; set; }
        public double? ClinicLongitude { get; set; }
        public string? HospitalName { get; set; }

        // ─── الوثائق والانجازات ───
        public List<VerificationDocumentResponse> VerificationDocuments { get; set; } = new();
        public List<AchievementResponse> Achievements { get; set; } = new();

        // ─── مراجعات المرضي ───
        public List<ReviewResponse> Reviews { get; set; } = new();

    }

    public class VerificationDocumentResponse
    {
        public int VerificationId { get; set; }
        public DoctorDocumentType DocumentType { get; set; }
        public string? FileUrl { get; set; }
    }

    public class AchievementResponse
    {
        public int AchievementId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
