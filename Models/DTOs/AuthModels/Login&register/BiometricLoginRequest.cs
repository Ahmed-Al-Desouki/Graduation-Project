namespace HealthCare_.Models.DTOs.AuthModels.Login_register
{
    public class BiometricLoginRequest
    {
        [Required]
        [StringLength(500, ErrorMessage = "DeviceId too long")]
        public string DeviceId { get; set; } = string.Empty;

        [Required]
        public string RefreshToken { get; set; } = string.Empty;

    }
}
