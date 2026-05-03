using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.DTOs.Admin
{
    public class ReviewModerationDto
    {
        public int ReviewID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string? ReviewerProfileImageUrl { get; set; }
        public int TargetID { get; set; }
        public string TargetType { get; set; } = string.Empty;
        public string? DoctorName { get; set; }
        public double Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime ReviewDate { get; set; }
        public bool IsDeleted { get; set; }
        public DateTime? DeletedAt { get; set; }
        public string? DeletedByAdminName { get; set; }
        public string? DeletionReason { get; set; }
    }

    public class DeleteReviewRequest
    {
        public int ReviewId { get; set; }
        public string Reason { get; set; } = string.Empty;
    }

    public class RestoreReviewRequest
    {
        public int ReviewId { get; set; }
    }

    public class ReviewListResponse
    {
        public List<ReviewModerationDto> Reviews { get; set; } = new();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public bool HasNextPage => Page * PageSize < TotalCount;
    }
}
