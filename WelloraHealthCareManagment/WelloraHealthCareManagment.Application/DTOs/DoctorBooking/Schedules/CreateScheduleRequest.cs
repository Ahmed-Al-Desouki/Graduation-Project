namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Schedules
{
    public class CreateScheduleRequest
    {
        public string TemplateName { get; set; } = string.Empty;
        public int SlotDurationMinutes { get; set; }
        public int BufferTimeMinutes { get; set; }
        public DateTime EffectiveFromDate { get; set; }
        public DateTime? EffectiveToDate { get; set; }
        public List<TimeRangeDto> TimeRanges { get; set; } = new();
    }

    public class TimeRangeDto
    {
        public DayOfWeek DayOfWeek { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
    }
}