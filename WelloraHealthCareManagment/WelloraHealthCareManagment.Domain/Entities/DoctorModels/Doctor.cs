using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;

namespace HealthCare_.Models.DoctorModels
{
    public class Doctor
    {
        [Key]
        public int DoctorId { get; set; }

        [Required, StringLength(100)]
        public string Specialization { get; set; }

        [Range(0, 100)]
        public int YearsOfExperience { get; set; }

        [Range(0, 10000)]
        public decimal ConsultationFee { get; private set; }

        public bool IsActive { get; set; }

        [Range(0, 5)]
        public double AverageRating { get; set; }

        [StringLength(500)]
        public string? Description { get; set; } = "Doctor Description";

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        //Existing Navigation Properties 
        public ApplicationUser User { get; set; } = null!;

        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();

        // NEW BOOKING SYSTEM (Added) 
        public ICollection<DoctorScheduleTemplate> ScheduleTemplates { get; set; } = new List<DoctorScheduleTemplate>();
        public ICollection<ScheduleException> ScheduleExceptions { get; set; } = new List<ScheduleException>();
        public ICollection<TimeSlot> TimeSlots { get; set; } = new List<TimeSlot>();
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicalHistoryAccessGrant> MedicalHistoryAccessGrants { get; set; } = new List<MedicalHistoryAccessGrant>();
        public ICollection<MedicalHistoryAccessLog> MedicalHistoryAccessLogs { get; set; } = new List<MedicalHistoryAccessLog>();

        public void SetConsultationFee(decimal fee)
        {
            if (fee < 0)
                throw new DomainException("Consultation fee cannot be negative");

            ConsultationFee = fee;
        }
    }
}