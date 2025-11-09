

namespace HealthCare_.Models.sharedModels
{
    public class ApplicationUser : IdentityUser<int>
    {

        // ─────────────── Basic Information ───────────────
        [Required(ErrorMessage = "Full name is required")]
        [StringLength(100, ErrorMessage = "Full name cannot exceed 100 characters")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Role is required")]
        [StringLength(50)]
        public string Role { get; set; } = string.Empty;

        [StringLength(500)]
        public string? Address { get; set; }

        // ─────────────── Profile Image ───────────────
        public int? ProfileImageId { get; set; }

        [ForeignKey(nameof(ProfileImageId))]
        public ExternalFile? ProfileImagePath { get; set; } // لا تُعبأ يدوياً أبداً

        // ─────────────── Security / 2FA ───────────────
        public override bool TwoFactorEnabled { get; set; } = true;

        //[StringLength(200)]
        //public string? AuthenticatorKey { get; set; }

        //[StringLength(1000)]
        //public string? RecoveryCodes { get; set; }

        // ─────────────── Passkey / WebAuthn ───────────────
        [StringLength(500)] // زيادة للأمان
        public string? PasskeyCredentialId { get; set; }

        [Column(TypeName = "nvarchar(max)")]
        public string? PasskeyPublicKey { get; set; }

        // ─────────────── Audit Information ───────────────
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public DateTime? UpdatedAt { get; set; }

        // ─────────────── Navigation Properties ───────────────
        public Doctor? Doctor { get; set; }
        public Patient? Patient { get; set; }
        public ICollection<Review> Reviews { get; set; } = new List<Review>();
    }
}
