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

        public string TimeZoneId { get; set; } = "Africa/Cairo";

        [Required]
        public string FcmToken { get; set; } = null!;

        //  CRITICAL: ScheduledTime is when the notification should be sent (UTC)
        public DateTime ScheduledTime { get; set; }

        //  CRITICAL: SentAt is when it was actually sent (NULL = not sent yet)
        public DateTime? SentAt { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        //  COMPUTED PROPERTIES - For code use only, NOT for database queries
        [NotMapped]
        public bool IsSent => SentAt.HasValue;

        [NotMapped]
        public bool IsDue => DateTime.UtcNow >= ScheduledTime && !IsSent;

        [NotMapped]
        public int DaysUntilDue => (int)(ScheduledTime - DateTime.UtcNow).TotalDays;
    }
}