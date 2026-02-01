namespace HealthCare_.Services.Auth
{
    public class GoogleLoginRequest
    {
        public string IdToken { get; set; } = string.Empty;
        public string? Role { get; set; } // "Patient" or "Doctor" (client-provided)
    }
}
