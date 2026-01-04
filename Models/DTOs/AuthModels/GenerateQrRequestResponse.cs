namespace HealthCare_.Models.DTOs.AuthModels
{
    public class GenerateQrRequest
    {
        public int PatientId { get; set; }
        public int MedicalHistoryId { get; set; }
    }

    public class GenerateQrResponse
    {
        public string Token { get; set; } = string.Empty;
        public string QrCodeBase64 { get; set; } = string.Empty;
    }
}
