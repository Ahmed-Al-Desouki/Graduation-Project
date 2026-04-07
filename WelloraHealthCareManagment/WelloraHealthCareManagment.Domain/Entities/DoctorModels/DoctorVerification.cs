// UPDATE: Domain/Entities/DoctorModels/DoctorVerification.cs
using HealthCare_.Models.DoctorModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Enums;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;

namespace WelloraHealthCareManagment.Domain.Entities.DoctorModels
{
    public class DoctorVerification
    {
        [Key]
        public int VerificationId { get; set; }

        // ─── ربط بالدكتور ───
        [Required]
        public int DoctorId { get; set; }
        [ForeignKey(nameof(DoctorId))]
        public Doctor Doctor { get; set; } = null!;

        // ─── نوع الوثيقة ───
        [Required]
        public DoctorDocumentType DocumentType { get; set; }

        // ─── الملف من ExternalFile الموجود ───
        public int? FileId { get; set; }
        [ForeignKey(nameof(FileId))]
        public ExternalFile? File { get; set; }

        // ─── حالة المراجعة ───
        public VerificationStatus Status { get; set; } = VerificationStatus.Pending;

        // ─── بيانات الأدمن ───
        [StringLength(1000)]
        public string? AdminNotes { get; set; }

        // NEW: Explicit rejection reason shown to doctor
        [StringLength(1000)]
        public string? RejectionReason { get; set; }

        public int? ReviewedByAdminId { get; set; }

        // NEW: Navigation property for admin who reviewed
        [ForeignKey(nameof(ReviewedByAdminId))]
        public ApplicationUser? ReviewedByAdmin { get; set; }

        public DateTime? ReviewedAt { get; set; }

        // ─── Audit ───
        public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}