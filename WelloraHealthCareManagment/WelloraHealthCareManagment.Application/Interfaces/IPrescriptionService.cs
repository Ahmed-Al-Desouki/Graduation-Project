using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Prescriptions;

namespace WelloraHealthCareManagement.Application.Interfaces
{
    public interface IPrescriptionService
    {
    
        /// Create prescription for appointment (Doctor only)
        Task<PrescriptionResponse> CreatePrescriptionAsync(
            int doctorId,
            CreatePrescriptionRequest request,
            CancellationToken cancellationToken = default);

    
        /// Get prescription by ID
        Task<PrescriptionResponse?> GetPrescriptionAsync(
            Guid prescriptionId,
            CancellationToken cancellationToken = default);

    
        /// Get all prescriptions for appointment
        Task<List<PrescriptionResponse>> GetAppointmentPrescriptionsAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);

    
        /// Get all patient prescriptions
        Task<List<PrescriptionResponse>> GetPatientPrescriptionsAsync(
            int patientId,
            CancellationToken cancellationToken = default);

    
        /// Add item to existing prescription
        Task AddPrescriptionItemAsync(
            Guid prescriptionId,
            int doctorId,
            PrescriptionItemRequest request,
            CancellationToken cancellationToken = default);

        Task AddPrescriptionItemsAsync(
            Guid prescriptionId,
            int doctorId,
            AddPrescriptionItemsRequest request,
            CancellationToken cancellationToken = default);

        Task UpdatePrescriptionItemAsync(
            Guid prescriptionId,
            Guid itemId,
            int doctorId,
            PrescriptionItemRequest request,
            CancellationToken cancellationToken = default);
    }
}