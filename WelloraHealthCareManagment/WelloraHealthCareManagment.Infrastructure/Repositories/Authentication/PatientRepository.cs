using HealthCare_.Models.PatientModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Entities.PatientModels;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication
{
    public class PatientRepository : IPatientRepository
    {
        private readonly HealthCarePlusContext _context;

        public PatientRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Patient?> GetByIdAsync(int patientId)
        {
            return await _context.Patients
                .Include(p => p.MedicalHistory) // Include related data if needed
                .FirstOrDefaultAsync(p => p.PatientID == patientId);
        }
        public async Task<Patient?> GetByIdWithUserAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Patients
                .Include(p => p.User)
                .ThenInclude(u => u.ProfileImagePath)
                .Include(p => p.MedicalHistory)
                .FirstOrDefaultAsync(p => p.PatientID == patientId, cancellationToken);
        }

        public async Task<Patient?> GetByUserIdAsync(int userId)
        {
            // PatientID = UserId
            return await _context.Patients
                .Include(p => p.MedicalHistory)
                .FirstOrDefaultAsync(p => p.PatientID == userId);
        }

        public async Task<Patient> CreateAsync(Patient patient)
        {
            await _context.Patients.AddAsync(patient);
            await _context.SaveChangesAsync();
            return patient;
        }

        public async Task UpdateAsync(Patient patient)
        {
            _context.Patients.Update(patient);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> PatientExistsByUserIdAsync(int userId)
        {
            return await _context.Patients.AnyAsync(p => p.PatientID == userId);
        }
    }
}

