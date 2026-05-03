using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagment.Application.Interfaces.AppRepositories
{
    public interface IPaymentRepository
    {
        Task<Payment?> GetByIdAsync(Guid paymentId, CancellationToken cancellationToken = default);
        Task<Payment?> GetByAppointmentIdAsync(Guid appointmentId, CancellationToken cancellationToken = default);
        Task<Payment?> GetByPaymobOrderIdAsync(string paymobOrderId, CancellationToken cancellationToken = default);
        Task<List<Payment>> GetPatientPaymentsAsync(int patientId, CancellationToken cancellationToken = default);
        Task AddAsync(Payment payment, CancellationToken cancellationToken = default);
        Task UpdateAsync(Payment payment, CancellationToken cancellationToken = default);
        Task DeleteAsync(Payment payment, CancellationToken cancellationToken = default);
        Task<Payment?> GetByPaymobOrderIdForUpdateAsync(string paymobOrderId, CancellationToken cancellationToken = default);
        Task<List<Payment>> GetRefundedPaymentsAsync(
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken cancellationToken = default);

        //Task<List<Payment>> GetPendingRefundsAsync(
        //    CancellationToken cancellationToken = default);

        Task<decimal> GetTotalRefundedAmountAsync(
            int? patientId = null,
            int? doctorId = null,
            DateTime? fromDate = null,
            DateTime? toDate = null,
            CancellationToken cancellationToken = default);

        Task<decimal> GetDoctorRevenueForPeriodAsync(
            int doctorId,
            DateTime fromDate,
            DateTime toDate,
            CancellationToken cancellationToken = default);

    }
}
