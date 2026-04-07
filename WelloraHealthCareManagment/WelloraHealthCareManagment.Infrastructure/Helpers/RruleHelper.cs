using System.Text.RegularExpressions;

namespace WelloraHealthCareManagment.Infrastructure.Helpers
{
    public static class RruleHelper
    {
        /// <summary>
        /// Clamps a nullable date to Max(date, today UTC).
        /// Prevents building cache for past occurrences.
        /// </summary>
        public static DateTime ClampToTodayUtc(DateTime? date)
            => date.HasValue
                ? new[] { date.Value.ToUniversalTime(), DateTime.UtcNow.Date }.Max()
                : DateTime.UtcNow.Date;

        /// <summary>
        /// Advances dtStart forward to the first calendar day
        /// that matches the BYDAY constraint in the RRULE.
        /// For FREQ=DAILY or no BYDAY, returns dtStart unchanged.
        /// Prevents iCal.NET from firing a spurious first occurrence
        /// on the DTSTART date when it doesn't match the recurrence pattern.
        /// </summary>
        public static DateTime AdvanceDtStartToFirstValidOccurrence(
            DateTime dtStart,
            string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return dtStart;

            var dayMatch = Regex.Match(rrule, @"BYDAY=([\w,]+)", RegexOptions.IgnoreCase);
            if (!dayMatch.Success)
                return dtStart; // FREQ=DAILY or FREQ=HOURLY — no day constraint

            var allowedDays = dayMatch.Groups[1].Value
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(MapRfc5545ToDayOfWeek)
                .ToHashSet();

            // Walk forward up to 7 days to find the first matching day
            for (int offset = 0; offset < 7; offset++)
            {
                var candidate = dtStart.Date.AddDays(offset);
                if (allowedDays.Contains(candidate.DayOfWeek))
                    return candidate.Add(dtStart.TimeOfDay);
            }

            // Fallback (should never happen with a valid BYDAY list)
            return dtStart;
        }

        /// <summary>
        /// Removes any embedded DTSTART from an RRULE string.
        /// iCal.NET requires DTSTART to be set on the CalendarEvent,
        /// not embedded in the RRULE text.
        /// </summary>
        public static string RemoveDtStartFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return rrule;

            return Regex.Replace(
                rrule,
                @"DTSTART[^;]*;?",
                string.Empty,
                RegexOptions.IgnoreCase)
                .Trim(';', ' ');
        }

        /// <summary>
        /// Extracts the first BYHOUR and BYMINUTE values from an RRULE string.
        /// Returns null for each if not present.
        /// </summary>
        public static (int? hour, int? minute) ExtractFirstTimeFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return (null, null);

            int? hour = null;
            int? minute = null;

            var hourMatch = Regex.Match(rrule, @"BYHOUR=([\d,]+)", RegexOptions.IgnoreCase);
            if (hourMatch.Success)
            {
                var first = hourMatch.Groups[1].Value.Split(',')[0];
                if (int.TryParse(first, out var h))
                    hour = h;
            }

            var minuteMatch = Regex.Match(rrule, @"BYMINUTE=([\d,]+)", RegexOptions.IgnoreCase);
            if (minuteMatch.Success)
            {
                var first = minuteMatch.Groups[1].Value.Split(',')[0];
                if (int.TryParse(first, out var m))
                    minute = m;
            }

            return (hour, minute);
        }

        private static DayOfWeek MapRfc5545ToDayOfWeek(string rfc5545Day) =>
            rfc5545Day.Trim().ToUpperInvariant() switch
            {
                "MO" => DayOfWeek.Monday,
                "TU" => DayOfWeek.Tuesday,
                "WE" => DayOfWeek.Wednesday,
                "TH" => DayOfWeek.Thursday,
                "FR" => DayOfWeek.Friday,
                "SA" => DayOfWeek.Saturday,
                "SU" => DayOfWeek.Sunday,
                _ => throw new ArgumentException($"Unknown RFC5545 day: {rfc5545Day}")
            };
    }
}
