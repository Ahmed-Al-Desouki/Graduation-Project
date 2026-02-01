using HealthCare_.Models.DoctorModels;
using HealthCare_.Models.PatientModels.Prescriptions;
using HealthCare_.Models.sharedModels.Reviews;
using HealthCare_.Models.V2;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace HealthCare_.Models.PatientModels.Appointments
{
    public class Appointment
    {
        [Key]
        [Required]
        public int AppointmentID { get; set; }
        [Required]
        public int PatientID { get; set; }
        [ForeignKey("PatientID")]
        public Patient Patient { get; set; }
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }
        [Required]
        public DateTime AppointmentDate { get; set; }
        [StringLength(500)]
        public string Symptoms { get; set; }
        [Required, StringLength(50)]
        public string Status { get; set; }
        [StringLength(50)]
        public string Type { get; set; }
        [Range(1, 120)]
        public int Duration { get; set; }
        [StringLength(50)]
        public string EmergencyLevel { get; set; }
        public bool IsReviewed { get; set; }
        [Required]
        public int SlotID { get; set; }
        [ForeignKey("SlotID")]
        public DoctorSlot Slot { get; set; }
        public DateTime BookingDate { get; set; } = DateTime.Now;
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        // Added missing navigation property
        public ICollection<Review> Reviews { get; set; } // Already added previously
        public ICollection<ReminderV2> Reminders { get; set; } // Added this to fix the error
                                                             // أضف ده مع باقي الـ navigation properties
        public Prescription? Prescription { get; set; }
    }
}