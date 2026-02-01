using System.Text.Json.Serialization;
using WelloraHealthCareManagment.Domain.EnumForModels;

namespace HealthCare_.Models.DTOs.V2
{
    // DTOs/V2/CreateReminderV2Dto.cs
    public class CreateReminderV2Dto
    {
        public Enums.ReminderType Type { get; set; } = Enums.ReminderType.Medication;
        public string Title { get; set; } = "";
        public string? Message { get; set; }

        public DateTime StartDate { get; set; } = DateTime.Today;
        public DateTime? EndDate { get; set; }

        // طريقتين لتحديد التكرار (الفلاتر يختار واحدة بس)
        public string? RRULE { get; set; } // الطريقة الاحترافية
        public SimpleFrequency? Simple { get; set; } // للي عايز بساطة

        public string TimeZoneId { get; set; } = "Africa/Cairo";
        public int? PrescriptionMedId { get; set; }
        public int? AppointmentId { get; internal set; }
    }

    public class SimpleFrequency
    {
        [JsonPropertyName("frequency")]
        public string Frequency { get; set; } = "Daily";

        [JsonPropertyName("intervalHours")]
        public int? IntervalHours { get; set; }

        [JsonPropertyName("times")]
        public List<string>? Times { get; set; }
    }
}
