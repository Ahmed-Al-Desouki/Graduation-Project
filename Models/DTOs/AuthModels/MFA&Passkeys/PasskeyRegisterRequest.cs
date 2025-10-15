namespace HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys
{
    public class PasskeyRegisterRequest
    {
        public string CredentialId { get; set; }
        public string PublicKey { get; set; }
    }
}
