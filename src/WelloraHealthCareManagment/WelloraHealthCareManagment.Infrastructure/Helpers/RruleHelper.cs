using System.Text.RegularExpressions;

namespace WelloraHealthCareManagment.Infrastructure.Helpers
{
    public static class RruleHelper
    {
        public static DateTime ClampToTodayUtc(DateTime? date)
            => date.HasValue
                ? new[] { date.Value.ToUniversalTime(), DateTime.UtcNow.Date }.Max()
                : DateTime.UtcNow.Date;

        /// <summary>
        /// Advances dtStart forward to the first calendar day
        /// that matches the recurrence constraints in the RRULE.
        /// Handles both BYDAY (weekly) and BYMONTHDAY (monthly) constraints.
        /// For FREQ=DAILY or FREQ=HOURLY with no day constraint, returns dtStart unchanged.
        /// Prevents iCal.NET from firing a spurious first occurrence
        /// on the DTSTART date when it doesn't match the recurrence pattern.
        /// </summary>
        public static DateTime AdvanceDtStartToFirstValidOccurrence(
            DateTime dtStart,
            string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return dtStart;

            // ✅ FIX: Handle BYMONTHDAY (e.g. FREQ=MONTHLY;BYMONTHDAY=16)
            var monthDayMatch = Regex.Match(rrule, @"BYMONTHDAY=([\d,]+)", RegexOptions.IgnoreCase);
            if (monthDayMatch.Success)
            {
                var allowedMonthDays = monthDayMatch.Groups[1].Value
                    .Split(',', StringSplitOptions.RemoveEmptyEntries)
                    .Select(d => int.Parse(d.Trim()))
                    .ToHashSet();

                // Walk forward up to 31 days to find the first matching day-of-month
                for (int offset = 0; offset < 31; offset++)
                {
                    var candidate = dtStart.Date.AddDays(offset);
                    if (allowedMonthDays.Contains(candidate.Day))
                        return candidate.Add(dtStart.TimeOfDay);
                }

                // Fallback (should never happen with a valid BYMONTHDAY list)
                return dtStart;
            }

            // Handle BYDAY (e.g. FREQ=WEEKLY;BYDAY=SA,SU,MO)
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

        public static string RemoveDtStartFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return rrule;

            // CASE 1: Multi-line iCal format — "DTSTART:...\nRRULE:FREQ=..."
            var rruleLineMatch = Regex.Match(
                rrule,
                @"^RRULE:(.+)$",
                RegexOptions.IgnoreCase | RegexOptions.Multiline);

            if (rruleLineMatch.Success)
                return rruleLineMatch.Groups[1].Value.Trim();

            // CASE 2: Single-line with "RRULE:" prefix
            if (rrule.StartsWith("RRULE:", StringComparison.OrdinalIgnoreCase))
                return rrule.Substring(6).Trim();

            // ✅ FIX CASE 3: DTSTART;TZID=... format (used by AppointmentReminderService)
            // e.g. "DTSTART;TZID=Africa/Cairo:20260411T090000;FREQ=DAILY;COUNT=1;BYHOUR=9;BYMINUTE=0"
            // Remove everything from DTSTART up to and including the first semicolon AFTER the date value
            var tzidMatch = Regex.Match(
                rrule,
                @"^DTSTART;TZID=[^:]+:[^;]+;(.+)$",
                RegexOptions.IgnoreCase);

            if (tzidMatch.Success)
                return tzidMatch.Groups[1].Value.Trim();

            // CASE 4: Already clean — "FREQ=DAILY;..."
            return Regex.Replace(
                rrule,
                @"DTSTART:[^\r\n;]*;?",
                string.Empty,
                RegexOptions.IgnoreCase)
                .Trim(';', ' ');
        }

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

        // ✅ FIX Issue 3: New public helper — returns BYDAY days set, or null if no BYDAY
        public static HashSet<DayOfWeek>? GetAllowedDaysFromRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return null;

            var dayMatch = Regex.Match(rrule, @"BYDAY=([\w,]+)", RegexOptions.IgnoreCase);
            if (!dayMatch.Success)
                return null;

            return dayMatch.Groups[1].Value
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(MapRfc5545ToDayOfWeek)
                .ToHashSet();
        }

        // ✅ FIX: Changed from private to public (needed by GetAllowedDaysFromRRule callers)
        public static DayOfWeek MapRfc5545ToDayOfWeek(string rfc5545Day) =>
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
        /// <summary>
        /// Detects RRULE with multiple paired BYHOUR+BYMINUTE values.
        /// Returns list of (hour, minute) pairs if found, null if single time.
        /// e.g. BYHOUR=9,14,17;BYMINUTE=30,0,0 → [(9,30),(14,0),(17,0)]
        /// </summary>
        public static List<(int hour, int minute)>? TryExpandMultiTimeRRule(string rrule)
        {
            if (string.IsNullOrWhiteSpace(rrule))
                return null;

            var hourMatch = Regex.Match(rrule, @"BYHOUR=([\d,]+)", RegexOptions.IgnoreCase);
            var minuteMatch = Regex.Match(rrule, @"BYMINUTE=([\d,]+)", RegexOptions.IgnoreCase);

            if (!hourMatch.Success || !minuteMatch.Success)
                return null;

            var hours = hourMatch.Groups[1].Value
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(int.Parse)
                .ToList();

            var minutes = minuteMatch.Groups[1].Value
                .Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(int.Parse)
                .ToList();

            // Single time — no cross-product issue
            if (hours.Count <= 1 && minutes.Count <= 1)
                return null;

            // Paired mode: zip hours with minutes (longest list wins, pad with 0)
            var count = Math.Max(hours.Count, minutes.Count);
            var pairs = new List<(int, int)>();

            for (int i = 0; i < count; i++)
            {
                var h = i < hours.Count ? hours[i] : hours.Last();
                var m = i < minutes.Count ? minutes[i] : 0;
                pairs.Add((h, m));
            }

            return pairs;
        }

        /// <summary>
        /// Replaces BYHOUR and BYMINUTE in an RRULE with single values.
        /// e.g. BYHOUR=9,14,17;BYMINUTE=30,0,0 with h=9,m=30 → BYHOUR=9;BYMINUTE=30
        /// </summary>
        public static string ReplaceTimeInRRule(string rrule, int hour, int minute)
        {
            var result = Regex.Replace(
                rrule,
                @"BYHOUR=[\d,]+",
                $"BYHOUR={hour}",
                RegexOptions.IgnoreCase);

            result = Regex.Replace(
                result,
                @"BYMINUTE=[\d,]+",
                $"BYMINUTE={minute}",
                RegexOptions.IgnoreCase);

            return result;
        }
    }
}