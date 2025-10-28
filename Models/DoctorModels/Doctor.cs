
namespace HealthCare_.Models.DoctorModels
{
    public class Doctor
    {
        [Key]
        [Required]
        public int DoctorID { get; set; }

        [Required]
        public int UserID { get; set; }
        [ForeignKey(nameof(UserID))]
        public ApplicationUser User { get; set; }

        [Required, StringLength(100)]
        public string Specialization { get; set; }

        [Range(0, 100)]
        public int YearsOfExperience { get; set; }

        [Range(0, 10000)]
        public decimal ConsultationFee { get; set; }
        public bool IsActive { get; set; }

        [Range(0, 5)]
        public double AverageRating { get; set; }

        [StringLength(500)]
        public string Description { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();
        public ICollection<DoctorWeeklySchedule> WeeklySchedules { get; set; } = new List<DoctorWeeklySchedule>();
        public ICollection<DoctorSlot> Slots { get; set; } = new List<DoctorSlot>();
        public ICollection<SessionType> SessionTypes { get; set; } = new List<SessionType>();
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicalRecord> MedicalRecords { get; set; } = new List<MedicalRecord>();
    }
}
