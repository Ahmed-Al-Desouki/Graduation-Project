using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Exceptions;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;

namespace HealthCare_.Models.DoctorModels
{
    public class Doctor
    {
        [Key]
        public int DoctorId { get; set; }

        [Range(0, 10000)]
        public decimal ConsultationFee { get; private set; }

        public bool IsActive { get; set; }

        [Range(0, 5)]
        public double AverageRating { get; set; }

        [StringLength(1000)]
        public string? Bio { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        //Existing Navigation Properties 
        public ApplicationUser User { get; set; } = null!;
        // ─── بيانات شخصية جديدة ───
        public DateTime? DateOfBirth { get; set; }
        public string? NationalId { get; set; }
        [Required, StringLength(100)]
        public string Specialization { get; set; }

        [Range(0, 100)]
        public int YearsOfExperience { get; set; }

        // ─── موقع العيادة ───
        public string? ClinicAddress { get; set; }
        public double? ClinicLatitude { get; set; }
        public double? ClinicLongitude { get; set; }
        public string? HospitalName { get; set; }

        // ─── حالة البروفايل ───
        public bool IsProfileCompleted { get; set; } = false;

        // ─── Navigation Properties ───
        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();
        //public ICollection<DoctorScheduleTemplate> ScheduleTemplates { get; set; } = new List<DoctorScheduleTemplate>();
        public ICollection<ScheduleException> ScheduleExceptions { get; set; } = new List<ScheduleException>();
        public ICollection<TimeSlot> TimeSlots { get; set; } = new List<TimeSlot>();
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicalHistoryAccessGrant> MedicalHistoryAccessGrants { get; set; } = new List<MedicalHistoryAccessGrant>();
        public ICollection<MedicalHistoryAccessLog> MedicalHistoryAccessLogs { get; set; } = new List<MedicalHistoryAccessLog>();
        public ICollection<DoctorVerification> Verifications { get; set; } = new List<DoctorVerification>();
        public ICollection<DoctorAchievement> Achievements { get; set; } = new List<DoctorAchievement>();

        public void SetConsultationFee(decimal fee)
        {
            if (fee < 0)
                throw new DomainException("Consultation fee cannot be negative");

            ConsultationFee = fee;
        }
    }
}
