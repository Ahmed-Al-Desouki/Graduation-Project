using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class UserSearchDto
    {
        public int UserId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsBlocked { get; set; }
        public bool IsSuspended { get; set; }
        public DateTime CreatedAt { get; set; }

        // Doctor-specific fields (nullable)
        public string? Specialization { get; set; }
        public double? AverageRating { get; set; }
        public int? ReviewCount { get; set; }
        public bool? IsVerified { get; set; }
    }

    public class UserSearchRequest
    {
        public string? SearchTerm { get; set; }
        public string? Role { get; set; } // "Doctor", "Patient", null = all
        public bool? IsBlocked { get; set; }
        public bool? IsSuspended { get; set; }
        public bool? IsVerified { get; set; } // For doctors only
        public string? Specialization { get; set; } // For doctors only
        public double? MinRating { get; set; } // For doctors only
        public DateTime? RegisteredAfter { get; set; }
        public DateTime? RegisteredBefore { get; set; }
        public string? SortBy { get; set; } // "Name", "CreatedAt", "Rating", "ReviewCount"
        public bool Descending { get; set; } = false;
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }

    public class UserSearchResponse
    {
        public List<UserSearchDto> Users { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
        public string SearchType { get; set; } = string.Empty; // "Trie", "Fuzzy", "Database"
        public bool IsSuccess { get; set; } = true;
        public string? ErrorMessage { get; set; }

        public static UserSearchResponse Fail(string error) => new()
        {
            IsSuccess = false,
            ErrorMessage = error
        };
    }
}
