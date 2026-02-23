//using WelloraHealthCareManagement.Domain.Entities;              تم نقله الي application project

//namespace WelloraHealthCareManagment.Infrastructure.Repositories.DoctorBooking
//{
//    public interface IMedicalHistoryAccessRepository
//    {
//        Task<MedicalHistoryAccessGrant?> GetActiveGrantAsync(
//            int patientId,
//            int doctorId,
//            Guid? appointmentId = null,
//            CancellationToken cancellationToken = default);

//        Task<List<MedicalHistoryAccessGrant>> GetPatientGrantsAsync(
//            int patientId,
//            bool activeOnly = true,
//            CancellationToken cancellationToken = default);

//        Task AddAsync(MedicalHistoryAccessGrant grant, CancellationToken cancellationToken = default);
//        Task AddLogAsync(MedicalHistoryAccessLog log, CancellationToken cancellationToken = default);
//    }
//}