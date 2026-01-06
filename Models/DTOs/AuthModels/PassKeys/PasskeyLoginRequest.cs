namespace HealthCare_.Models.DTOs.AuthModels.PassKeys
{
    public class PasskeyLoginRequest
    {
        public string CredentialId { get; set; }
        public string Signature { get; set; }
        public string ClientDataJson { get; set; }
        public string AuthenticatorData { get; set; }
    }
}
