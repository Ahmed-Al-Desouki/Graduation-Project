// Services/Patient/SelfMedicationService.cs
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;
using HealthCare_.Services.Shared;
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Services.Patient
{
    public class SelfMedicationService : ISelfMedicationService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;
        private readonly ILogger<SelfMedicationService> _logger;

        public SelfMedicationService(
            HealthCarePlusContext context,
            AuthHelperService authHelper,
            ILogger<SelfMedicationService> logger)
        {
            _context = context;
            _authHelper = authHelper;
            _logger = logger;
        }

        public async Task<List<SelfMedicationDto>> GetSelfMedicationsAsync()
        {
            var userId = _authHelper.GetCurrentUserId();

            return await _context.PatientSelfMedications
                .AsNoTracking()
                .Where(m => m.PatientID == userId && !m.IsDeleted)
                .Select(m => new SelfMedicationDto
                {
                    ID = m.ID,
                    MedicationName = m.MedicationName,
                    Dosage = m.Dosage,
                    Instructions = m.Instructions,
                    StartDate = m.StartDate,
                    EndDate = m.EndDate
                }).ToListAsync();
        }

        public async Task<SelfMedicationDto> UpsertSelfMedicationAsync(CreateSelfMedicationRequest request)
        {
            var userId = _authHelper.GetCurrentUserId();

            _logger.LogInformation(
                "Upserting self medication for PatientID: {PatientID}, MedicationID: {MedicationID}",
                userId,
                request.SelfMedicationID
            );

            PatientSelfMedication? selfMed = null;

            if (request.SelfMedicationID.HasValue)
            {
                selfMed = await _context.PatientSelfMedications.FirstOrDefaultAsync(m =>
                    m.ID == request.SelfMedicationID.Value &&
                    m.PatientID == userId);
            }

            if (selfMed != null)
            {
                selfMed.MedicationName = request.MedicationName ?? selfMed.MedicationName;
                selfMed.Dosage = request.Dosage ?? selfMed.Dosage;
                selfMed.Instructions = request.Instructions ?? selfMed.Instructions;
                selfMed.StartDate = request.StartDate ?? selfMed.StartDate;
                selfMed.EndDate = request.EndDate ?? selfMed.EndDate;
                selfMed.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                selfMed = new PatientSelfMedication
                {
                    PatientID = userId,
                    MedicationName = request.MedicationName,
                    Dosage = request.Dosage,
                    Instructions = request.Instructions,
                    StartDate = request.StartDate,
                    EndDate = request.EndDate,
                    CreatedAt = DateTime.UtcNow
                };
                _context.PatientSelfMedications.Add(selfMed);
            }

            await _context.SaveChangesAsync();

            return new SelfMedicationDto
            {
                ID = selfMed.ID,
                MedicationName = selfMed.MedicationName,
                Dosage = selfMed.Dosage,
                Instructions = selfMed.Instructions,
                StartDate = selfMed.StartDate,
                EndDate = selfMed.EndDate
            };
        }

        public async Task SoftDeleteSelfMedicationAsync(int selfMedicationId)
        {
            var userId = _authHelper.GetCurrentUserId();

            _logger.LogInformation(
                "Attempting Soft Delete SelfMedication. ID: {ID}, PatientID: {PatientID}",
                selfMedicationId,
                userId
            );

            var selfMed = await _context.PatientSelfMedications.FirstOrDefaultAsync(m =>
                m.ID == selfMedicationId &&
                m.PatientID == userId &&
                !m.IsDeleted);

            if (selfMed == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Self Medication Not Found. ID: {ID}, PatientID: {PatientID}",
                    selfMedicationId, userId
                );
                throw new KeyNotFoundException("Self medication not found.");
            }

            selfMed.IsDeleted = true;
            selfMed.DeletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Self Medication Soft Deleted Successfully. ID: {ID}, PatientID: {PatientID}",
                selfMedicationId, userId
            );
        }
    }
}