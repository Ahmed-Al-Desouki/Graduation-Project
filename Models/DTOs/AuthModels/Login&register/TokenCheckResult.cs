namespace HealthCare_.Models.DTOs.AuthModels.Login_register
{
    public class TokenCheckResult
    {
        public string Type { get; set; } = string.Empty; // "access" or "refresh"
        public bool Valid { get; set; }
        public DateTime? ExpiresAt { get; set; }
        public int ExpiresIn { get; set; }
        public bool Revoked { get; set; }
        public string? Reason { get; set; } // not_found, revoked, used, expired
    }
}
