using ReminderStatus = HealthCare_.Models.EnumForModels.Enums.ReminderStatus;
using ReminderType = HealthCare_.Models.EnumForModels.Enums.ReminderType;

namespace HealthCare_.Models.DTOs.ReminderDTO
{
    public class ReminderInstanceDto
    {
        public int InstanceID { get; set; }
        public int ReminderID { get; set; }
        public DateTime DueDateTime { get; set; }
        public ReminderStatus Status { get; set; }
        public string? Name { get; set; }
        public string? Message { get; set; }
        public ReminderType Type { get; set; }
        public bool IsMedication { get; set; }
        public string? Dosage { get; set; }
    }
}
