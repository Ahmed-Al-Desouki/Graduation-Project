using System.Globalization;

namespace WelloraHealthCareManagment.Application.Interfaces.Services
{
    public interface IAppLocalizationService
    {
        string GetCurrentLanguage();
        string NormalizeLanguage(string? language);
        bool IsRightToLeft(string? language = null);
        CultureInfo GetCulture(string? language = null);
        string Localize(string key, IDictionary<string, string>? arguments = null, string? language = null);
        string TranslateText(string? text, string? language = null);
        string FormatDateTime(DateTime value, string? language = null, bool includeTime = true);
        string FormatDate(DateTime value, string? language = null);
        string FormatTime(DateTime value, string? language = null);
        string FormatAmount(decimal amount, string currency = "EGP", string? language = null);
        string FormatEnumLabel(string value, string? language = null);
    }
}
