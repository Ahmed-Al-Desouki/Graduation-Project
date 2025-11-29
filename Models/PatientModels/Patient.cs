using HealthCare_.Models.sharedModels;


namespace HealthCare_.Models.PatientModels
{
    public class Patient
    {
        [Key]
        [Required]
        public int PatientID { get; set; }

        //[Required]
        //public DateTime DateOfBirth { get; set; }

        //[Required, StringLength(30)]
        //[MaxLength(20)]
        //public string Gender { get; set; } = "Unknown";

        //[StringLength(200)]
        //public string CurrentLocation { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public ApplicationUser User { get; set; } = null!;
        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();
        public MedicalHistory MedicalHistory { get; set; } = null!;
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicationsIntake> MedicationsIntakes { get; set; } = new List<MedicationsIntake>();
        public ICollection<Reminder> Reminders { get; set; } = new List<Reminder>();
    }

}