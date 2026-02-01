using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.RemindersInterface
{
    public interface ITimezoneHelper
    {
        DateTime ConvertUtcToUserTimezone(DateTime utcDateTime, string timeZoneId);
        DateTime ConvertUserTimezoneToUtc(DateTime userDateTime, string timeZoneId);
        DateTime EnsureUtc(DateTime dt);
    }
}
