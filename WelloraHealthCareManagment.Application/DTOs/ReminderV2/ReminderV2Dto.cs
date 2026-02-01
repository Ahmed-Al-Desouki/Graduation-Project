using WelloraHealthCareManagment.Domain.EnumForModels;

namespace HealthCare_.Models.DTOs.V2
{
    public class ReminderV2Dto
    {
        public int Id { get; set; }
        public string Title { get; set; } = "";
        public Enums.ReminderType Type { get; set; }
        public string? Message { get; set; }  // أضفناه
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string TimeZoneId { get; set; } = "Africa/Cairo";

        // الحقول الجديدة اللي لازم تكون موجودة
        public bool IsSimpleEveryXHours { get; set; }
        public TimeSpan? FirstDoseTime { get; set; }
        public int? IntervalHours { get; set; }

        public string RRULE { get; set; } = "";
        public string? EXDATE { get; set; }   // أضفناه

        // Read-only
        public bool IsLifetime => EndDate == null;
        public DateTime? NextOccurrence { get; set; }
        public int TakenCount { get; set; }
        public int TotalLogged { get; set; }
        public bool IsActive { get; set; }
    }
}