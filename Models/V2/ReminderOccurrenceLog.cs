// File: Models/V2/ReminderOccurrenceLog.cs
using System.ComponentModel.DataAnnotations;
using HealthCare_.Models.EnumForModels;

namespace HealthCare_.Models.V2
{
    public class ReminderOccurrenceLog
    {
        [Key]
        public long Id { get; set; } // long عشان يستحمل ملايين السجلات

        public int ReminderId { get; set; }
        public ReminderV2 Reminder { get; set; } = null!;

        // Local للعرض
        public DateTime DueDateTime { get; set; }

        // UTC للتخزين والحسابات
        public DateTime DueDateTimeUtc { get; set; }

        public ReminderStatus Status { get; set; } = ReminderStatus.Pending;

        public DateTime? ConfirmedAt { get; set; }
        public IntakeStatus? IntakeStatus { get; set; } // Taken / Missed / Skipped

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
