using HealthCare_.Models.sharedModels.Reviews;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IReviewRepository
    {
        Task<Review> CreateAsync(Review review);
        Task UpdateAsync(Review review);
        Task DeleteAsync(Review review);
        Task<Review?> GetByIdAsync(int reviewId);

        // للتحقق من ownership عند update/delete
        Task<Review?> GetByIdAndPatientAsync(int reviewId, int patientId);

        // لعرض reviews الدكتور في GET /profile
        Task<List<Review>> GetByDoctorIdAsync(int doctorId);

        // لحساب متوسط التقييم
        Task<double> GetAverageRatingForDoctorAsync(int doctorId);

        // لإحصائيات الأدمن
        Task<int> GetReviewCountForDoctorAsync(int doctorId);
    }
}
