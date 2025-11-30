// Services/Patient/SocialHistoryService.cs
using HealthCare_.Interfaces.Patient.Medical_History;
using HealthCare_.Models.DTOs.PatientDot;
using HealthCare_.Models.DTOs.PatientDTO;
using HealthCare_.Services.Shared;
using Microsoft.EntityFrameworkCore;

namespace HealthCare_.Services.Patient
{
    public class SocialHistoryService : ISocialHistoryService
    {
        private readonly HealthCarePlusContext _context;
        private readonly AuthHelperService _authHelper;
        private readonly ILogger<SocialHistoryService> _logger;

        public SocialHistoryService(
            HealthCarePlusContext context,
            AuthHelperService authHelper,
            ILogger<SocialHistoryService> logger)
        {
            _context = context;
            _authHelper = authHelper;
            _logger = logger;
        }

        public async Task<List<SocialHistoryDto>> GetSocialHistoryAsync(int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            return await _context.SocialHistories
                .Where(s => s.HistoryID == historyId && !s.IsDeleted)
                .Select(s => new SocialHistoryDto
                {
                    SocialHistoryID = s.SocialHistoryID,
                    SmokingStatus = s.SmokingStatus,
                    SmokingDetails = s.SmokingDetails,
                    AlcoholUse = s.AlcoholUse,
                    DrugUse = s.DrugUse,
                    Occupation = s.Occupation,
                    Exercise = s.Exercise,
                    Notes = s.Notes
                }).ToListAsync();
        }

        public async Task<SocialHistoryDto> UpsertSocialHistoryAsync(UpsertSocialHistoryRequest request)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(request.HistoryID);

            _logger.LogInformation("Upserting social history for HistoryID: {HistoryID}", request.HistoryID);

            var record = await _context.SocialHistories
                .FirstOrDefaultAsync(s => s.HistoryID == request.HistoryID);

            if (record != null)
            {
                record.SmokingStatus = request.SmokingStatus;
                record.SmokingDetails = request.SmokingDetails ?? record.SmokingDetails;
                record.AlcoholUse = request.AlcoholUse;
                record.DrugUse = request.DrugUse ?? record.DrugUse;
                record.Occupation = request.Occupation ?? record.Occupation;
                record.Exercise = request.Exercise ?? record.Exercise;
                record.Notes = request.Notes ?? record.Notes;
                record.UpdatedAt = DateTime.UtcNow;
            }
            else
            {
                record = new SocialHistory
                {
                    HistoryID = request.HistoryID,
                    SmokingStatus = request.SmokingStatus,
                    SmokingDetails = request.SmokingDetails,
                    AlcoholUse = request.AlcoholUse,
                    DrugUse = request.DrugUse,
                    Occupation = request.Occupation,
                    Exercise = request.Exercise,
                    Notes = request.Notes,
                    CreatedAt = DateTime.UtcNow
                };
                _context.SocialHistories.Add(record);
            }

            await _context.SaveChangesAsync();

            _logger.LogInformation("Social history upserted successfully (ID: {ID})", record.SocialHistoryID);

            return new SocialHistoryDto
            {
                SocialHistoryID = record.SocialHistoryID,
                SmokingStatus = record.SmokingStatus,
                SmokingDetails = record.SmokingDetails,
                AlcoholUse = record.AlcoholUse,
                DrugUse = record.DrugUse,
                Occupation = record.Occupation,
                Exercise = record.Exercise,
                Notes = record.Notes
            };
        }

        public async Task SoftDeleteSocialHistoryAsync(int socialHistoryId, int historyId)
        {
            await _authHelper.EnsureHistoryBelongsToCurrentUser(historyId);

            _logger.LogInformation(
                "Attempting Soft Delete SocialHistory. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                socialHistoryId, historyId
            );

            var record = await _context.SocialHistories.FirstOrDefaultAsync(s =>
                s.SocialHistoryID == socialHistoryId &&
                s.HistoryID == historyId &&
                !s.IsDeleted);

            if (record == null)
            {
                _logger.LogWarning(
                    "Soft Delete Failed - Social History Not Found. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                    socialHistoryId, historyId
                );
                throw new KeyNotFoundException("Social history not found.");
            }

            record.IsDeleted = true;
            record.DeletedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            _logger.LogInformation(
                "Social History Soft Deleted Successfully. SocialHistoryID: {SocialHistoryID}, HistoryID: {HistoryID}",
                socialHistoryId, historyId
            );
        }
    }
}