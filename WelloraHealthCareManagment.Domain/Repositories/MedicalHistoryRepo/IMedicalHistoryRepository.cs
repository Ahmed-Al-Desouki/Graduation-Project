using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface IMedicalHistoryRepository
    {
        /// Get medical history by patient ID
        Task<MedicalHistory?> GetByPatientIdAsync(int patientId);

        /// Create new medical history
        Task<MedicalHistory> CreateAsync(MedicalHistory history);

        /// Update medical history
        Task UpdateAsync(MedicalHistory history);

        /// Check if medical history exists for patient
        Task<bool> ExistsByPatientIdAsync(int patientId);

        /// Get history ID by patient ID
        Task<int?> GetHistoryIdByPatientIdAsync(int patientId);

        /// Get complete patient data with all related entities
        Task<Patient?> GetCompletePatientDataAsync(int patientId);
        Task<MedicalHistory?> GetByIdWithDetailsAsync(int historyId);
        Task<MedicalHistory> AddAsync(MedicalHistory history);
    }
}
