using System.ComponentModel.DataAnnotations;


namespace HealthCare_.Models.AuthModels
{

    public class RegisterRequest
    {
        [Required(ErrorMessage = "First name is required")]
        [StringLength(50)]
        public string FName { get; set; }

        [Required(ErrorMessage = "Last name is required")]
        [StringLength(50)]
        public string LName { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        [StringLength(100)]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters")]
        public string Password { get; set; }

        [Required(ErrorMessage = "Address is required")]
        [MaxLength(500)]
        public string Address { get; set; }

        [Required(ErrorMessage = "Profile image path is required")]
        public string ProfileImagePath { get; set; }

        [Required(ErrorMessage = "Role is required")]
        [RegularExpression("Patient|Doctor", ErrorMessage = "Role must be either 'Patient' or 'Doctor'")]
        public string Role { get; set; }

        // Optional fields
        public DateTime? UpdatedAt { get; set; }

        public bool EmailConfirmed { get; set; } = false;
        public bool LockoutEnabled { get; set; } = false;
        public DateTimeOffset? LockoutEnd { get; set; }
        public bool PhoneNumberConfirmed { get; set; } = false;
        public bool TwoFactorEnabled { get; set; } = false;
    }

}
