using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.DTOs.AuthModels
{
    public class RefreshToken
    {
        [Key]
        public int Id { get; set; }

        [Required, MaxLength(1000)]
        public string Token { get; set; }

        [Required]
        public DateTime Expires { get; set; }

        public bool IsUsed { get; set; } = false;
        public bool IsRevoked { get; set; } = false;

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? Revoked { get; set; }
        [MaxLength(100)]
        public string? RevokedByIp { get; set; }

        [Required]
        public string JwtId { get; set; }

        [Required]
        public int UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public ApplicationUser User { get; set; }

        public int? ReplacedById { get; set; }
        public RefreshToken? ReplacedBy { get; set; }

        public int? UserSessionId { get; set; }

        [ForeignKey(nameof(UserSessionId))]
        public UserSession? UserSession { get; set; }

        [MaxLength(500)]
        public string DeviceInfo { get; set; }

        [MaxLength(100)]
        public string IpAddress { get; set; }
        [MaxLength(500)]
        public string? Salt { get; set; }

        public DateTime? LastUsedAt { get; set; }
    }
}