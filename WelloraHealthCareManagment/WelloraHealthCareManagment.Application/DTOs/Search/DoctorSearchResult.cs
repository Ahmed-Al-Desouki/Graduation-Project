using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Search
{
    public class DoctorSearchResult
    {
        public int DoctorId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public decimal ConsultationFee { get; set; }
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public int YearsOfExperience { get; set; }
        public string? Bio { get; set; }
        public string? ProfileImageUrl { get; set; }
        public bool IsActive { get; set; }
        public string? ClinicAddress { get; set; }
        public double? ClinicLatitude { get; set; }
        public double? ClinicLongitude { get; set; }
        public string? HospitalName { get; set; }
        public double? DistanceKm { get; set; }
        public string? ClinicMapUrl { get; set; }
        public string? DirectionsMapUrl { get; set; }
    }

    public class DoctorSearchResponse
    {
        public List<DoctorSearchResult> Doctors { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
        public string SearchType { get; set; } = string.Empty; // "Prefix" or "Fuzzy"
        public bool IsSuccess { get; set; } = true;
        public string? ErrorMessage { get; set; }

        // Factory methods
        public static DoctorSearchResponse Fail(string error) => new()
        {
            IsSuccess = false,
            ErrorMessage = error
        };
    }

    public class NearbyDoctorSearchResponse
    {
        public List<DoctorSearchResult> Doctors { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
        public bool IsSuccess { get; set; } = true;
        public string? ErrorMessage { get; set; }
        public string SearchType { get; set; } = "Nearby";
        public double PatientLatitude { get; set; }
        public double PatientLongitude { get; set; }
        public double? RadiusKm { get; set; }

        public static NearbyDoctorSearchResponse Fail(string error) => new()
        {
            IsSuccess = false,
            ErrorMessage = error
        };
    }
}
