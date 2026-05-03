namespace WelloraHealthCareManagment.Application.Common.Localization
{
    public static class AppLanguages
    {
        public const string English = "en";
        public const string Arabic = "ar";

        public static readonly string[] Supported = [English, Arabic];

        public static bool IsSupported(string? language) =>
            !string.IsNullOrWhiteSpace(language) &&
            Supported.Contains(Normalize(language), StringComparer.OrdinalIgnoreCase);

        public static string Normalize(string? language)
        {
            if (string.IsNullOrWhiteSpace(language))
            {
                return English;
            }

            var normalized = language.Trim().ToLowerInvariant();

            if (normalized.StartsWith(Arabic, StringComparison.OrdinalIgnoreCase))
            {
                return Arabic;
            }

            return English;
        }

        public static bool IsRtl(string? language) =>
            string.Equals(Normalize(language), Arabic, StringComparison.OrdinalIgnoreCase);
    }
}
