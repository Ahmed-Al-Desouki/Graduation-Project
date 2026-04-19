using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Responses;

namespace WelloraHealthCareManagment.Application.DTOs.DoctorDtos
{
    public class PublicDoctorProfileResponse
    {
        // ─── بيانات أساسية ───
        public int DoctorId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public int YearsOfExperience { get; set; }
        public decimal ConsultationFee { get; set; }
        public string? Bio { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public bool IsActive { get; set; }

        // ─── موقع العيادة ───
        public string? ClinicAddress { get; set; }
        public double? ClinicLatitude { get; set; }
        public double? ClinicLongitude { get; set; }
        public string? HospitalName { get; set; }

        // ─── Reviews العامة ───
        public List<ReviewResponse> Reviews { get; set; } = new();

        // ─── الإنجازات ───
        public List<AchievementResponse> Achievements { get; set; } = new();
    }
}
