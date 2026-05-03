using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments
{
    public class BookFollowUpExistingRequest
    {
        public Guid SlotId { get; set; }       
        public string? PatientNotes { get; set; }
        public string? FollowUpInstructions { get; set; }
    }

    // Request لإنشاء slot جديد + حجزه
    public class BookFollowUpNewRequest
    {
        public DateTime? FollowUpDate { get; set; }     
        public TimeSpan? StartTime { get; set; }   
        public int DurationMinutes { get; set; } = 30;
        public string? PatientNotes { get; set; }
        public string? FollowUpInstructions { get; set; }
    }

    public class FollowUpResponse
    {
        public Guid NewAppointmentId { get; set; }
        public Guid NewTimeSlotId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
