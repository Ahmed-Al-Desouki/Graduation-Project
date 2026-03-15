// Infrastructure/Repositories/PaymentRepository.cs

using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Application.Interfaces.AppRepositories;

namespace WelloraHealthCareManagment.Infrastructure.Repositories
{
    public class PaymentRepository : IPaymentRepository
    {
        private readonly HealthCarePlusContext _context;

        public PaymentRepository(HealthCarePlusContext context)
        {
            _context = context;
        }

        public async Task<Payment?> GetByAppointmentIdAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default)
        {
            _context.ChangeTracker.Clear();

            return await _context.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    p => p.AppointmentId == appointmentId,
                    cancellationToken);
        }

        public async Task<Payment?> GetByPaymobOrderIdAsync(
            string paymobOrderId,
            CancellationToken cancellationToken = default)
        {
            _context.ChangeTracker.Clear();

            return await _context.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(
                    p => p.PaymobOrderId == paymobOrderId,
                    cancellationToken);
        }

        public async Task<Payment?> GetByPaymobOrderIdForUpdateAsync(
            string paymobOrderId,
            CancellationToken cancellationToken = default)
        {
            _context.ChangeTracker.Clear();

            return await _context.Payments
                .FirstOrDefaultAsync(
                    p => p.PaymobOrderId == paymobOrderId,
                    cancellationToken);
        }

        public async Task<Payment?> GetByIdAsync(
            Guid paymentId,
            CancellationToken cancellationToken = default)
        {
            _context.ChangeTracker.Clear();

            return await _context.Payments
                .AsNoTracking()
                .Include(p => p.Appointment)
                .Include(p => p.Doctor)
                    .ThenInclude(d => d.User)
                .Include(p => p.Patient)
                    .ThenInclude(pat => pat.User)
                .FirstOrDefaultAsync(p => p.Id == paymentId, cancellationToken);
        }

        public async Task<List<Payment>> GetPatientPaymentsAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            _context.ChangeTracker.Clear();

            return await _context.Payments
                .AsNoTracking()
                .Include(p => p.Doctor)
                    .ThenInclude(d => d.User)
                .Where(p => p.PatientId == patientId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync(cancellationToken);
        }

        public async Task AddAsync(
            Payment payment,
            CancellationToken cancellationToken = default)
        {
            await _context.Payments.AddAsync(payment, cancellationToken);
        }

        public async Task UpdateAsync(
            Payment payment,
            CancellationToken cancellationToken = default)
        {
            _context.Payments.Update(payment);
            await Task.CompletedTask;
        }

        public async Task DeleteAsync(
            Payment payment,
            CancellationToken cancellationToken = default)
        {
            _context.Payments.Remove(payment);
            await Task.CompletedTask;
        }
    }
}