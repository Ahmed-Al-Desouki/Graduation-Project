// Infrastructure/Repositories/PaymentRepository.cs

using Microsoft.EntityFrameworkCore;
using WelloraHealthCareManagement.Domain.Entities;
using WelloraHealthCareManagement.Domain.Enums;
using WelloraHealthCareManagment.Infrastructure.Context;
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
            

            return await _context.Payments
                .FirstOrDefaultAsync(
                    p => p.PaymobOrderId == paymobOrderId,
                    cancellationToken);
        }

        //public async Task<Payment?> GetByIdAsync(
        //    Guid paymentId,
        //    CancellationToken cancellationToken = default)
        //{
        //    // مش محتاج Clear ولا Include للـ Appointment هنا
        //    return await _context.Payments
        //        .AsNoTracking()
        //        .Include(p => p.Doctor)
        //            .ThenInclude(d => d.User)
        //        .Include(p => p.Patient)
        //            .ThenInclude(pat => pat.User)
        //        .FirstOrDefaultAsync(p => p.Id == paymentId, cancellationToken);
        //}
        public async Task<Payment?> GetByIdAsync(
            Guid paymentId,
            CancellationToken cancellationToken = default)
        {
            return await _context.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == paymentId, cancellationToken);
        }

        public async Task<List<Payment>> GetPatientPaymentsAsync(
            int patientId,
            CancellationToken cancellationToken = default)
        {
            // نجيب بس الـ fields المحتاجة عبر Select anonymous type
            // بس لأن الـ interface بيرجع List<Payment>، نضيف AsNoTracking بس
            return await _context.Payments
                .AsNoTracking()
                .Include(p => p.Doctor)
                    .ThenInclude(d => d.User)
                .Where(p => p.PatientId == patientId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync(cancellationToken);
        }

        public async Task<List<Payment>> GetRefundedPaymentsAsync(
       DateTime? fromDate = null,
       DateTime? toDate = null,
       CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == PaymentStatus.Refunded);

            if (fromDate.HasValue)
                query = query.Where(p => p.RefundedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(p => p.RefundedAt <= toDate.Value);

            return await query
                .Include(p => p.Patient)
                    .ThenInclude(p => p.User)
                .Include(p => p.Doctor)
                    .ThenInclude(d => d.User)
                .OrderByDescending(p => p.RefundedAt)
                .ToListAsync(cancellationToken);
        }

        public async Task<decimal> GetTotalRefundedAmountAsync(
            int? patientId = null,
            int? doctorId = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken cancellationToken = default)
        {
            var query = _context.Payments
                .Where(p => p.Status == PaymentStatus.Refunded);

            if (patientId.HasValue)
                query = query.Where(p => p.PatientId == patientId.Value);

            if (doctorId.HasValue)
                query = query.Where(p => p.DoctorId == doctorId.Value);

            if (fromDate.HasValue)
                query = query.Where(p => p.RefundedAt >= fromDate.Value);

            if (toDate.HasValue)
                query = query.Where(p => p.RefundedAt <= toDate.Value);

            return await query.SumAsync(p => p.RefundAmount ?? 0, cancellationToken);
        }

        public async Task AddAsync(
            Payment payment,
            CancellationToken cancellationToken = default)
        {
            await _context.Payments.AddAsync(payment, cancellationToken);
        }

        //public async Task UpdateAsync(
        //    Payment payment,
        //    CancellationToken cancellationToken = default)
        //{
        //    _context.Payments.Update(payment);
        //    await Task.CompletedTask;
        //}
        public async Task UpdateAsync(
            Payment payment,
            CancellationToken cancellationToken = default)
        {
            var entry = _context.Entry(payment);
            if (entry.State == EntityState.Detached)
                _context.Payments.Attach(payment).State = EntityState.Modified;
            // لو كان tracked بالفعل، EF هيعرف التغييرات تلقائياً
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
