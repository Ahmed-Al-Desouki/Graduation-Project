namespace HealthCare_.Models.DTOs.V2
{
    public class ConfirmIntakeRequests
    {
        public class ConfirmIntakeRequest
        {
            public int ReminderId { get; set; }
            public IntakeStatus Status { get; set; } = IntakeStatus.Taken;
        }

        public class RequiredReminderIdRequest
        {
            public int ReminderId { get; set; }
        }
    }
}
