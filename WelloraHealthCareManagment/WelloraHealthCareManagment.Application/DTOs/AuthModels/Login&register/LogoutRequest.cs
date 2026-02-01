namespace HealthCare_.Models.DTOs.AuthModels
{
    public class LogoutRequest
    {

        public int UserId { get; set; }
        public string Jti { get; set; } = string.Empty;
    }
}
