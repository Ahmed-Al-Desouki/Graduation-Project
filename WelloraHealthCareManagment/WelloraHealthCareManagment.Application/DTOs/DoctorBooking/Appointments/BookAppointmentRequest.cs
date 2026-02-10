namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Appointments
{
    public class BookAppointmentRequest
    {
        public Guid TimeSlotId { get; set; }
        public string? PatientNotes { get; set; }
        public bool GrantMedicalHistoryAccess { get; set; } = true;
    }

    public class BookAppointmentResponse
    {
        public Guid AppointmentId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan AppointmentTime { get; set; }
        public string DoctorName { get; set; } = string.Empty;
        public bool MedicalHistoryAccessGranted { get; set; }
    }
}