namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots
{
    public class AvailableSlotDto
    {
        public Guid SlotId { get; set; }
        public DateTime SlotDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public bool IsManuallyCreated { get; set; }
    }
}