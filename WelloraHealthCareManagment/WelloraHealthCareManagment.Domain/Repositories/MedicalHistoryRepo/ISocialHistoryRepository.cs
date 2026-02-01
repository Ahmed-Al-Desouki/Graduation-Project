// Domain/Repositories/ISocialHistoryRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;

namespace WelloraHealthCareManagment.Domain.Repositories
{
    public interface ISocialHistoryRepository
    {
         
        /// Get all social history entries by history ID (excluding deleted)
        Task<List<SocialHistory>> GetByHistoryIdAsync(int historyId);
        
        /// Get social history by history ID (single record, excluding deleted)
        Task<SocialHistory?> GetSingleByHistoryIdAsync(int historyId);
         
        /// Get social history by ID
        Task<SocialHistory?> GetByIdAsync(int socialHistoryId, int historyId);
        
        /// Add new social history
        Task<SocialHistory> AddAsync(SocialHistory socialHistory);
        
        /// Update existing social history 
        Task UpdateAsync(SocialHistory socialHistory);

         
        /// Soft delete social history
        Task SoftDeleteAsync(SocialHistory socialHistory);
    }
}