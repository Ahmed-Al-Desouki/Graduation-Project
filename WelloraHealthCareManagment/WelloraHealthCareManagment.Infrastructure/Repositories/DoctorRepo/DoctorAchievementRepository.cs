using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;
using WelloraHealthCareManagment.Domain.Entities.DoctorModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo
{
    public class DoctorAchievementRepository : IDoctorAchievementRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorAchievementRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<DoctorAchievement> CreateAsync(DoctorAchievement achievement)
        {
            await _context.DoctorAchievements.AddAsync(achievement);
            await _context.SaveChangesAsync();
            return achievement;
        }

        public async Task UpdateAsync(DoctorAchievement achievement)
        {
            _context.DoctorAchievements.Update(achievement);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(DoctorAchievement achievement)
        {
            _context.DoctorAchievements.Remove(achievement);
            await _context.SaveChangesAsync();
        }

        public async Task<DoctorAchievement?> GetByIdAsync(int achievementId)
        {
            return await _context.DoctorAchievements
                .Include(a => a.Image)
                .FirstOrDefaultAsync(a => a.AchievementId == achievementId);
        }

        public async Task<DoctorAchievement?> GetByIdAndDoctorAsync(int achievementId, int doctorId)
        {
            return await _context.DoctorAchievements
                .Include(a => a.Image)
                .FirstOrDefaultAsync(a =>
                    a.AchievementId == achievementId &&
                    a.DoctorId == doctorId);
        }

        public async Task<List<DoctorAchievement>> GetByDoctorIdAsync(int doctorId)
        {
            return await _context.DoctorAchievements
                .Include(a => a.Image)
                .Where(a => a.DoctorId == doctorId)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }
    }
}
