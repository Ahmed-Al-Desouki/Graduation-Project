using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace HealthCare_.Models.DTOs.V2
{
    public class ConfirmIntakeRequests
    {
        public class ConfirmIntakeRequest
        {
            public int ReminderId { get; set; }
            public ReminderEnums.IntakeStatus Status { get; set; } = ReminderEnums.IntakeStatus.Taken;
        }

        public class RequiredReminderIdRequest
        {
            public int ReminderId { get; set; }
        }
    }
}
