using HealthCare_.Models.DoctorModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication

{
    public interface IDoctorRepository
    {

        /// Get doctor by doctor ID
        Task<Doctor?> GetByIdAsync(int doctorId);

        /// Get doctor by user ID (same as doctor ID)
        Task<Doctor?> GetByUserIdAsync(int userId);

        /// Create new doctor profile
        Task<Doctor> CreateAsync(Doctor doctor);

        /// Update doctor profile
        Task UpdateAsync(Doctor doctor);

        /// Check if doctor exists by user ID
        Task<bool> DoctorExistsByUserIdAsync(int userId);
    }
}