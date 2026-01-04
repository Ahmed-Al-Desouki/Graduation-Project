// File: Models/EnumForModels/Enums.cs
namespace HealthCare_.Models.EnumForModels
{
     // Status for individual occurrence instances(cache + logs)
    public enum OccurrenceStatus : byte
    {
        Scheduled = 0,    // Future, not yet actionable
        Pending = 1,      // Within action window (-30min to +2h)
        Taken = 2,        // User confirmed
        Skipped = 3,      // User explicitly skipped
        Snoozed = 4,      // Postponed (creates new occurrence)
        Missed = 5,       // Window expired without action
        Expired = 6       // Too late to act (>2h grace)
    }

    //  Status for the master reminder entity
    public enum ReminderStatus
    {
        Active = 0,
        Paused = 1,
        Completed = 2,
        Dismissed = 3
    }

    public enum IntakeStatus
    {
        Taken = 0,
        PartiallyTaken = 1,
        Missed = 2,
        Skipped = 3
    }

    public enum ReminderType
    {
        Medication = 0,
        Appointment = 1,
        Custom = 2
    }

    public enum RepeatFrequency
    {
        Once = 0,
        Daily = 1,
        Weekly = 2,
        EveryXHours = 3
    }

    //  KEEP the static Enums wrapper for backward compatibility
    public static class Enums
    {
        // Expose all enums as nested types
        public enum IntakeStatus
        {
            Taken = 0,
            PartiallyTaken = 1,
            Missed = 2,
            Skipped = 3
        }

        public enum ReminderStatus
        {
            Active = 0,
            Paused = 1,
            Completed = 2,
            Dismissed = 3,
            Skipped = 4,
            Pending = 5
        }

        public enum OccurrenceStatus : byte
        {
            Scheduled = 0,
            Pending = 1,
            Taken = 2,
            Skipped = 3,
            Snoozed = 4,
            Missed = 5,
            Expired = 6
        }

        public enum ReminderType
        {
            Medication = 0,
            Appointment = 1,
            Custom = 2
        }

        public enum RepeatFrequency
        {
            Once = 0,
            Daily = 1,
            Weekly = 2,
            EveryXHours = 3
        }
    }
}