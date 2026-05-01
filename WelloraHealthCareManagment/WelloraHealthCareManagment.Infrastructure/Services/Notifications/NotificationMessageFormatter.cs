using System.Globalization;

namespace WelloraHealthCareManagment.Infrastructure.Services.Notifications
{
    public static class NotificationMessageFormatter
    {
        private static readonly CultureInfo EnCulture = CultureInfo.InvariantCulture;

        public static string FormatDoctor(string? fullName, int? doctorId = null)
        {
            var normalizedName = string.IsNullOrWhiteSpace(fullName)
                ? null
                : fullName.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedName))
            {
                var prefixedName = normalizedName.StartsWith("Dr.", StringComparison.OrdinalIgnoreCase)
                    ? normalizedName
                    : $"Dr. {normalizedName}";

                return doctorId.HasValue
                    ? $"{prefixedName} (Doctor #{doctorId.Value})"
                    : prefixedName;
            }

            return doctorId.HasValue
                ? $"Doctor #{doctorId.Value}"
                : "the doctor";
        }

        public static string FormatPatient(string? fullName, int? patientId = null)
        {
            var normalizedName = string.IsNullOrWhiteSpace(fullName)
                ? null
                : fullName.Trim();

            if (!string.IsNullOrWhiteSpace(normalizedName))
            {
                return patientId.HasValue
                    ? $"{normalizedName} (Patient #{patientId.Value})"
                    : normalizedName;
            }

            return patientId.HasValue
                ? $"Patient #{patientId.Value}"
                : "the patient";
        }

        public static string FormatAppointmentDateTime(DateTime slotDate, TimeSpan startTime)
            => slotDate.Add(startTime).ToString("dddd, dd MMM yyyy 'at' hh:mm tt", EnCulture);

        public static string FormatDateTime(DateTime value)
            => value.ToString("dddd, dd MMM yyyy 'at' hh:mm tt", EnCulture);

        public static string FormatDate(DateTime value)
            => value.ToString("dddd, dd MMM yyyy", EnCulture);

        public static string FormatAmount(decimal amount, string currency = "EGP")
            => $"{amount:F2} {currency}";

        public static string FormatQuoted(string? value, string fallback)
            => $"\"{(string.IsNullOrWhiteSpace(value) ? fallback : value.Trim())}\"";

        public static string FormatReason(string? reason)
            => string.IsNullOrWhiteSpace(reason)
                ? "No reason was provided."
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
                ? "no records"
                : string.Join(", ", permissions);
        }
    }
}
