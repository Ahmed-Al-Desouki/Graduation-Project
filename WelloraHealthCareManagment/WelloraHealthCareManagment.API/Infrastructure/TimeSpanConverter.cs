using System.Text.Json;
using System.Text.Json.Serialization;

namespace HealthCare_.Infrastructure
{

    public class TimeSpanConverter : JsonConverter<TimeSpan>
    {
        public override TimeSpan Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var value = reader.GetString();

            if (string.IsNullOrWhiteSpace(value))
                return TimeSpan.Zero;

            // 1. صيغة كاملة: "14:30:00" أو "08:00"
            if (TimeSpan.TryParse(value, out var ts))
                return ts;

            // 2. رقم ساعة بس: "8" أو "20"
            if (int.TryParse(value, out var hours))
                return TimeSpan.FromHours(hours);

            // 3. صيغة قصيرة زي "8pm" أو "2pm" (اختياري)
            if (value.Length >= 2 && value[^2] is 'p' or 'P' && int.TryParse(value[..^2], out hours))
            {
                hours = hours == 12 ? 12 : hours + 12;
                return TimeSpan.FromHours(hours);
            }
            if (value.Length >= 2 && value[^2] is 'a' or 'A' && int.TryParse(value[..^2], out hours))
            {
                hours = hours == 12 ? 0 : hours;
                return TimeSpan.FromHours(hours);
            }

            throw new JsonException($"Unable to convert \"{value}\" to TimeSpan. Use formats like \"08:00\", \"14:30\", \"8\", \"20\"");
        }

        public override void Write(Utf8JsonWriter writer, TimeSpan value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ToString(@"hh\:mm"));
        }
    }

}
