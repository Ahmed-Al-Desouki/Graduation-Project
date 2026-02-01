namespace HealthCare_.Models.DTOs.AuthModels
{
    public class RefreshRequest
    {
        public string AccessToken { get; set; } // old access token (possibly expired)
        public string RefreshToken { get; set; }
    }
}
