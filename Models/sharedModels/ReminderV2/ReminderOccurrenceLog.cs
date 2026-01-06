// File: Models/V2/ReminderOccurrenceLog.cs
using System.ComponentModel.DataAnnotations;
using HealthCare_.Models.EnumForModels;

namespace HealthCare_.Models.V2
{
    public class ReminderOccurrenceLog
    {
        [Key]
        public long Id { get; set; }

        public int PatientId { get; set; } // ✅ ADDED
        public int ReminderId { get; set; }
        public ReminderV2 Reminder { get; set; } = null!;

        // Local for display
        public DateTime DueDateTime { get; set; }

        // UTC for storage and calculations
        public DateTime DueDateTimeUtc { get; set; }

        // FIX: Use OccurrenceStatus
        public Enums.OccurrenceStatus Status { get; set; } = Enums.OccurrenceStatus.Pending;

        public DateTime? ConfirmedAt { get; set; }
        public DateTime? ActionedAt { get; set; } // ✅ ADDED

        public Enums.IntakeStatus? IntakeStatus { get; set; }

        // ADDED: Track if action was within valid window
        public bool ActionedWithinWindow { get; set; } = true;

        // ADDED: For snoozed occurrences
        public bool IsSnoozeFromOriginal { get; set; } = false;
        public DateTime? OriginalDueDateTime { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}