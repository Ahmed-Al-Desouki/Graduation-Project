using System;
using System.Threading;
using System.Threading.Tasks;
using WelloraHealthCareManagement.Domain.Entities;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IPrescriptionReminderService
    {
        /// Creates medication reminders for all items in a prescription.
        /// Reminders are generated based on each item's frequency, duration, and times.
        Task CreatePrescriptionRemindersAsync(
            Prescription prescription,
            CancellationToken cancellationToken = default);

        /// Cancels all active reminders associated with a specific prescription.
        Task CancelPrescriptionRemindersAsync(
            Guid prescriptionId,
            int patientId,
            CancellationToken cancellationToken = default);

        Task CreateReminderForItemAsync(PrescriptionItem item,
            Guid prescriptionId, int patientId, CancellationToken ct = default);
    }
}