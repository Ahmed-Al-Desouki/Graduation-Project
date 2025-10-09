namespace HealthCare_.Models.Enums
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
        public enum ExternalFileCategory
        {
            License,
            Certificate,
            Bio,
            LabTest,
            Radiology,
            Other
        }
    }
}
