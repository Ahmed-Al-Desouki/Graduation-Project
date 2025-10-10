namespace HealthCare_.Models.DTOs.AuthModels
{
    public class LogoutRequest
    {
        public string AccessToken { get; set; } // optional: token from Authorization header or body
        public string RefreshToken { get; set; } // refresh token to revoke
    }
}
