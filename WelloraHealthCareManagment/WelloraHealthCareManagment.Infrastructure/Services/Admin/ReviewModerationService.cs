// Infrastructure/Services/ReviewModerationService.cs

using AutoMapper;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Admin;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;

namespace WelloraHealthCareManagement.Infrastructure.Services.Admin;

public class ReviewModerationService : IReviewModerationService
{
    private readonly IReviewRepository _reviewRepository;
    private readonly IDoctorRepository _doctorRepository;
    private readonly INotificationService _notificationService;
    private readonly IAdminAuditService _auditService;
    private readonly IMapper _mapper;
    private readonly ILogger<ReviewModerationService> _logger;

    public ReviewModerationService(
        IReviewRepository reviewRepository,
        IDoctorRepository doctorRepository,
        INotificationService notificationService,
        IAdminAuditService auditService,
        IMapper mapper,
        ILogger<ReviewModerationService> logger)
    {
        _reviewRepository = reviewRepository;
        _doctorRepository = doctorRepository;
        _notificationService = notificationService;
        _auditService = auditService;
        _mapper = mapper;
        _logger = logger;
    }

    public async Task<ServiceResult<ReviewListResponse>> GetAllReviewsAsync(
        int? doctorId = null,
        int? userId = null,
        double? minRating = null,
        double? maxRating = null,
        DateTime? fromDate = null,
        DateTime? toDate = null,
        int page = 1,
        int pageSize = 10,
        CancellationToken ct = default)
    {
        try
        {
            var totalCount = await _reviewRepository.CountAllReviewsFilteredAsync(
                doctorId, userId, minRating, maxRating, fromDate, toDate, ct);

            var reviews = await _reviewRepository.GetAllReviewsFilteredAsync(
                doctorId, userId, minRating, maxRating, fromDate, toDate, page, pageSize, ct);

            // جلب أسماء الأطباء للـ reviews الخاصة بالدكاترة
            var doctorIds = reviews
                .Where(r => r.TargetType == "Doctor")
                .Select(r => r.TargetID)
                .Distinct()
                .ToList();

            var doctorNames = await _reviewRepository.GetDoctorNamesByIdsAsync(doctorIds, ct);

            var dtos = reviews.Select(r =>
            {
                var dto = _mapper.Map<ReviewModerationDto>(r);
                if (r.TargetType == "Doctor" && doctorNames.TryGetValue(r.TargetID, out var doctorName))
                {
                    dto.DoctorName = doctorName;
                }
                return dto;
            }).ToList();

            var response = new ReviewListResponse
            {
                Reviews = dtos,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };

            return ServiceResult<ReviewListResponse>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting all reviews");
            return ServiceResult<ReviewListResponse>.Failure("Failed to get reviews");
        }
    }

    public async Task<ServiceResult<ReviewListResponse>> GetDeletedReviewsAsync(
        int page = 1,
        int pageSize = 10,
        CancellationToken ct = default)
    {
        try
        {
            var reviews = await _reviewRepository.GetDeletedReviewsAsync(page, pageSize, ct);
            var totalCount = await _reviewRepository.CountDeletedReviewsAsync(ct);

            var doctorIds = reviews
                .Where(r => r.TargetType == "Doctor")
                .Select(r => r.TargetID)
                .Distinct()
                .ToList();

            var doctorNames = await _reviewRepository.GetDoctorNamesByIdsAsync(doctorIds, ct);

            var dtos = reviews.Select(r =>
            {
                var dto = _mapper.Map<ReviewModerationDto>(r);
                if (r.TargetType == "Doctor" && doctorNames.TryGetValue(r.TargetID, out var doctorName))
                {
                    dto.DoctorName = doctorName;
                }
                dto.DeletedByAdminName = r.DeletedByAdmin?.FullName;
                return dto;
            }).ToList();

            var response = new ReviewListResponse
            {
                Reviews = dtos,
                TotalCount = totalCount,
                Page = page,
                PageSize = pageSize
            };

            return ServiceResult<ReviewListResponse>.Success(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting deleted reviews");
            return ServiceResult<ReviewListResponse>.Failure("Failed to get deleted reviews");
        }
    }

    public async Task<ServiceResult> DeleteReviewAsync(
        DeleteReviewRequest request,
        int adminId,
        string? ipAddress = null,
        CancellationToken ct = default)
    {
        try
        {
            var review = await _reviewRepository.GetByIdAsync(request.ReviewId);
            if (review == null)
                return ServiceResult.Failure("Review not found");

            if (review.IsDeleted)
                return ServiceResult.Failure("Review is already deleted");

            // جلب اسم الدكتور للإشعار
            string? doctorName = null;
            if (review.TargetType == "Doctor")
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(review.TargetID, ct);
                doctorName = doctor?.User?.FullName;
            }

            // Soft Delete
            await _reviewRepository.SoftDeleteAsync(review, adminId, request.Reason, ct);

            // إعادة حساب متوسط التقييم
            if (review.TargetType == "Doctor")
            {
                await RecalculateDoctorRatingAsync(review.TargetID, ct);
            }

            // إرسال إشعار لصاحب التقييم
            if (!string.IsNullOrEmpty(doctorName))
            {
                await _notificationService.SendReviewDeletedNotificationAsync(
                    review.UserID, doctorName, request.Reason, ct);
            }

            // Audit Log
            await _auditService.LogActionAsync(
                adminId,
                AdminActionType.DeleteReview,
                "Review",
                request.ReviewId.ToString(),
                new
                {
                    Reason = request.Reason,
                    DoctorId = review.TargetID,
                    UserId = review.UserID
                },
                ipAddress,
                ct: ct);

            _logger.LogInformation("Admin {AdminId} deleted review {ReviewId}. Reason: {Reason}",
                adminId, request.ReviewId, request.Reason);

            return ServiceResult.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting review {ReviewId}", request.ReviewId);
            return ServiceResult.Failure("Failed to delete review");
        }
    }

