using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;
using WelloraHealthCareManagment.Domain.Enums;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IDoctorVerificationRepository
    {
        Task<DoctorVerification> CreateAsync(DoctorVerification verification);
        Task UpdateAsync(DoctorVerification verification);
        Task<DoctorVerification?> GetByIdAsync(int verificationId);
        Task<DoctorVerification?> GetByDoctorAndTypeAsync(int doctorId, DoctorDocumentType type);
        Task<List<DoctorVerification>> GetByDoctorIdAsync(int doctorId);
        Task<bool> ExistsAsync(int doctorId, DoctorDocumentType type);
    }
}
