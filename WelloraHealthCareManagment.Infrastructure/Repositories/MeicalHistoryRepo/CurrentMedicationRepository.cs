// Infrastructure/Repositories/MedicalHistoryRepository.cs
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
{
    public class CurrentMedicationRepository : ICurrentMedicationRepository
    {
        private readonly HealthCarePlusContext _context;

        public CurrentMedicationRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<int?> GetPatientIdByHistoryIdAsync(int historyId)
        {
            return await _context.MedicalHistories
                .AsNoTracking()
                .Where(h => h.HistoryID == historyId)
                .Select(h => (int?)h.PatientID)
                .FirstOrDefaultAsync();
        }

        public async Task<bool> HistoryBelongsToPatientAsync(int historyId, int patientId)
        {
            return await _context.MedicalHistories
                .AsNoTracking()
                .AnyAsync(h => h.HistoryID == historyId && h.PatientID == patientId);
        }

        public async Task<int?> GetHistoryIdByPatientIdAsync(int patientId)
        {
            return await _context.MedicalHistories
                .AsNoTracking()
                .Where(mh => mh.PatientID == patientId)
                .Select(mh => (int?)mh.HistoryID)
                .FirstOrDefaultAsync();
        }
    }
}