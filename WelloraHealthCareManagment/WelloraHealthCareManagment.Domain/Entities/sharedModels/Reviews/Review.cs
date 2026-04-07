using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.sharedModels.Reviews
{
    public class Review
    {
        [Key]
        [Required]
        public int ReviewID { get; set; }
        [Required]
        public int UserID { get; set; }
        [ForeignKey("UserID")]
        public ApplicationUser User { get; set; }
        [Required, StringLength(50)]
        public string TargetType { get; set; }
        [Required]
        public int TargetID { get; set; }
        [Range(0, 5)]
        public double Rating { get; set; }
        [StringLength(1000)]
        public string? Comment { get; set; }
        [Required]
        public DateTime ReviewDate { get; set; }
        public bool IsVerified { get; set; }
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }
        public int? DeletedByAdminId { get; set; }
        public string? DeletionReason { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        // Navigation
        public ApplicationUser? DeletedByAdmin { get; set; }

    }
}
