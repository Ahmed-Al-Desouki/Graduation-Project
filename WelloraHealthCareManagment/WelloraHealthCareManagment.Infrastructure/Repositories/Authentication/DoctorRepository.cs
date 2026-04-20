using HealthCare_.Models.DoctorModels;
using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagment.Infrastructure.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.Authentication

{
    public class DoctorRepository : IDoctorRepository
    {
        private readonly HealthCarePlusContext _context;

        public DoctorRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Doctor?> GetByIdAsync(int doctorId)
        {
            return await _context.Doctors.FindAsync(doctorId);
        }
        public async Task<Doctor?> GetByIdWithUserAsync(
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Doctors
                .Include(d => d.User)
                .ThenInclude(u => u.ProfileImagePath)
                .FirstOrDefaultAsync(d => d.DoctorId == doctorId, cancellationToken);
        }

        public async Task<Doctor?> GetByUserIdAsync(int userId)
        {
            //  DoctorID = UserId
            return await _context.Doctors
                .FirstOrDefaultAsync(d => d.DoctorId == userId);
        }

        public async Task<Doctor> CreateAsync(Doctor doctor)
        {
            await _context.Doctors.AddAsync(doctor);
            await _context.SaveChangesAsync();
            return doctor;
        }

        public async Task UpdateAsync(Doctor doctor)
        {
            _context.Doctors.Update(doctor);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> DoctorExistsByUserIdAsync(int userId)
        {
            return await _context.Doctors.AnyAsync(d => d.DoctorId == userId);
        }
    }
}
