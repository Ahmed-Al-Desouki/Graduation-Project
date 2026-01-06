namespace HealthCare_.Models.PatientModels.MedicalHistoryModels
{
    public class SocialHistory
    {
        [Key]
        public int SocialHistoryID { get; set; }

        [Required]
        public int HistoryID { get; set; } // FK to MedicalHistory
        [ForeignKey("HistoryID")]
        public MedicalHistory MedicalHistory { get; set; }

        // Structured fields
        [StringLength(20)]
        public string SmokingStatus { get; set; } = "Never"; // Never/Current/Former

        [StringLength(200)]
        public string? SmokingDetails { get; set; } // e.g., "15 cigs/day, 10 years"

        [StringLength(20)]
        public string AlcoholUse { get; set; } = "None"; // None/Social/Daily/Former

        [StringLength(50)]
        public string? DrugUse { get; set; } = "None"; // None/Recreational/IV/Other

        [StringLength(200)]
        public string? Occupation { get; set; }

        [StringLength(200)]
        public string? Exercise { get; set; } // free text or "3 times/week"

        [StringLength(1000)]
        public string? Notes { get; set; } // free notes

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public bool IsDeleted { get; set; } = false;
        public DateTime? DeletedAt { get; set; }

    }
}
