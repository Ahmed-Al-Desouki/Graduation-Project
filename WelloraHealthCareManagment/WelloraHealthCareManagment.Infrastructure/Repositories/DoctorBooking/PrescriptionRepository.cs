using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class PrescriptionRepository : IPrescriptionRepository
    {
        private readonly HealthCarePlusContext _context;

        public PrescriptionRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Prescription?> GetByIdAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Prescriptions
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == prescriptionId, cancellationToken);
        }

        public async Task<Prescription?> GetByIdWithItemsAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Prescriptions
                .Include(p => p.Items)
                .FirstOrDefaultAsync(p => p.Id == prescriptionId, cancellationToken);
        }

        public async Task<List<Prescription>> GetByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Prescriptions
                .Include(p => p.Items)
                .Where(p => p.AppointmentId == appointmentId)
                .OrderByDescending(p => p.IssuedAt)
                .AsNoTracking()
                .ToListAsync(cancellationToken);
        }

        public async Task<List<Prescription>> GetByPatientIdAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Prescriptions
                .Include(p => p.Items)
                .Include(p => p.Appointment)
                    .ThenInclude(a => a.Doctor)
                        .ThenInclude(d => d.User)
                .Where(p => p.PatientId == patientId)
                .OrderByDescending(p => p.IssuedAt)
                .AsNoTracking() 
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            Prescription prescription,
            CancellationToken cancellationToken = default)
        {
            await _context.Prescriptions.AddAsync(prescription, cancellationToken);
            // No SaveChanges here - handled by UnitOfWork
        }

        public async Task UpdateAsync(
            Prescription prescription,
            CancellationToken cancellationToken = default)
        {
            _context.Prescriptions.Update(prescription);
            // No SaveChanges here - handled by UnitOfWork
            await Task.CompletedTask;
        }
    }
}