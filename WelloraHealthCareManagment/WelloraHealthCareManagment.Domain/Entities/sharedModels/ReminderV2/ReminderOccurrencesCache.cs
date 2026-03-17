// File: Models/V2/ReminderOccurrencesCache.cs
using HealthCare_.Models.DoctorModels;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace HealthCare_.Models.V2
{
    [Table("ReminderOccurrencesCache")]
    public class ReminderOccurrencesCache
    {
        [Key]
        public long Id { get; set; }

        public int? PatientId { get; set; }
        public int? DoctorId { get; set; }
        public int ReminderId { get; set; }

        // Local time for display
        public DateTime DueDateTime { get; set; }

        // UTC for storage and internal calculations
        public DateTime DueDateTimeUtc { get; set; }
        public string TimeZoneId { get; set; } = "Africa/Cairo";

        [Required, MaxLength(200)]
        public string Title { get; set; } = null!;

        [MaxLength(500)]
        public string? Message { get; set; }

        public ReminderEnums.ReminderType Type { get; set; }

        [MaxLength(100)]
        public string? Dosage { get; set; }

        //  FIX: Use OccurrenceStatus instead of byte
        public ReminderEnums.OccurrenceStatus Status { get; set; } = ReminderEnums.OccurrenceStatus.Scheduled;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation (optional)
        public ReminderV2? Reminder { get; set; }
        public Doctor? Doctor { get; set; }
        public Patient? Patient { get; set; }
    }
}