using System.Globalization;
using WelloraHealthCareManagment.Application.Common.Localization;

namespace WelloraHealthCareManagment.Infrastructure.Services.Notifications
{
    public static class NotificationMessageFormatter
    {
        public static string FormatDoctor(string? fullName, int? doctorId = null)
        {
            var normalizedName = string.IsNullOrWhiteSpace(fullName)
                ? null
                : fullName.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedName))
            {
                var prefixedName = normalizedName.StartsWith("Dr.", StringComparison.OrdinalIgnoreCase) ||
                    normalizedName.StartsWith("د.", StringComparison.OrdinalIgnoreCase)
                    ? normalizedName
                    : AppLanguageContext.Language == AppLanguages.Arabic
                        ? $"د. {normalizedName}"
                        : $"Dr. {normalizedName}";

                return doctorId.HasValue
                    ? AppLanguageContext.Language == AppLanguages.Arabic
                        ? $"{prefixedName} (الطبيب رقم {doctorId.Value})"
                        : $"{prefixedName} (Doctor #{doctorId.Value})"
                    : prefixedName;
            }

            return doctorId.HasValue
                ? AppLanguageContext.Language == AppLanguages.Arabic ? $"الطبيب رقم {doctorId.Value}" : $"Doctor #{doctorId.Value}"
                : AppLanguageContext.Language == AppLanguages.Arabic ? "الطبيب" : "the doctor";
        }

        public static string FormatPatient(string? fullName, int? patientId = null)
        {
            var normalizedName = string.IsNullOrWhiteSpace(fullName)
                ? null
                : fullName.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedName))
            {
                return patientId.HasValue
                    ? AppLanguageContext.Language == AppLanguages.Arabic
                        ? $"{normalizedName} (المريض رقم {patientId.Value})"
                        : $"{normalizedName} (Patient #{patientId.Value})"
                    : normalizedName;
            }

            return patientId.HasValue
                ? AppLanguageContext.Language == AppLanguages.Arabic ? $"المريض رقم {patientId.Value}" : $"Patient #{patientId.Value}"
                : AppLanguageContext.Language == AppLanguages.Arabic ? "المريض" : "the patient";
        }

        public static string FormatAppointmentDateTime(DateTime slotDate, TimeSpan startTime)
            => FormatDateTime(slotDate.Add(startTime));

        public static string FormatDateTime(DateTime value)
            => value.ToString(
                AppLanguageContext.Language == AppLanguages.Arabic
                    ? "dddd، dd MMM yyyy 'الساعة' hh:mm tt"
                    : "dddd, dd MMM yyyy 'at' hh:mm tt",
                CultureInfo.CurrentCulture);

        public static string FormatDate(DateTime value)
            => value.ToString(
                AppLanguageContext.Language == AppLanguages.Arabic
                    ? "dddd، dd MMM yyyy"
                    : "dddd, dd MMM yyyy",
                CultureInfo.CurrentCulture);

        public static string FormatAmount(decimal amount, string currency = "EGP")
            => AppLanguageContext.Language == AppLanguages.Arabic
                ? $"{amount.ToString("N2", CultureInfo.CurrentCulture)} {(currency == "EGP" ? "ج.م" : currency)}"
                : $"{amount.ToString("N2", CultureInfo.CurrentCulture)} {currency}";

        public static string FormatQuoted(string? value, string fallback)
            => $"\"{(string.IsNullOrWhiteSpace(value) ? fallback : value.Trim())}\"";

        public static string FormatReason(string? reason)
            => string.IsNullOrWhiteSpace(reason)
                ? AppLanguageContext.Language == AppLanguages.Arabic ? "لم يتم تقديم سبب." : "No reason was provided."
                : AppLanguageContext.Language == AppLanguages.Arabic
                    ? $"السبب: {reason.Trim()}."
                    : $"Reason: {reason.Trim()}.";

        public static string FormatPermissionSummary(
            bool canViewMedicalHistory,
            bool canViewPrescriptions,
            bool canViewLabResults)
        {
            var permissions = new List<string>();

            if (canViewMedicalHistory)
            {
                permissions.Add("medical history");
            }

            if (canViewPrescriptions)
            {
                permissions.Add("prescriptions");
            }

            if (canViewLabResults)
            {
                permissions.Add("lab results");
            }

            return permissions.Count == 0
                ? AppLanguageContext.Language == AppLanguages.Arabic ? "لا توجد سجلات" : "no records"
                : string.Join(", ", permissions);
        }
    }
}
