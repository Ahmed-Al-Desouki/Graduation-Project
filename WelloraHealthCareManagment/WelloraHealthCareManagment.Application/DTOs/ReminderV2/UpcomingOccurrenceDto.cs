using System.Text.Json;
using System.Text.Json.Serialization;
using WelloraHealthCareManagment.Domain.EnumForModels;

namespace HealthCare_.Models.DTOs.V2
{
    public class UpcomingOccurrenceDto
    {
        public int ReminderId { get; set; }
        public string Title { get; set; } = "";
        public string? Message { get; set; }

        [JsonConverter(typeof(DateTimeWithoutTimezoneConverter))]
        public DateTime DueDateTime { get; set; }

        public string TimeZoneId { get; set; } = "Africa/Cairo";
        public Enums.ReminderType Type { get; set; }
        public bool IsMedication { get; set; }
        public string? Dosage { get; set; }

        //  FIX: Use OccurrenceStatus
        public Enums.OccurrenceStatus Status { get; set; }

        //  FIX: Remove hardcoded CanConfirm, make them settable properties
        public bool CanConfirm { get; set; }
        public bool CanSnooze { get; set; }
        public bool CanSkip { get; set; } = true; // Skip always allowed for record-keeping
        public string? ActionUnavailableReason { get; set; }
    }

    public class DateTimeWithoutTimezoneConverter : JsonConverter<DateTime>
    {
        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return DateTime.Parse(reader.GetString()!);
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ToString("yyyy-MM-ddTHH:mm:ss"));
        }
    }
}