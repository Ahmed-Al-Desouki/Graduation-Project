
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.DoctorModels
{
    public class DoctorWeeklySchedule
    {
        [Key]
        [Required]
        public int ScheduleID { get; set; }
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }
        [Required, StringLength(20)]
        public string DayOfWeek { get; set; }
        [Required]
        public TimeSpan StartTime { get; set; }
        [Required]
        public TimeSpan EndTime { get; set; }
        [Range(1, 120)]
        public int Duration { get; set; } = 30;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
