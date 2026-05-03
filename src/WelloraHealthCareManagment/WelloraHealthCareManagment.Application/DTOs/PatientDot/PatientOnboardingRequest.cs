using System.ComponentModel.DataAnnotations;

namespace WelloraHealthCareManagment.Application.DTOs.PatientDot
{
    public class PatientOnboardingRequest
    {
        [StringLength(100)]
        public string? FullName { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        [StringLength(500)]
        public string? Address { get; set; }

        [Range(-90, 90)]
        public double? CurrentLatitude { get; set; }

        [Range(-180, 180)]
        public double? CurrentLongitude { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [StringLength(50)]
        public string? Gender { get; set; }

        [StringLength(10)]
        public string? BloodType { get; set; }

        [Range(0, 300)]
        public double? Height { get; set; }

        [Range(0, 500)]
        public double? Weight { get; set; }
    }
}
