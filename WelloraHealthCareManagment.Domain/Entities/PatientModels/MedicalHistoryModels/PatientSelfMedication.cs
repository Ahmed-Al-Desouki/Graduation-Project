using System.ComponentModel.DataAnnotations.Schema;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace HealthCare_.Models.PatientModels.MedicalHistoryModels
{
    public class PatientSelfMedication
    {
        public int ID { get; set; }

        public int PatientID { get; set; }
        public Patient Patient { get; set; } = null!;

        [ForeignKey(nameof(HistoryID))]
        public int HistoryID { get; set; }
        public MedicalHistory MedicalHistory { get; set; } = null!;

        public string MedicationName { get; set; } = string.Empty;
        public string? Dosage { get; set; }
        public string? Instructions { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }
    }


}
