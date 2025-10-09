using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HealthCare_.Models.Doctor
{
    public class SessionType
    {
        [Key]
        [Required]
        public int SessionTypeID { get; set; }
        [Required]
        public int DoctorID { get; set; }
        [ForeignKey("DoctorID")]
        public Doctor Doctor { get; set; }
        [Required, StringLength(100)]
        public string Name { get; set; }
        [Range(1, 120)]
        public int Duration { get; set; }
        [Range(0, 10000)]
        public decimal Price { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

    }
}
