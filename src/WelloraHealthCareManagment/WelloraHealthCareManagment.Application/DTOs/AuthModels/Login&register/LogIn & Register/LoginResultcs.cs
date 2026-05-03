namespace HealthCare_.Models.DTOs.AuthModels.Login_register
{
    public class LoginResultcs
    {
        public string? AccessToken { get; set; }
        public string? RefreshToken { get; set; }
        public string? Status { get; set; }      // "success", "pending", "failed"
        public string? MfaToken { get; set; }
        public string? Message { get; set; }
        public string? Error { get; set; }
    }
}
