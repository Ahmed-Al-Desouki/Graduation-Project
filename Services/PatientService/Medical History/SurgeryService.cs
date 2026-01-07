// Services/Patient/SurgeryService.cs
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDot.MedicalProfile;
using HealthCare_.Services.Shared;

namespace HealthCare_.Services.Patient
{
    public class SurgeryService : ISurgeryService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;
        private readonly ILogger<SurgeryService> _logger;

        public SurgeryService(
            HealthCarePlusContext context,
            AuthHelperService authHelper,
            ILogger<SurgeryService> logger)
        {
            _context = context;
            _authHelper = authHelper;
            _logger = logger;
        }

        public async Task<List<SurgeryDto>> GetSurgeriesAsync(int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            return await _context.Surgeries
                .AsNoTracking()
                .Where(s => s.HistoryID == historyId && !s.IsDeleted)
                .Select(s => new SurgeryDto
                {
                    SurgeryID = s.SurgeryID,
                    Name = s.Name,
                    Date = s.Date,
                    Notes = s.Notes,
                    Complications = s.Complications
                }).ToListAsync();
        }

        public async Task<SurgeryDto> UpsertSurgeryAsync(CreateSurgeryRequest request)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(request.HistoryID);

            _logger.LogInformation("Upserting surgery '{Surgery}' for HistoryID: {HistoryID}", request.Name, request.HistoryID);

            var surgery = request.SurgeryID.HasValue
                ? await _context.Surgeries.FirstOrDefaultAsync(s =>
                    s.SurgeryID == request.SurgeryID.Value &&
                    s.HistoryID == request.HistoryID)
                : null;

            if (surgery != null)
            {
                // UPDATE
                surgery.Name = request.Name ?? surgery.Name;
                surgery.Date = request.Date ?? surgery.Date;
                surgery.Notes = request.Notes ?? surgery.Notes;
                surgery.Complications = request.Complications ?? surgery.Complications;
                surgery.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                surgery = new Surgery
                {
                    HistoryID = request.HistoryID,
                    Name = request.Name,
                    Date = request.Date,
                    Notes = request.Notes,
                    Complications = request.Complications,
                    CreatedAt = DateTime.UtcNow
                };
                _context.Surgeries.Add(surgery);
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Surgery upserted successfully: '{Surgery}' (ID: {ID})", surgery.Name, surgery.SurgeryID);

            return new SurgeryDto
            {
                SurgeryID = surgery.SurgeryID,
                Name = surgery.Name,
                Date = surgery.Date,
                Notes = surgery.Notes,
                Complications = surgery.Complications
            };
        }

        public async Task SoftDeleteSurgeryAsync(int surgeryId, int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete Surgery. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                surgeryId, historyId
            );

            var surgery = await _context.Surgeries.FirstOrDefaultAsync(s =>
                s.SurgeryID == surgeryId &&
                s.HistoryID == historyId &&
                !s.IsDeleted);

            if (surgery == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Surgery Not Found. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                    surgeryId, historyId
                );
                throw new KeyNotFoundException("Surgery not found.");
            }

            surgery.IsDeleted = true;
            surgery.DeletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Surgery Soft Deleted Successfully. SurgeryID: {SurgeryID}, HistoryID: {HistoryID}",
                surgeryId, historyId
            );
        }
        public async Task<List<SurgeryDto>> GetSurgeriesForShareAsync(int patientId)
        {
            // نجلب أولًا HistoryID الخاص بالـ patient
            var historyId = await _context.MedicalHistories
                .Where(mh => mh.PatientID == patientId)
                .Select(mh => mh.HistoryID)
                .FirstOrDefaultAsync();

            if (historyId == 0)
                return new List<SurgeryDto>(); // لو مفيش history

            return await _context.Surgeries
                .AsNoTracking()
                .Where(s => s.HistoryID == historyId && !s.IsDeleted)
                .Select(s => new SurgeryDto
                {
                    SurgeryID = s.SurgeryID,
                    Name = s.Name,
                    Date = s.Date,
                    Notes = s.Notes,
                    Complications = s.Complications
                }).ToListAsync();
        }

    }
}