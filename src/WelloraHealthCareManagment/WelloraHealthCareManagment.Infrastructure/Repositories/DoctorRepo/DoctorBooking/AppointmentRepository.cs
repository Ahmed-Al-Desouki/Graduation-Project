using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagement.Infrastructure.Data;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorRepo.DoctorBooking
{
    public class AppointmentRepository : IAppointmentRepository
    {
        private readonly HealthCarePlusContext _context;

        public AppointmentRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Appointment?> GetByIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .FirstOrDefaultAsync(a => a.Id == appointmentId, cancellationToken);
        }
        public async Task<Appointment?> GetByIdWithDetailsAsync(
          Guid appointmentId,
          CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .Include(a => a.TimeSlot)
                .Include(a => a.Doctor)             
                    .ThenInclude(d => d.User)       
                .Include(a => a.Patient)              
                    .ThenInclude(p => p.User)              
                .Include(a => a.MedicalRecord)
                .Include(a => a.Prescriptions)
                    .ThenInclude(p => p.Items)
                .Include(a => a.AccessGrants)
                .FirstOrDefaultAsync(a => a.Id == appointmentId, cancellationToken);
        }

        public async Task<Appointment?> GetByTimeSlotIdAsync(
            Guid timeSlotId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .FirstOrDefaultAsync(a =>
                    a.TimeSlotId == timeSlotId &&
                    a.Status != AppointmentStatus.Cancelled &&
                    a.Status != AppointmentStatus.NoShow,
                    cancellationToken);
        }

        public async Task<List<Appointment>> GetPatientAppointmentsAsync(
            int patientId,
            AppointmentStatus? status = null,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Appointments
                .AsNoTracking()  // ← أضيف هنا
                .Include(a => a.TimeSlot)
                .Include(a => a.Doctor)
                    .ThenInclude(d => d.User)
                .Include(a => a.Patient)
                    .ThenInclude(p => p.User)
                    .Include(a => a.MedicalRecord)
                .Include(a => a.Prescriptions).ThenInclude(p => p.Items)
                .Where(a => a.PatientId == patientId);

            if (status.HasValue)
                query = query.Where(a => a.Status == status.Value);

            return await query
                .OrderByDescending(a => a.TimeSlot.SlotDate)
                .ThenByDescending(a => a.TimeSlot.StartTime)
                .ToListAsync(cancellationToken);
        }

        public async Task<List<Appointment>> GetDoctorAppointmentsAsync(
             int doctorId,
             DateTime? date = null,
             AppointmentStatus? status = null,
             CancellationToken cancellationToken = default)
        {
            var query = _context.Appointments
                .AsNoTracking()  // ← أضيف هنا
                .Include(a => a.TimeSlot)
                .Include(a => a.Doctor)
                    .ThenInclude(d => d.User)
                .Include(a => a.Patient)
                    .ThenInclude(p => p.User)
                    .Include(a => a.MedicalRecord)
                .Include(a => a.Prescriptions).ThenInclude(p => p.Items)
                .Where(a => a.DoctorId == doctorId);

            if (date.HasValue)
                query = query.Where(a => a.TimeSlot.SlotDate == date.Value.Date);

            if (status.HasValue)
                query = query.Where(a => a.Status == status.Value);

            return await query
                .OrderBy(a => a.TimeSlot.SlotDate)
                .ThenBy(a => a.TimeSlot.StartTime)
                .ToListAsync(cancellationToken);
        }

        public async Task<List<Appointment>> GetUpcomingAppointmentsAsync(
             int doctorId,
             int count = 10,
             CancellationToken cancellationToken = default)
        {
            var now = DateTime.UtcNow;

            return await _context.Appointments
                .AsNoTracking() 
                .Include(a => a.TimeSlot)
                .Include(a => a.Doctor)
                    .ThenInclude(d => d.User)
                .Include(a => a.Patient)
                    .ThenInclude(p => p.User)
                    .Include(a => a.MedicalRecord)
                .Include(a => a.Prescriptions).ThenInclude(p => p.Items)
                .Where(a => a.DoctorId == doctorId
                    && (a.Status == AppointmentStatus.Confirmed
                        || a.Status == AppointmentStatus.Pending)
                    && a.TimeSlot.SlotDate >= now.Date)
                .OrderBy(a => a.TimeSlot.SlotDate)
                .ThenBy(a => a.TimeSlot.StartTime)
                .Take(count)
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            Appointment appointment,
            CancellationToken cancellationToken = default)
        {
            await _context.Appointments.AddAsync(appointment, cancellationToken);
        }

        //public async Task UpdateAsync(
        //    Appointment appointment,
        //    CancellationToken cancellationToken = default)
        //{
        //    _context.Appointments.Update(appointment);
        //    await Task.CompletedTask;
        //}
        public async Task UpdateAsync(
            Appointment appointment,
            CancellationToken cancellationToken = default)
        {
            var entry = _context.Entry(appointment);
            if (entry.State == EntityState.Detached)
                _context.Appointments.Attach(appointment).State = EntityState.Modified;
            await Task.CompletedTask;
        }

        public async Task<List<Appointment>> GetCompletedByPatientIdAsync(
            int patientId,
            CancellationToken ct = default)
        {
            return await _context.Appointments
                .AsNoTracking()
                .Include(a => a.TimeSlot)
                .Include(a => a.Doctor).ThenInclude(d => d.User)
                .Include(a => a.Patient).ThenInclude(d => d.User)
                .Include(a => a.MedicalRecord)
                .Include(a => a.Prescriptions).ThenInclude(p => p.Items)
                .Where(a => a.PatientId == patientId &&
                            a.Status == AppointmentStatus.Completed)
                .OrderByDescending(a => a.TimeSlot.SlotDate)
                .ToListAsync(ct);
        }
        public async Task<Appointment?> GetByIdWithGrantsAsync(Guid appointmentId, CancellationToken ct = default)
        {
            return await _context.Appointments
                .Include(a => a.TimeSlot)
                .Include(a => a.AccessGrants)
                .FirstOrDefaultAsync(a => a.Id == appointmentId, ct);
        }
        public async Task<Appointment?> GetByIdForUpdateAsync(
            Guid id,
            CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
        }
        public async Task<bool> HasCompletedAppointmentAsync(
            int patientId,
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .AsNoTracking()
                .AnyAsync(a =>
                    a.PatientId == patientId &&
                    a.DoctorId == doctorId &&
                    a.Status == AppointmentStatus.Completed,
                    cancellationToken);
        }
        public async Task<int> GetDistinctPatientCountByDoctorAsync(
            int doctorId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Appointments
                .AsNoTracking()
                .Where(a =>
                    a.DoctorId == doctorId &&
                    a.Status != AppointmentStatus.Cancelled &&
                    a.Status != AppointmentStatus.NoShow)
                .Select(a => a.PatientId)
                .Distinct()
                .CountAsync(cancellationToken);
        }
        public async Task<List<Appointment>> GetByTimeSlotIdsAsync(
            List<Guid> slotIds,
            CancellationToken ct = default)
            => await _context.Appointments
                .Where(a => slotIds.Contains(a.TimeSlotId))
                .ToListAsync(ct);
    }
}
