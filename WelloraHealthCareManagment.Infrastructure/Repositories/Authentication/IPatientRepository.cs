using HealthCare_.Models.PatientModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication
{
    public interface IPatientRepository
    {

        /// Get patient by patient ID
        Task<Patient?> GetByIdAsync(int patientId);

        /// Get patient by user ID (same as patient ID in your system)
        Task<Patient?> GetByUserIdAsync(int userId);

        /// Create new patient profile
        Task<Patient> CreateAsync(Patient patient);

        /// Update patient profile
        Task UpdateAsync(Patient patient);

        /// Check if patient exists by user ID
        Task<bool> PatientExistsByUserIdAsync(int userId);
    }
}
