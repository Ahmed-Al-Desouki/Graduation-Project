using WelloraHealthCareManagment.Domain.EnumForModels;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorBooking.Prescriptions
{
    public class CreatePrescriptionRequest
    {
        public Guid AppointmentId { get; set; }
        public DateTime? ValidUntil { get; set; }
        public string? SpecialInstructions { get; set; }
        public List<PrescriptionItemRequest> Items { get; set; } = new();
    }

    public class PrescriptionItemRequest
    {
        public string MedicationName { get; set; } = string.Empty;
        public string? MedicationCode { get; set; }
        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public string? Instructions { get; set; }

        public RepeatFrequency? ReminderFrequencyType { get; set; }  // Enum (OnceOnly, Daily, Weekly, Monthly, EveryXHours)
        public List<DayOfWeek>? ReminderWeeklyDays { get; set; }     // e.g., [Sunday, Wednesday]
        public List<string>? ReminderDailyDoseTimes { get; set; }    // e.g., ["10:00", "17:00"] – strings من time picker
        public int? ReminderIntervalHours { get; set; }              // لـ EveryXHours
        public DateTime? ReminderStartDate { get; set; }
        public DateTime? ReminderEndDate { get; set; }
        public string? ReminderFirstDoseTime { get; set; }
    }

    public class PrescriptionResponse
    {
        public Guid PrescriptionId { get; set; }
        public string PrescriptionNumber { get; set; } = string.Empty;
        public DateTime IssuedAt { get; set; }
        public DateTime? ValidUntil { get; set; }
        public List<PrescriptionItemDto> Items { get; set; } = new();
    }

    public class PrescriptionItemDto
    {
        public Guid ItemId { get; set; }
        public string MedicationName { get; set; } = string.Empty;
        public string Dosage { get; set; } = string.Empty;
        public string Frequency { get; set; } = string.Empty;
        public string Duration { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public string? Instructions { get; set; }
    }
    public class AddPrescriptionItemsRequest
    {
        public List<PrescriptionItemRequest> Items { get; set; } = new();
    }
}