namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots
{
    public class GenerateSlotsRequest
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool RegenerateExisting { get; set; } = false;

        // ولّد للأيام الجديدة بس (اللي اتضافت للـ template)
        public List<DayOfWeek>? OnlyForDays { get; set; }

        // عدد الـ slots في الـ batch (default: 1000)
        public int BatchSize { get; set; } = 1000;
    }

    public class GenerateSlotsResponse
    {
        public int SlotsGenerated { get; set; }
        public int SlotsSkipped { get; set; }
        public DateTime GeneratedFrom { get; set; }
        public DateTime GeneratedTo { get; set; }
        public int BatchesProcessed { get; set; }
        public TimeSpan ProcessingTime { get; set; }
    }
}