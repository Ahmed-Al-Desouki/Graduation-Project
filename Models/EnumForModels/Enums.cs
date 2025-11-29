// File: Models/EnumForModels/Enums.cs
namespace HealthCare_.Models.EnumForModels
{
    public static class Enums
    {
        public enum IntakeStatus
        {
            Taken,
            Missed,
            Skipped
        }

        public enum ReminderStatus
        {
            Pending,
            Active,
            Completed,
            Overdue,
            Expired,
            Dismissed
        }

        public enum ReminderType
        {
            Medication,
            Appointment,
            Custom
        }

        public enum RepeatFrequency
        {
            Once,
            Daily,
            Weekly,
            EveryXHours
        }

        // أي enums تانية تحتفظ بيها هنا
    }
}