// Infrastructure/Repositories/SelfMedicationRepository.cs
using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
{
    public class SelfMedicationRepository : ISelfMedicationRepository
    {
        private readonly HealthCarePlusContext _context;

        public SelfMedicationRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<List<PatientSelfMedication>> GetByPatientAndHistoryIdAsync(
            int patientId,
            int historyId)
        {
            return await _context.PatientSelfMedications
                .AsNoTracking()
                .Where(m => m.PatientID == patientId &&
                           m.HistoryID == historyId &&
                           !m.IsDeleted)
                .ToListAsync();
        }

        public async Task<List<PatientSelfMedication>> GetByPatientIdAsync(int patientId)
        {
            return await _context.PatientSelfMedications
                .AsNoTracking()
                .Where(m => m.PatientID == patientId && !m.IsDeleted)
                .ToListAsync();
        }

        public async Task<PatientSelfMedication?> GetByIdAsync(
            int selfMedicationId,
            int patientId,
            int historyId)
        {
            var query = _context.PatientSelfMedications
                .Where(m => m.ID == selfMedicationId &&
                           m.PatientID == patientId &&
                           !m.IsDeleted);

            // إذا historyId = 0 يعني any history
            if (historyId > 0)
            {
                query = query.Where(m => m.HistoryID == historyId);
            }

            return await query.FirstOrDefaultAsync();
        }

        public async Task<PatientSelfMedication> AddAsync(PatientSelfMedication medication)
        {
            _context.PatientSelfMedications.Add(medication);
            await _context.SaveChangesAsync();
            return medication;
        }

        public async Task UpdateAsync(PatientSelfMedication medication)
        {
            _context.PatientSelfMedications.Update(medication);
            await _context.SaveChangesAsync();
        }

        public async Task SoftDeleteAsync(PatientSelfMedication medication)
        {
            _context.PatientSelfMedications.Update(medication);
            await _context.SaveChangesAsync();
        }
    }
}