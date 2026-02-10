using HealthCare_.Models.PatientModels.MedicalHistoryModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;
using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo

{
    public class MedicalHistoryRepository : IMedicalHistoryRepository
    {
        private readonly HealthCarePlusContext _context;

        public MedicalHistoryRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<MedicalHistory?> GetByPatientIdAsync(int patientId)
        {
            return await _context.MedicalHistories
                .FirstOrDefaultAsync(m => m.PatientID == patientId);
        }

        public async Task<MedicalHistory> CreateAsync(MedicalHistory history)
        {
            await _context.MedicalHistories.AddAsync(history);
            await _context.SaveChangesAsync();
            return history;
        }

        public async Task UpdateAsync(MedicalHistory history)
        {
            _context.MedicalHistories.Update(history);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> ExistsByPatientIdAsync(int patientId)
        {
            return await _context.MedicalHistories
                .AnyAsync(m => m.PatientID == patientId);
        }

        public async Task<int?> GetHistoryIdByPatientIdAsync(int patientId)
        {
            return await _context.MedicalHistories
                .AsNoTracking()
                .Where(mh => mh.PatientID == patientId)
                .Select(mh => (int?)mh.HistoryID)
                .FirstOrDefaultAsync();
        }

        public async Task<Patient?> GetCompletePatientDataAsync(int patientId)
        {
            return await _context.Patients
                .AsNoTracking()
                .Include(p => p.User)
                    .ThenInclude(u => u.ProfileImagePath)
                .Include(p => p.MedicalHistory!)
                    .ThenInclude(mh => mh.Files)
                .Include(p => p.MedicalHistory!)
                    //.ThenInclude(mh => mh.MedicalRecords!)
                        //.ThenInclude(mr => mr.Doctor!)
                            //.ThenInclude(d => d.User)
                //.Include(p => p.Appointments!)
                    //.ThenInclude(a => a.Doctor!)
                        //.ThenInclude(d => d.User)
                //.Include(p => p.Appointments!)
                    //.ThenInclude(a => a.Prescription!)
                        //.ThenInclude(pr => pr.Medications)
                .FirstOrDefaultAsync(p => p.PatientID == patientId);
        }

        public async Task<MedicalHistory?> GetByIdWithDetailsAsync(int historyId)
        {
            return await _context.MedicalHistories
                .FirstOrDefaultAsync(mh => mh.HistoryID == historyId);
        }

        public async Task<MedicalHistory> AddAsync(MedicalHistory history)
        {
            _context.MedicalHistories.Add(history);
            await _context.SaveChangesAsync();
            return history;
        }
    }
}