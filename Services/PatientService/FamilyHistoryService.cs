// Services/Patient/FamilyHistoryService.cs
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Services.Shared;

namespace HealthCare_.Services.Patient
{
    public class FamilyHistoryService : IFamilyHistoryService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;
        private readonly ILogger<FamilyHistoryService> _logger;

        public FamilyHistoryService(
            HealthCarePlusContext context,
            AuthHelperService authHelper,
            ILogger<FamilyHistoryService> logger)
        {
            _context = context;
            _authHelper = authHelper;
            _logger = logger;
        }

        public async Task<List<FamilyHistoryDto>> GetFamilyHistoryAsync(int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            return await _context.FamilyHistoryEntries
                .AsNoTracking()
                .Where(f => f.HistoryID == historyId && !f.IsDeleted)
                .Select(f => new FamilyHistoryDto
                {
                    FamilyHistoryID = f.FamilyHistoryID,
                    Condition = f.Condition,
                    Relative = f.Relative,
                    OnsetAge = f.OnsetAge,
                    Notes = f.Notes,
                    IsVerified = f.IsVerified
                }).ToListAsync();
        }

        public async Task<FamilyHistoryDto> UpsertFamilyHistoryAsync(CreateFamilyHistoryRequest request)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(request.HistoryID);

            _logger.LogInformation(
                "Upserting family history for HistoryID: {HistoryID}, FamilyHistoryID: {FamilyHistoryID}",
                request.HistoryID,
                request.FamilyHistoryID
            );

            FamilyHistoryEntry? record = null;

            if (request.FamilyHistoryID.HasValue)
            {
                record = await _context.FamilyHistoryEntries.FirstOrDefaultAsync(f =>
                    f.FamilyHistoryID == request.FamilyHistoryID.Value &&
                    f.HistoryID == request.HistoryID);
            }

            if (record != null)
            {
                record.Condition = request.Condition ?? record.Condition;
                record.Relative = request.Relative ?? record.Relative;
                record.OnsetAge = request.OnsetAge ?? record.OnsetAge;
                record.Notes = request.Notes ?? record.Notes;
                record.IsVerified = request.IsVerified;
                record.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                record = new FamilyHistoryEntry
                {
                    HistoryID = request.HistoryID,
                    Condition = request.Condition,
                    Relative = request.Relative,
                    OnsetAge = request.OnsetAge,
                    Notes = request.Notes,
                    IsVerified = request.IsVerified,
                    CreatedAt = DateTime.UtcNow
                };
                _context.FamilyHistoryEntries.Add(record);
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Family history upserted successfully (ID: {ID})",
                record.FamilyHistoryID
            );

            return new FamilyHistoryDto
            {
                FamilyHistoryID = record.FamilyHistoryID,
                Condition = record.Condition,
                Relative = record.Relative,
                OnsetAge = record.OnsetAge,
                Notes = record.Notes,
                IsVerified = record.IsVerified
            };
        }

        public async Task SoftDeleteFamilyHistoryAsync(int familyHistoryId, int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete FamilyHistory. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                familyHistoryId, historyId
            );

            var record = await _context.FamilyHistoryEntries.FirstOrDefaultAsync(f =>
                f.FamilyHistoryID == familyHistoryId &&
                f.HistoryID == historyId &&
                !f.IsDeleted);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Family History Not Found. FamilyHistoryID: {FamilyHistoryID, HistoryID: {HistoryID}",
                    familyHistoryId, historyId
                );
                throw new KeyNotFoundException("Family history not found.");
            }

            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Family History Soft Deleted Successfully. FamilyHistoryID: {FamilyHistoryID}, HistoryID: {HistoryID}",
                familyHistoryId, historyId
            );
        }
    }
}