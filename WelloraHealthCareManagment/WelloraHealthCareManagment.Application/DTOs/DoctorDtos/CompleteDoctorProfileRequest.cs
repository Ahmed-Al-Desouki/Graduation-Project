using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class CompleteDoctorProfileRequest
    {
        [Required, StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required, Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required]
        public DateTime DateOfBirth { get; set; }

        [Required, StringLength(100)]
        public string Specialization { get; set; } = string.Empty;

        [Required, Range(0, 100)]
        public int YearsOfExperience { get; set; }

        [Required, Range(0, 10000)]
        public decimal ConsultationFee { get; set; }

        [Required, StringLength(20)]
        public string NationalId { get; set; } = string.Empty;
    }
}
