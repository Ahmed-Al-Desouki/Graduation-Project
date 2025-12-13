namespace HealthCare_.Models.DTOs.V2
{
    public class ConfirmIntakeRequests
    {
        public class ConfirmIntakeRequest
        {
            public int ReminderId { get; set; }
            public Enums.IntakeStatus Status { get; set; } = Enums.IntakeStatus.Taken;
        }

        public class RequiredReminderIdRequest
        {
            public int ReminderId { get; set; }
        }
    }
}
