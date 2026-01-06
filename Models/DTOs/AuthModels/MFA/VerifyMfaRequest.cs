namespace HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys
{
    public class VerifyMfaRequest
    {
        [Required]
        public string OtpCode { get; set; }
    }
}
