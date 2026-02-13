using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.API.Context;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
{
    public class MedicalRecordRepository : IMedicalRecordRepository
    {
        private readonly HealthCarePlusContext _context;

        public MedicalRecordRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<AppointmentMedicalRecord?> GetByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            return await _context.AppointmentMedicalRecords
                .FirstOrDefaultAsync(m => m.AppointmentId == appointmentId, cancellationToken);
        }

        public async Task AddAsync(
            AppointmentMedicalRecord record,
            CancellationToken cancellationToken = default)
        {
            await _context.AppointmentMedicalRecords.AddAsync(record, cancellationToken);
        }

        public async Task UpdateAsync(
            AppointmentMedicalRecord record,
            CancellationToken cancellationToken = default)
        {
            _context.AppointmentMedicalRecords.Update(record);
            await Task.CompletedTask;
        }
    }
}