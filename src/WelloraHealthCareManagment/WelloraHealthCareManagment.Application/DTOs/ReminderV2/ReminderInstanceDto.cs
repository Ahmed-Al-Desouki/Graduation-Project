

using WelloraHealthCareManagment.Domain.Enums;

namespace HealthCare_.Models.DTOs.ReminderV2
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
