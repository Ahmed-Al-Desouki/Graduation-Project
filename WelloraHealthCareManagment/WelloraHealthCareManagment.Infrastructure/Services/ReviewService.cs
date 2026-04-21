using HealthCare_.Models.sharedModels.Reviews;
using Microsoft.Extensions.Logging;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Requests;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Responses;
using WelloraHealthCareManagment.Application.Interfaces;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Application.Interfaces.Services;
using WelloraHealthCareManagment.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Repositories.Authentication;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagment.Infrastructure.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IAppointmentRepository _appointmentRepository;
        private readonly IDoctorRepository _doctorRepository;
        private readonly INotificationService _notificationService;
        private readonly ILogger<ReviewService> _logger;

        public ReviewService(
            IReviewRepository reviewRepository,
            IAppointmentRepository appointmentRepository,
            IDoctorRepository doctorRepository,
            INotificationService notificationService,
            ILogger<ReviewService> logger)
        {
            _reviewRepository = reviewRepository;
            _appointmentRepository = appointmentRepository;
            _doctorRepository = doctorRepository;
            _notificationService = notificationService;
            _logger = logger;
        }


        // ADD REVIEW
        public async Task<ServiceResult<ReviewResponse>> AddReviewAsync(
            int patientId,
            AddReviewRequest request)
        {
            try
            {
                // 1. تحقق إن الدكتور موجود
                var doctor = await _doctorRepository.GetByIdAsync(request.DoctorId);
                if (doctor == null)
                    return ServiceResult<ReviewResponse>.Failure("Doctor not found");

                // 2. تحقق إن المريض عنده completed appointment مع الدكتور
                var hasAppointment = await _appointmentRepository
                    .HasCompletedAppointmentAsync(patientId, request.DoctorId);

                if (!hasAppointment)
                    return ServiceResult<ReviewResponse>.Failure(
                        "You can only review a doctor after completing an appointment with them");

                // 3. إنشاء الـ review
                var review = new Review
                {
                    UserID = patientId,
                    TargetType = "Doctor",
                    TargetID = request.DoctorId,
                    Rating = request.Rating,
                    Comment = request.Comment,
                    ReviewDate = DateTime.UtcNow,
                    IsVerified = true,   
                    CreatedAt = DateTime.UtcNow
                };

                await _reviewRepository.CreateAsync(review);

                // 4. تحديث AverageRating في جدول Doctor
                await UpdateDoctorAverageRatingAsync(request.DoctorId);
                await NotifyDoctorAboutReviewAsync(
                    request.DoctorId,
                    patientId,
                    review.ReviewID,
                    "New Review",
                    $"Patient #{patientId} added a new review to your profile.",
                    NotificationType.ReviewCreated);

                _logger.LogInformation(
                    "AddReviewAsync: Patient {PatientId} reviewed Doctor {DoctorId}",
                    patientId, request.DoctorId);

                return ServiceResult<ReviewResponse>.Success(MapToResponse(review, ""));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "AddReviewAsync failed for patient {PatientId}", patientId);
                return ServiceResult<ReviewResponse>.Failure("Server error while adding review");
            }
        }


        // UPDATE REVIEW
        public async Task<ServiceResult> UpdateReviewAsync(
            int patientId,
            int reviewId,
            UpdateReviewRequest request)
        {
            try
            {
                // تحقق من ownership
                var review = await _reviewRepository.GetByIdAndPatientAsync(reviewId, patientId);
                if (review == null)
                    return ServiceResult.Failure("Review not found or does not belong to you");

                // Partial update — غير بس اللي اتبعت
                if (request.Rating.HasValue)
                    review.Rating = request.Rating.Value;

                if (!string.IsNullOrWhiteSpace(request.Comment))
                    review.Comment = request.Comment;

                review.UpdatedAt = DateTime.UtcNow;
                await _reviewRepository.UpdateAsync(review);

                // تحديث AverageRating
                await UpdateDoctorAverageRatingAsync(review.TargetID);
                await NotifyDoctorAboutReviewAsync(
                    review.TargetID,
                    patientId,
                    review.ReviewID,
                    "Review Updated",
                    $"Patient #{patientId} updated a review on your profile.",
                    NotificationType.ReviewUpdated);

                _logger.LogInformation(
                    "UpdateReviewAsync: Review {ReviewId} updated by patient {PatientId}",
                    reviewId, patientId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "UpdateReviewAsync failed. ReviewId: {ReviewId}", reviewId);
                return ServiceResult.Failure("Server error while updating review");
            }
        }


        // DELETE REVIEW
        public async Task<ServiceResult> DeleteReviewAsync(int patientId, int reviewId)
        {
            try
            {
                var review = await _reviewRepository.GetByIdAndPatientAsync(reviewId, patientId);
                if (review == null)
                    return ServiceResult.Failure("Review not found or does not belong to you");

                int doctorId = review.TargetID;
                await _reviewRepository.DeleteAsync(review);

                // تحديث AverageRating بعد الحذف
                await UpdateDoctorAverageRatingAsync(doctorId);
                await NotifyDoctorAboutReviewAsync(
                    doctorId,
                    patientId,
                    review.ReviewID,
                    "Review Deleted",
                    $"Patient #{patientId} deleted a review from your profile.",
                    NotificationType.ReviewDeletedByPatient);

                _logger.LogInformation(
                    "DeleteReviewAsync: Review {ReviewId} deleted by patient {PatientId}",
                    reviewId, patientId);

                return ServiceResult.Success();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DeleteReviewAsync failed. ReviewId: {ReviewId}", reviewId);
                return ServiceResult.Failure("Server error while deleting review");
            }
        }


        // GET DOCTOR REVIEWS
        public async Task<ServiceResult<List<ReviewResponse>>> GetDoctorReviewsAsync(int doctorId)
        {
            try
            {
                var reviews = await _reviewRepository.GetByDoctorIdAsync(doctorId);

                var result = reviews
                    .Select(r => MapToResponse(r, r.User?.FullName ?? "Patient"))
                    .ToList();

                return ServiceResult<List<ReviewResponse>>.Success(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetDoctorReviewsAsync failed for doctor {DoctorId}", doctorId);
                return ServiceResult<List<ReviewResponse>>.Failure("Server error while fetching reviews");
            }
        }


        // PRIVATE HELPERS
        // يتحسب بعد كل add/update/delete ويُحفظ في Doctor.AverageRating
        private async Task UpdateDoctorAverageRatingAsync(int doctorId)
        {
            try
            {
                var newAverage = await _reviewRepository.GetAverageRatingForDoctorAsync(doctorId);
                var doctor = await _doctorRepository.GetByIdAsync(doctorId);
                if (doctor == null) return;

                doctor.AverageRating = newAverage;
                doctor.UpdatedAt = DateTime.UtcNow;
                await _doctorRepository.UpdateAsync(doctor);
            }
            catch (Exception ex)
            {
                // مش هنوقف العملية لو فشل حساب الـ rating
                _logger.LogWarning(ex,
                    "UpdateDoctorAverageRatingAsync: Failed to update rating for doctor {DoctorId}",
                    doctorId);
            }
        }

        private static ReviewResponse MapToResponse(Review review, string patientName)
        {
            return new ReviewResponse
            {
                ReviewId = review.ReviewID,
                PatientId = review.UserID,
                PatientName = patientName,
                Rating = review.Rating,
                Comment = review.Comment,
                ReviewDate = review.ReviewDate,
                IsVerified = review.IsVerified
            };
        }

        private async Task NotifyDoctorAboutReviewAsync(
            int doctorId,
            int patientId,
            int reviewId,
            string title,
            string message,
            NotificationType type)
        {
            await _notificationService.NotifyAsync(new Application.DTOs.Admin.NotificationDispatchRequest
            {
                UserId = doctorId,
                Title = title,
                Message = message,
                Type = type,
                RelatedEntityType = "Review",
                RelatedEntityId = reviewId,
                Data = new Dictionary<string, string>
                {
                    ["reviewId"] = reviewId.ToString(),
                    ["doctorId"] = doctorId.ToString(),
                    ["patientId"] = patientId.ToString()
                }
            });
        }
    }
}
