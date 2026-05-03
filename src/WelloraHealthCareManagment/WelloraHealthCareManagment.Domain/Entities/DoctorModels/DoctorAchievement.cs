using HealthCare_.Models.DoctorModels;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Entities.DoctorModels
{
    public class DoctorAchievement
    {
        [Key]
        public int AchievementId { get; set; }

        // ─── ربط بالدكتور ───
        [Required]
        public int DoctorId { get; set; }
        [ForeignKey(nameof(DoctorId))]
        public Doctor Doctor { get; set; } = null!;

        // ─── بيانات الانجاز ───
        [Required, StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [StringLength(1000)]
        public string? Description { get; set; }

        // ─── الصورة من ExternalFile الموجود ───
        public int? FileId { get; set; }
        [ForeignKey(nameof(FileId))]
        public ExternalFile? Image { get; set; }

        // ─── Audit ───
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
    }
}
