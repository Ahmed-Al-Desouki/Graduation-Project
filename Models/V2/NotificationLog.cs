using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.V2
{
    [Table("NotificationLogs")]
    public class NotificationLog
    {
        [Key]
        public long Id { get; set; }

        public int PatientId { get; set; }
        public int ReminderId { get; set; }
        public long OccurrenceId { get; set; } // Reference to ReminderOccurrencesCache.Id
        public string TimeZoneId { get; set; } = "Africa/Cairo"; // Add this column

        [Required]
        public string FcmToken { get; set; } = null!;

        public DateTime ScheduledTime { get; set; } // When it should be sent (UTC)
        public DateTime? SentAt { get; set; }       // When it was actually sent
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsSent => SentAt.HasValue;
        public bool IsDue => DateTime.UtcNow >= ScheduledTime && !IsSent;
    }
}