using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Application.Common;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Requests;
using WelloraHealthCareManagment.Application.DTOs.Reviews.Responses;

namespace WelloraHealthCareManagment.Application.Interfaces
{
    public interface IReviewService
    {
        Task<ServiceResult<ReviewResponse>> AddReviewAsync(
            int patientId,
            AddReviewRequest request);

        Task<ServiceResult> UpdateReviewAsync(
            int patientId,
            int reviewId,
            UpdateReviewRequest request);

        Task<ServiceResult> DeleteReviewAsync(
            int patientId,
            int reviewId);

        Task<ServiceResult<List<ReviewResponse>>> GetDoctorReviewsAsync(int doctorId);
    }
}
