using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models
{
    public class Doctor
    {
        [Key]
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public User User { get; set; }
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

        // Attachments for files (with validation for single/multiple in service)
        public ICollection<Attachment> Licenses { get; set; } = new List<Attachment>(); // Links to DoctorLicense
        public ICollection<Attachment> Certificates { get; set; } = new List<Attachment>(); // Links to DoctorCertificate
        public ICollection<Attachment> Bios { get; set; } = new List<Attachment>(); // Links to DoctorBio

        public ICollection<DoctorWeeklySchedule> WeeklySchedules { get; set; }
        public ICollection<DoctorSlot> Slots { get; set; }
        public ICollection<SessionType> SessionTypes { get; set; }
        public ICollection<Appointment> Appointments { get; set; }
        public ICollection<Prescription> Prescriptions { get; set; }
        public ICollection<MedicalRecord> MedicalRecords { get; set; }

    }
}
