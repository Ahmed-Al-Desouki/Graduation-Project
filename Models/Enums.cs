namespace HealthCare_.Models
{
    public class Enums
    {
        public enum IntakeStatus
        {
            Taken,
            Missed,
            Skipped
        }

        public enum ReminderType
        {
            Medication,
            Appointment
        }

        public enum ReminderStatus
        {
            Pending,
            Completed,
            Expired
        }
    }
}
