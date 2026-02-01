

using HealthCare_.Models.PatientModels.Appointments;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.DoctorModels
{
    public class DoctorSlot
    {
        [Key]
        [Required]
        public int SlotID { get; set; }
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }
        [Required]
        public DateTime SlotDate { get; set; }
        [Range(1, 120)]
        public int Duration { get; set; } = 30;
        public bool IsBooked { get; set; } = false;
        public int? AppointmentID { get; set; }
        public Appointment Appointment { get; set; } // Remove [ForeignKey] here
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}