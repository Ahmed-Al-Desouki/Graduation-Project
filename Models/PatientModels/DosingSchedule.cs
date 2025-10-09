

namespace HealthCare_.Models.PatientModels
{
    public class DosingSchedule
    {
        [Key]
        [Required]
        public int DosingScheduleID { get; set; }
        [Required]
        public int PrescriptionMedID { get; set; }
        [ForeignKey("PrescriptionMedID")]
        public PrescriptionMed PrescriptionMed { get; set; }
        [Required]
        public TimeSpan DailyTime { get; set; } // e.g., 08:00:00 for 8:00 AM
    }
}
