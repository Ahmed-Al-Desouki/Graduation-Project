//// Infrastructure/Repositories/PrescriptionRepository.cs
//using HealthCare_.Models.PatientModels.Prescriptions;
//using Microsoft.EntityFrameworkCore;
//using WelloraHealthCareManagment.Infrastructure.Context;
//using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

//namespace WelloraHealthCareManagment.Infrastructure.Repositories.MeicalHistoryRepo
//{
//    public class PrescriptionRepository : IPrescriptionRepository
//    {
//        private readonly HealthCarePlusContext _context;

//        public PrescriptionRepository(HealthCarePlusContext context)
//        {
//            _context = context;
//        }

//        public async Task<List<PrescriptionMed>> GetMedicationsByPatientIdAsync(int patientId)
//        {
//            return await _context.Prescriptions
//                .AsNoTracking()
//                .Where(pr => pr.PatientID == patientId)
//                .SelectMany(pr => pr.Medications)
//                .ToListAsync();
//        }

//        public async Task<Prescription> GetPrescriptionWithMedicationsAsync(int prescriptionId)
//        {
//            return await _context.Prescriptions
//                .AsNoTracking()
//                .Include(p => p.Medications)
//                .FirstOrDefaultAsync(p => p.PrescriptionID == prescriptionId);
//        }
//    }
//}
