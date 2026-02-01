// Domain/Repositories/IFamilyHistoryRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface IFamilyHistoryRepository
    {
         
        /// Get all family history entries by history ID (excluding deleted)
        Task<List<FamilyHistoryEntry>> GetByHistoryIdAsync(int historyId);

        /// Get family history entry by ID  
        Task<FamilyHistoryEntry?> GetByIdAsync(int familyHistoryId, int historyId);
         
        /// Add new family history entry         
        Task<FamilyHistoryEntry> AddAsync(FamilyHistoryEntry entry);
         
        /// Update existing family history entry         
        Task UpdateAsync(FamilyHistoryEntry entry);
        
        /// Soft delete family history entry        
        Task SoftDeleteAsync(FamilyHistoryEntry entry);
    }
}