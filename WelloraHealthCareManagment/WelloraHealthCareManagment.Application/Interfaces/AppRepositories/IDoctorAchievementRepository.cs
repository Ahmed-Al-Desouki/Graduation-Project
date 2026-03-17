using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IDoctorAchievementRepository
    {
        Task<DoctorAchievement> CreateAsync(DoctorAchievement achievement);
        Task UpdateAsync(DoctorAchievement achievement);
        Task DeleteAsync(DoctorAchievement achievement);
        Task<DoctorAchievement?> GetByIdAsync(int achievementId);
        Task<DoctorAchievement?> GetByIdAndDoctorAsync(int achievementId, int doctorId);
        Task<List<DoctorAchievement>> GetByDoctorIdAsync(int doctorId);
    }
}
