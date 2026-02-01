// Domain/Repositories/ISurgeryRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface ISurgeryRepository
    {
         
        /// Get all surgeries by history ID (excluding deleted)         
        Task<List<Surgery>> GetByHistoryIdAsync(int historyId);
        
        /// Get surgery by ID      
        Task<Surgery?> GetByIdAsync(int surgeryId, int historyId);
         
        /// Add new surgery        
        Task<Surgery> AddAsync(Surgery surgery);
        
        /// Update existing surgery
        Task UpdateAsync(Surgery surgery);
        
        /// Soft delete surgery
        Task SoftDeleteAsync(Surgery surgery);
    }
}