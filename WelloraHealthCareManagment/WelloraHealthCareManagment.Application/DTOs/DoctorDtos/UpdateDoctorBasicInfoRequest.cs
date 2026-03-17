using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class UpdateDoctorBasicInfoRequest
    {
        [StringLength(100)]
        public string? FullName { get; set; }

        [Phone]
        public string? PhoneNumber { get; set; }

        public DateTime? DateOfBirth { get; set; }

        [StringLength(100)]
        public string? Specialization { get; set; }

        [Range(0, 100)]
        public int? YearsOfExperience { get; set; }

        [Range(0, 10000)]
        public decimal? ConsultationFee { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        [StringLength(20)]
        public string? NationalId { get; set; }
    }
}
