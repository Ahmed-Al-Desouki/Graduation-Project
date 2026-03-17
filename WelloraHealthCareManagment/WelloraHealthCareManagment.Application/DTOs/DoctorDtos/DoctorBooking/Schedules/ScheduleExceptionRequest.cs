namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Schedules
{
    public class CreateDayOffRequest
    {
        public DateTime Date { get; set; }
        public string? Reason { get; set; }
    }

    public class CreateCustomHoursRequest
    {
        public DateTime Date { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public string? Reason { get; set; }
    }
}