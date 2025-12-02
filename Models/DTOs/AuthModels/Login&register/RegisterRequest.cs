namespace HealthCare_.Models.AuthModels
{

    public class RegisterRequest
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(100)]
        public string FullName { get; set; }

        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email format")]
        [StringLength(100)]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required")]
        [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters")]
        public string Password { get; set; }

        public IFormFile? ProfileImageFile { get; set; }

        [Required(ErrorMessage = "Role is required")]
        [RegularExpression("Patient|Doctor", ErrorMessage = "Role must be either 'Patient' or 'Doctor'")]
        public string Role { get; set; }

        public DateTime? UpdatedAt { get; set; }

        public bool TwoFactorEnabled { get; set; } = true;
    }

}
