namespace HealthCare_.Models.DTOs.V2
{

    public class UpcomingOccurrenceDto
    {
        public int ReminderId { get; set; }
        public string Title { get; set; } = "";
        public string? Message { get; set; }
        public DateTime DueDateTime { get; set; } // Local time
        public ReminderType Type { get; set; }
        public bool IsMedication { get; set; }
        public string? Dosage { get; set; }
        public ReminderStatus Status { get; set; } // Pending / Taken / Missed / Snoozed
        public bool CanSnooze { get; set; } = true;
        public bool CanConfirm => Status == ReminderStatus.Pending || Status == ReminderStatus.Active;
    }
}
