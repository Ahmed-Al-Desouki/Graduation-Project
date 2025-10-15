namespace HealthCare_.Models.DTOs.AuthModels.MFA_Passkeys
{
    public class PasskeyLoginRequest
    {
        public string CredentialId { get; set; }
        public string Signature { get; set; }
        public string ClientDataJson { get; set; }
        public string AuthenticatorData { get; set; }
    }
}
