// Services/Patient/CurrentMedicationService.cs
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDTO;
using HealthCare_.Services.Shared;

namespace HealthCare_.Services.Patient
{
    public class CurrentMedicationService : ICurrentMedicationService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;

        public CurrentMedicationService(
            HealthCarePlusContext context,
            AuthHelperService authHelper)
        {
            _context = context;
            _authHelper = authHelper;
        }

        public async Task<List<CurrentMedicationDto>> GetCurrentMedicationsAsync(int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            var userId = _authHelper.GetCurrentUserId();

            var meds = await _context.Prescriptions
                .AsNoTracking()
                .Where(pr => pr.PatientID == userId)
                .SelectMany(pr => pr.Medications)
                .Select(med => new CurrentMedicationDto
                {
                    CurrentMedicationID = med.ID,
                    HistoryID = historyId,
                    MedicationName = med.MedicationName,
                    Dosage = med.Dosage,
                    StartDate = med.StartDate,
                    EndDate = med.EndDate,
                    Notes = med.Instructions
                })
                .ToListAsync();

            return meds;
        }
    }
}