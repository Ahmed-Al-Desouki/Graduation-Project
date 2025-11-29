namespace HealthCare_.Models.PatientModels
{
    public class FamilyHistoryEntry
    {
        [Key]
        public int FamilyHistoryID { get; set; }

        [Required]
        public int HistoryID { get; set; } // FK to MedicalHistory
        [ForeignKey("HistoryID")]
        public MedicalHistory MedicalHistory { get; set; }

        [Required, StringLength(200)]
        public string Condition { get; set; } = string.Empty; // Disease name (can be from list or custom)

        [Required, StringLength(50)]
        public string Relative { get; set; } = "Other"; // Father, Mother, Sibling, Grandparent, Other

        public int? OnsetAge { get; set; } // optional

        [StringLength(1000)]
        public string? Notes { get; set; }

        public bool IsVerified { get; set; } = false; // whether patient is sure

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }

    }
}
