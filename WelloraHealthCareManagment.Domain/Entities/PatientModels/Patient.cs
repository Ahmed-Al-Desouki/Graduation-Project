using HealthCare_.Models.PatientModels.Appointments;
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using HealthCare_.Models.PatientModels.MedIntakeAndRecords;
using HealthCare_.Models.PatientModels.Prescriptions;
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using HealthCare_.Models.V2;
using System.ComponentModel.DataAnnotations;


namespace WelloraHealthCareManagment.Domain.Entities.PatientModels
{
    public class Patient
    {
        [Key]
        [Required]
        public int PatientID { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
        public ApplicationUser User { get; set; } = null!;
        public ICollection<ExternalFile> Files { get; set; } = new List<ExternalFile>();
        public MedicalHistory MedicalHistory { get; set; } = null!;
        public ICollection<Appointment> Appointments { get; set; } = new List<Appointment>();
        public ICollection<Prescription> Prescriptions { get; set; } = new List<Prescription>();
        public ICollection<MedicationsIntake> MedicationsIntakes { get; set; } = new List<MedicationsIntake>();
        public ICollection<ReminderV2> Reminders { get; set; } = new List<ReminderV2>();
        public ICollection<PatientSelfMedication> SelfMedications { get; set; }
    }

}