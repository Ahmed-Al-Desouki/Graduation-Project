namespace HealthCare_.Models.DTOs.V2
{
    // File: Models/DTOs/V2/ReminderV2Dto.cs
    namespace HealthCare_.Models.DTOs.V2
    {
        public class ReminderV2Dto
        {
            public int Id { get; set; }
            public string Title { get; set; } = "";
            public ReminderType Type { get; set; }
            public DateTime StartDate { get; set; }
            public DateTime? EndDate { get; set; }
            public string RRULE { get; set; } = "";
            public string TimeZoneId { get; set; } = "Africa/Cairo";

            // Read-only properties (محسوبة تلقائيًا)
            public bool IsLifetime => EndDate == null;
            public DateTime? NextOccurrence { get; set; }
            public int TakenCount { get; set; }
            public int TotalLogged { get; set; }

            //Important: أضفنا الحقل ده عشان الـ MapToDto يشتغل
            public bool IsActive { get; set; }
            public TimeSpan? BaseTime { get; internal set; }
        }
    }
}
