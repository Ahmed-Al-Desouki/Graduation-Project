
using HealthCare_.Models.sharedModels.ApplicationsAndSession;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.sharedModels.Reviews
{
    public class Review
    {
        [Key]
        [Required]
        public int ReviewID { get; set; }
        [Required]
        public int UserID { get; set; }
        [ForeignKey("UserID")]
        public ApplicationUser User { get; set; }
        [Required, StringLength(50)]
        public string TargetType { get; set; }
        [Required]
        public int TargetID { get; set; }
        [Range(0, 5)]
        public double Rating { get; set; }
        [StringLength(1000)]
        public string Comment { get; set; }
        [Required]
        public DateTime ReviewDate { get; set; }
        public bool IsVerified { get; set; }
        //public int? AppointmentID { get; set; }
        //[ForeignKey("AppointmentID")]
        //public Appointment Appointment { get; set; }
        [StringLength(500)]
        public string FilePath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
