//using System.Text.Json.Serialization;


//namespace HealthCare_.Models.DTOs.ReminderDTO
//{
//    public class CreateReminderDto
//    {
//        [JsonConverter(typeof(JsonStringEnumConverter))]
//        public ReminderType? Type { get; set; }

//        public string? Name { get; set; }
//        public DateTime StartDate { get; set; }
//        public DateTime? EndDate { get; set; }
//        public RepeatFrequency Frequency { get; set; } = RepeatFrequency.Daily;
//        public int? IntervalHours { get; set; }
//        public TimeSpan BaseTime { get; set; } = TimeSpan.FromHours(8);
//        public string? Message { get; set; }
//    }
//}
