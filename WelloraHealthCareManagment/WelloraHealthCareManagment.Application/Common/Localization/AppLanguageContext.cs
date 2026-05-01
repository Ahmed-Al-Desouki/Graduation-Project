using System.Globalization;

namespace WelloraHealthCareManagment.Application.Common.Localization
{
    public static class AppLanguageContext
    {
        private static readonly AsyncLocal<string?> CurrentLanguage = new();

        public static string Language
        {
            get => AppLanguages.Normalize(CurrentLanguage.Value);
            set => CurrentLanguage.Value = AppLanguages.Normalize(value);
        }

        public static IDisposable BeginScope(string? language)
        {
            var previousLanguage = CurrentLanguage.Value;
            var previousCulture = CultureInfo.CurrentCulture;
            var previousUiCulture = CultureInfo.CurrentUICulture;

            Language = AppLanguages.Normalize(language);
            var culture = CultureInfo.GetCultureInfo(Language == AppLanguages.Arabic ? "ar-EG" : "en-US");
            CultureInfo.CurrentCulture = culture;
            CultureInfo.CurrentUICulture = culture;

            return new Scope(previousLanguage, previousCulture, previousUiCulture);
        }

        private sealed class Scope : IDisposable
        {
            private readonly string? _previousLanguage;
            private readonly CultureInfo _previousCulture;
            private readonly CultureInfo _previousUiCulture;
            private bool _disposed;

            public Scope(string? previousLanguage, CultureInfo previousCulture, CultureInfo previousUiCulture)
            {
                _previousLanguage = previousLanguage;
                _previousCulture = previousCulture;
                _previousUiCulture = previousUiCulture;
            }

            public void Dispose()
            {
                if (_disposed)
                {
                    return;
                }

                CurrentLanguage.Value = _previousLanguage;
                CultureInfo.CurrentCulture = _previousCulture;
                CultureInfo.CurrentUICulture = _previousUiCulture;
                _disposed = true;
            }
        }
    }
}
