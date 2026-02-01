using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo
{
    public interface IMedicalFileRepository
    {
        /// Get lab test files by history ID
        Task<List<ExternalFile>> GetLabTestsByHistoryIdAsync(int historyId);

        /// Get radiology files by history ID
        Task<List<ExternalFile>> GetRadiologyFilesByHistoryIdAsync(int historyId);
    }
}
