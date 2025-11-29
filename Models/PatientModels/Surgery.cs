namespace HealthCare_.Models.PatientModels
{
    public class Surgery
    {
        [Key]
        public int SurgeryID { get; set; }

        [Required]
        public int HistoryID { get; set; } // FK to MedicalHistory
        [ForeignKey("HistoryID")]
        public MedicalHistory MedicalHistory { get; set; }

        [Required, StringLength(250)]
        public string Name { get; set; } = string.Empty;

        public DateTime? Date { get; set; } // إذا المريض ما عرفش التاريخ ممكن null

        [StringLength(1000)]
        public string? Notes { get; set; }

        [StringLength(500)]
        public string? Complications { get; set; }

        // Source: who added it (User / Doctor)
        [StringLength(50)]
        public string Source { get; set; } = "User";

        // If added from a doctor's appointment, link it (optional)
        public int? AppointmentID { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }

    }
}
