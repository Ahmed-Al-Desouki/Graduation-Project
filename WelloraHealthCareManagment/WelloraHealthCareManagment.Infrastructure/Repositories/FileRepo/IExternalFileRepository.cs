using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.FileRepo
{
    public interface IExternalFileRepository
    {
        Task<ExternalFile> CreateAsync(ExternalFile file);
        Task<ExternalFile?> GetByIdAsync(int fileId);
        Task<List<ExternalFile>> GetByPatientIdAsync(int patientId);
        Task<List<ExternalFile>> GetByDoctorIdAsync(int doctorId);
        Task<ExternalFile> GetDoctorURLProfile(int doctorId);
        Task DeleteAsync(ExternalFile file);
        Task<ExternalFile?> GetPatientFileByIdAsync(int fileId, int patientId);
        Task<ExternalFile?> GetDoctorFileByIdAsync(int fileId, int doctorId);
        Task<List<ExternalFile>> GetPatientFilesByCategoryAsync(int patientId, string categoryType);
        Task<List<ExternalFile>> GetDoctorFilesByCategoryAsync(int doctorId, string categoryType);
        Task<List<ExternalFile>> GetProfileFilesForUserAsync(int userId, string role);
        Task UpdateAsync(ExternalFile file);
    }
}
