using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Interfaces.RemindersInterface;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class TimezoneHelper : ITimezoneHelper
    {
        public DateTime EnsureUtc(DateTime dt) =>
            dt.Kind == DateTimeKind.Utc ? dt : DateTime.SpecifyKind(dt, DateTimeKind.Utc);

        public DateTime ConvertUtcToUserTimezone(DateTime utcDateTime, string timeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId ?? "Africa/Cairo");
            return TimeZoneInfo.ConvertTimeFromUtc(EnsureUtc(utcDateTime), tz);
        }

        public DateTime ConvertUserTimezoneToUtc(DateTime userDateTime, string timeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId ?? "Africa/Cairo");
            var unspecified = DateTime.SpecifyKind(userDateTime, DateTimeKind.Unspecified);
            return TimeZoneInfo.ConvertTimeToUtc(unspecified, tz);
        }
    }
}
