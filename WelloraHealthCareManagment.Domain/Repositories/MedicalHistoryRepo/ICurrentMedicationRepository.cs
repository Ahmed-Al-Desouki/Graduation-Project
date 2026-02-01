using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface ICurrentMedicationRepository
    {

        /// Get patient ID by medical history ID
        Task<int?> GetPatientIdByHistoryIdAsync(int historyId);

        /// Check if medical history belongs to specific patient
        Task<bool> HistoryBelongsToPatientAsync(int historyId, int patientId);

        Task<int?> GetHistoryIdByPatientIdAsync(int patientId);


    }
}
