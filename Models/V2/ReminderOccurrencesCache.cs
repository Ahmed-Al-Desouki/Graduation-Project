namespace HealthCare_.Models.V2
{
    [Table("ReminderOccurrencesCache")]
    public class ReminderOccurrencesCache
    {
        [Key]
        public long Id { get; set; }

        public int PatientId { get; set; }

        public int ReminderId { get; set; }

        public DateTime DueDateTime { get; set; }   // Local time بتاع المريض

        [Required, MaxLength(200)]
        public string Title { get; set; } = null!;

        [MaxLength(500)]
        public string? Message { get; set; }

        public ReminderType Type { get; set; }

        [MaxLength(100)]
        public string? Dosage { get; set; }

        // 0=Pending, 1=Completed, 2=Skipped, 3=Overdue
        public byte Status { get; set; } = 0;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation (اختياري لو حابب)
        public ReminderV2? Reminder { get; set; }
    }
}
