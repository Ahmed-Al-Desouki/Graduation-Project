using System.ComponentModel.DataAnnotations;

namespace HealthCare_.Models
{
    public class User
    {
        [Key]
        [Required]
        public int UserID { get; set; }
        [Required, StringLength(50)]
        public string FName { get; set; }
        [Required, StringLength(50)]
        public string LName { get; set; }
        [Required, EmailAddress, StringLength(100)]
        public string Email { get; set; }
        [Required, StringLength(256)] // Hashed
        public string PasswordHash { get; set; } // Encrypt via BCrypt in service
        [Required]
        public string Role { get; set; } // "Patient" or "Doctor"
        [Phone, StringLength(20)]
        public string Phone { get; set; }
        [StringLength(200)]
        public string Address { get; set; }
        [StringLength(500)] // URL
        public string ProfileImagePath { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }

        public Doctor Doctor { get; set; }
        public Patient Patient { get; set; }
        public ICollection<Review> Reviews { get; set; }

    }
}
