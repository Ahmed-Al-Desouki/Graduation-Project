using WelloraHealthCareManagment.Application.DTOs;
using WelloraHealthCareManagment.Application.DTOs.DoctorDtos.DoctorBooking.Appointments;

namespace WelloraHealthCareManagement.Application.Interfaces
{

    /// Service for managing appointment medical records

    public interface IMedicalRecordService
    {
    
        /// Create medical record for an appointment (Doctor only)
        Task<Guid> CreateMedicalRecordAsync(
            Guid appointmentId,
            int doctorId,
            CreateMedicalRecordRequest request,
            CancellationToken cancellationToken = default);

    
        /// Update existing medical record (Doctor only)
        Task UpdateMedicalRecordAsync(
            Guid appointmentId,
            int doctorId,
            UpdateMedicalRecordRequest request,
            CancellationToken cancellationToken = default);

    
        /// Get medical record for appointment
        Task<AppointmentMedicalRecordDto?> GetMedicalRecordAsync(
            Guid appointmentId,
            CancellationToken cancellationToken = default);
    }


}