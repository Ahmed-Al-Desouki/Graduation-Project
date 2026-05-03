namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.TimeSlots
{
    public class RestoreBlockedSlotsRequest
    {
        public List<Guid> SlotIds { get; set; } = new();
    }
}
