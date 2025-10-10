namespace HealthCare_.Models.DTOs.AuthModels
{
    public class RefreshTokenRequest
    {
        public string AccessToken { get; set; }  // القديم
        public string RefreshToken { get; set; } // اللي هيتم التحقق منه
    }
}
