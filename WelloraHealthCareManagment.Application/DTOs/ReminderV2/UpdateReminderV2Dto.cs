// File: Models/DTOs/V2/UpdateReminderV2Dto.cs
using System.Text.Json.Serialization;
using WelloraHealthCareManagment.Domain.EnumForModels;

namespace HealthCare_.Models.DTOs.V2
{
    public class UpdateReminderV2Dto
    {
        public string? Title { get; set; }
        public string? Message { get; set; }

        [JsonPropertyName("startDate")]
        public DateTime? StartDate { get; set; }

        [JsonPropertyName("endDate")]
        public DateTime? EndDate { get; set; }

        [JsonPropertyName("rRule")]
        public string? RRULE { get; set; }

        [JsonPropertyName("simple")]
        public SimpleFrequency? Simple { get; set; }

        public string? TimeZoneId { get; set; }
        public bool? IsActive { get; set; }
        public Enums.ReminderStatus? Status { get; set; }
    }
}