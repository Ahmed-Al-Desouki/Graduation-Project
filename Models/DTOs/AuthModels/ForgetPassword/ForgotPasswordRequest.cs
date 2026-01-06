namespace HealthCare_.Models.DTOs.AuthModels.ForgetPassword
{
    public class ForgotPasswordRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = null!;
    }
}
