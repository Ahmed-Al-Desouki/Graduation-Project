//using HealthCare.Application.Interfaces;
//using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
//using WelloraHealthCareManagment.Domain.Repositories.MedicalHistoryRepo;

//namespace WelloraHealthCareManagment.Application.UseCases.MedicalHistory.Queries.CurrentMedication.GetCurrentMedications
//{
//    public class GetCurrentMedicationsQueryHandler
//    {
//        private readonly IPrescriptionRepository _prescriptionRepository;
//        private readonly ICurrentMedicationRepository _currentMedicationRepository;
//        private readonly ICurrentUserService _currentUserService;

//        public GetCurrentMedicationsQueryHandler(
//            IPrescriptionRepository prescriptionRepository,
//            ICurrentMedicationRepository currentMedicationRepository,
//            ICurrentUserService currentUserService)
//        {
//            _prescriptionRepository = prescriptionRepository;
//            _currentMedicationRepository = currentMedicationRepository;
//            _currentUserService = currentUserService;
//        }

//        public async Task<List<CurrentMedicationDto>> HandleAsync(GetCurrentMedicationsQuery query)
//        {
//            // 1. Get current user
//            var userId = _currentUserService.GetCurrentUserId();

//            // 2. Validate that history belongs to current user
//            var belongsToUser = await _currentMedicationRepository
//                .HistoryBelongsToPatientAsync(query.HistoryId, userId);

//            if (!belongsToUser)
//            {
//                throw new UnauthorizedAccessException(
//                    "The specified medical history does not belong to the current user.");
//            }

//            // 3. Get medications
//            var medications = await _prescriptionRepository
//                .GetMedicationsByPatientIdAsync(userId);

//            // 4. Map to DTOs
//            var result = medications.Select(med => new CurrentMedicationDto
//            {
//                CurrentMedicationID = med.ID,
//                HistoryID = query.HistoryId,
//                MedicationName = med.MedicationName,
//                Dosage = med.Dosage,
//                StartDate = med.StartDate,
//                EndDate = med.EndDate,
//                Notes = med.Instructions
//            }).ToList();

//            return result;
//        }
//    }
//}