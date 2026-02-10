namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.TimeSlots
{
    public class GenerateSlotsRequest
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool RegenerateExisting { get; set; } = false;
    }

    public class GenerateSlotsResponse
    {
        public int SlotsGenerated { get; set; }
        public int SlotsSkipped { get; set; }
        public DateTime GeneratedFrom { get; set; }
        public DateTime GeneratedTo { get; set; }
    }
}