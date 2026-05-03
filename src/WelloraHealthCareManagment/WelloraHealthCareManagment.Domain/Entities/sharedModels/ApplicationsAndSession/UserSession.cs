using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class UserSession
{
    [Key]
    public int Id { get; set; }

    [Required]
    public int UserId { get; set; }

    [ForeignKey(nameof(UserId))]
    public ApplicationUser User { get; set; }

    [MaxLength(500)]
    public string? EncryptedToken { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime ExpiresAt { get; set; }
    public DateTime LastActivity { get; set; } = DateTime.UtcNow;

    [MaxLength(500)]
    public string? DeviceInfo { get; set; } // محدّث من 200 إلى 500

    [MaxLength(100)]
    public string? IpAddress { get; set; }

    [MaxLength(450)]
    public string? RefreshTokenHash { get; set; }

    public DateTime? LastUsedAt { get; set; }

    public DateTime? EndedAt { get; set; }

    public bool IsActive { get; set; } = true;
    public bool IsRevoked { get; set; } = false;
    public DateTime? RevokedAt { get; set; }
    [MaxLength(100)]
    public string? RevokedByIp { get; set; }

    [MaxLength(300)]
    public string? Notes { get; set; }

    // Added for AES encryption
    [MaxLength(500)]
    public string Salt { get; set; }

    public bool IsExpired() => DateTime.UtcNow >= ExpiresAt;

    public void RevokeSession(string? note = null)
    {
        IsRevoked = true;
        IsActive = false;
        RevokedAt = DateTime.UtcNow;
        Notes = note ?? "Session revoked.";
    }
}