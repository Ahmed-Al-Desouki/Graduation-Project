using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models
{
    public class Patient
    {
        [Key]
        [Required]
        public int PatientID { get; set; }
        [ForeignKey("PatientID")]
        public User User { get; set; }
        [Required]
        public DateTime DateOfBirth { get; set; }
        [Required, StringLength(10)]
        public string Gender { get; set; }
        [StringLength(200)] // e.g., "lat,long"
        public string CurrentLocation { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public ICollection<MedicalHistory> MedicalHistories { get; set; }
        public ICollection<Appointment> Appointments { get; set; }
        public ICollection<Prescription> Prescriptions { get; set; }
        public ICollection<MedicationsIntake> MedicationsIntakes { get; set; }
        public ICollection<Reminder> Reminders { get; set; }
    }
}