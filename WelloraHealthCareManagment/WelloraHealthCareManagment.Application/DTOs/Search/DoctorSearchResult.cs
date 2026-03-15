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
        public string? Description { get; set; }
        public string? ProfileImageUrl { get; set; }
        public bool IsActive { get; set; }
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
}
