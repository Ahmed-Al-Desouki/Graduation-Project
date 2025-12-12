using System.Text.Json;
using System.Text.Json.Serialization;

namespace HealthCare_.Models.DTOs.V2
{

    public class UpcomingOccurrenceDto
    {
        public int ReminderId { get; set; }
        public string Title { get; set; } = "";
        public string? Message { get; set; }
        [JsonConverter(typeof(DateTimeWithoutTimezoneConverter))]
        public DateTime DueDateTime { get; set; } 
        public ReminderType Type { get; set; }
        public bool IsMedication { get; set; }
        public string? Dosage { get; set; }
        public ReminderStatus Status { get; set; } // Pending / Taken / Missed / Snoozed
        public string TimeZoneId { get; set; } = "Africa/Cairo";
        public bool CanSnooze { get; set; } = true;
        public bool CanConfirm => Status == ReminderStatus.Pending || Status == ReminderStatus.Active;
    }
    public class DateTimeWithoutTimezoneConverter : JsonConverter<DateTime>
    {
        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return DateTime.Parse(reader.GetString()!);
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            // Write DateTime without timezone suffix (no Z)
            writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss"));
        }
    }
}
