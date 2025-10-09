

namespace HealthCare_.Models.PatientModels
{
    public class Patient
    {
        [Key]
        [Required]
        public int PatientID { get; set; }

        [Required]
        public int UserID { get; set; }
        [ForeignKey(nameof(UserID))]
        public ApplicationUser User { get; set; }

        [Required]
        public DateTime DateOfBirth { get; set; }

        [Required, StringLength(10)]
        public string Gender { get; set; }

        [StringLength(200)]
        public string CurrentLocation { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<MedicalHistory> MedicalHistories { get; set; } = new List<MedicalHistory>();
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicationsIntake> MedicationsIntakes { get; set; } = new List<MedicationsIntake>();
        public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
    }

}