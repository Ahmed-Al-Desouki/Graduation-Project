using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class DoctorVerificationDoctorDto
    {
        public int DoctorId { get; set; }
        public string DoctorName { get; set; } = string.Empty;
        public string DoctorEmail { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string Specialization { get; set; } = string.Empty;
        public string? ClinicLocation { get; set; }
        public int YearsOfExperience { get; set; }
        public DoctorVerificationRequestStatus RequestStatus { get; set; }
        public bool IsReadyForReview { get; set; }
        public List<DoctorDocumentType> MissingRequiredDocuments { get; set; } = new();
        public List<DoctorVerificationDto> Verifications { get; set; } = new();
    }

    public class DoctorVerificationDto
    {
        public int VerificationId { get; set; }
        public int DoctorId { get; set; }
        public string DoctorName { get; set; } = string.Empty;
        public string DoctorEmail { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public DoctorDocumentType DocumentType { get; set; }
        public string? FileUrl { get; set; }
        public VerificationStatus Status { get; set; }
        public string? AdminNotes { get; set; }
        public string? RejectionReason { get; set; }
        public int? ReviewedByAdminId { get; set; }
        public string? ReviewedByAdminName { get; set; }
        public DateTime? ReviewedAt { get; set; }
        public DateTime SubmittedAt { get; set; }
    }

    public class ApproveDoctorVerificationRequest
    {
        public string? AdminNotes { get; set; }
    }

    public class RejectDoctorVerificationRequest
    {
        public string RejectionReason { get; set; } = string.Empty;
        public string? AdminNotes { get; set; }
    }

    public class DoctorVerificationListResponse
    {
        public List<DoctorVerificationDoctorDto> Doctors { get; set; } = new();
        public int TotalCount { get; set; }
        public int PendingCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
    }

    public class VerificationStatisticsDto
    {
        public int TotalVerifications { get; set; }
        public int PendingVerifications { get; set; }
        public int ApprovedVerifications { get; set; }
        public int RejectedVerifications { get; set; }
        public Dictionary<VerificationStatus, int> VerificationsByStatus { get; set; } = new();
        public int ApprovedThisMonth { get; set; }
        public int RejectedThisMonth { get; set; }
    }
}
