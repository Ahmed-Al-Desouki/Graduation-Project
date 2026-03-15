using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Schedules
{
    public class UpdateScheduleRequest
    {
        public List<TimeRangeDto> TimeRangesToAdd { get; set; } = new();
        public List<DayOfWeek> TimeRangesToRemove { get; set; } = new();
        public int? NewSlotDurationMinutes { get; set; }
        public int? NewBufferTimeMinutes { get; set; }
    }
}
