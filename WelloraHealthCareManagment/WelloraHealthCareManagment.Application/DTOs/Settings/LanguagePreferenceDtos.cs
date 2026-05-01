namespace WelloraHealthCareManagment.Application.DTOs.Settings
{
    public class LanguagePreferenceResponse
    {
        public string Language { get; set; } = "en";
        public bool IsRightToLeft { get; set; }
        public string[] SupportedLanguages { get; set; } = [];
    }

    public class UpdateLanguagePreferenceRequest
    {
        public string Language { get; set; } = string.Empty;
    }
}
