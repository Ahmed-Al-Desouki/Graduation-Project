namespace HealthCare_.Models.DTOs.AuthModels
{
    public class RefreshToken
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Token { get; set; }

        [Required]
        public DateTime Expires { get; set; }

        public bool IsUsed { get; set; } = false;
        public bool IsRevoked { get; set; } = false;

        [Required]
        public DateTime Created { get; set; } = DateTime.UtcNow;

        public DateTime? Revoked { get; set; }

        // Link to access token's jti
        [Required]
        public string JwtId { get; set; }

        // Relationship to user
        [Required]
        public int UserId { get; set; }
        [ForeignKey(nameof(UserId))]
        public ApplicationUser User { get; set; }
    }
}