    public async Task<ServiceResult> RestoreReviewAsync(
        RestoreReviewRequest request,
        int adminId,
        string? ipAddress = null,
        CancellationToken ct = default)
    {
        try
        {
            var review = await _reviewRepository.GetByIdAsync(request.ReviewId);
            if (review == null)
                return ServiceResult.Failure("Review not found");

            if (!review.IsDeleted)
                return ServiceResult.Failure("Review is not deleted");

            if (review.TargetType == "Doctor")
            {
                var existingActiveReview = await _reviewRepository
                    .GetActiveByPatientAndDoctorAsync(review.UserID, review.TargetID);

                if (existingActiveReview != null)
                    return ServiceResult.Failure(
                        "Cannot restore this review because the patient already has an active review for this doctor.");
            }

            await _reviewRepository.RestoreAsync(review, ct);

            if (review.TargetType == "Doctor")
            {
                await RecalculateDoctorRatingAsync(review.TargetID, ct);
            }

            await _auditService.LogActionAsync(
                adminId,
                AdminActionType.RestoreReview,
                "Review",
                request.ReviewId.ToString(),
                new { DoctorId = review.TargetID, UserId = review.UserID },
                ipAddress,
                ct: ct);

            _logger.LogInformation("Admin {AdminId} restored review {ReviewId}", adminId, request.ReviewId);

            return ServiceResult.Success();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error restoring review {ReviewId}", request.ReviewId);
            return ServiceResult.Failure("Failed to restore review");
        }
    }

    public async Task<ServiceResult<ReviewModerationDto>> GetReviewDetailsAsync(
        int reviewId, CancellationToken ct = default)
    {
        try
        {
            var review = await _reviewRepository.GetByIdWithDeletedByAdminAsync(reviewId, ct);
            if (review == null)
                return ServiceResult<ReviewModerationDto>.Failure("Review not found");

            var dto = _mapper.Map<ReviewModerationDto>(review);

            if (review.TargetType == "Doctor")
            {
                var doctor = await _doctorRepository.GetByIdWithUserAsync(review.TargetID, ct);
                dto.DoctorName = doctor?.User?.FullName;
            }

            // هذا السطر مهم جدًا
            dto.DeletedByAdminName = review.DeletedByAdmin?.FullName;

            return ServiceResult<ReviewModerationDto>.Success(dto);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting review details {ReviewId}", reviewId);
            return ServiceResult<ReviewModerationDto>.Failure("Failed to get review details");
        }
    }

    public async Task RecalculateDoctorRatingAsync(int doctorId, CancellationToken ct = default)
    {
        try
        {
            var newAverageRating = await _reviewRepository.GetAverageRatingForDoctorActiveAsync(doctorId, ct);
            var doctor = await _doctorRepository.GetByIdAsync(doctorId);

            if (doctor != null)
            {
                doctor.AverageRating = Math.Round(newAverageRating, 2);
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);

                _logger.LogInformation("Recalculated rating for doctor {DoctorId}: {NewRating}",
                    doctorId, newAverageRating);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error recalculating rating for doctor {DoctorId}", doctorId);
        }
    }
}
