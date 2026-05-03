// Domain/Repositories/ISelfMedicationRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface ISelfMedicationRepository
    {
        /// Get all self medications by patient ID and history ID (excluding deleted)
        Task<List<PatientSelfMedication>> GetByPatientAndHistoryIdAsync(int patientId, int historyId);
         
        /// Get all self medications by patient ID only (excluding deleted)         
        Task<List<PatientSelfMedication>> GetByPatientIdAsync(int patientId);
         
        /// Get self medication by ID        
        Task<PatientSelfMedication?> GetByIdAsync(int selfMedicationId, int patientId, int historyId);
         
        /// Add new self medication
        Task<PatientSelfMedication> AddAsync(PatientSelfMedication medication);
         
        /// Update existing self medication
        Task UpdateAsync(PatientSelfMedication medication);
         
        /// Soft delete self medication         
        Task SoftDeleteAsync(PatientSelfMedication medication);
    }
}