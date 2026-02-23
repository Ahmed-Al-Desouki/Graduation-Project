using HealthCare_.Models.V2;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Data;
using WelloraHealthCareManagement.Infrastructure.Services;
using WelloraHealthCareManagment.API.Context;
using WelloraHealthCareManagment.Domain.EnumForModels;
using WelloraHealthCareManagment.Domain.Repositories.ReminderRepo;

namespace WelloraHealthCareManagment.Infrastructure.Repositories.ReminderRepo
{
    public class ReminderOccurrencesCacheRepository : IReminderOccurrencesCacheRepository
    {
        private readonly HealthCarePlusContext _context;
        public ILogger<ReminderOccurrencesCacheRepository> _logger { get; }

        public ReminderOccurrencesCacheRepository(HealthCarePlusContext context,
            ILogger<ReminderOccurrencesCacheRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<List<ReminderOccurrencesCache>> GetByPatientAndDateRangeAsync(
            int patientId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            return await _context.ReminderOccurrencesCache
                .AsNoTracking()
                .Where(x => x.PatientId == patientId
                         && x.DueDateTimeUtc >= fromUtcInclusive
                         && x.DueDateTimeUtc < toUtcExclusive)
                .OrderBy(x => x.DueDateTimeUtc)
                .ToListAsync();
        }

        public async Task<ReminderOccurrencesCache?> GetByReminderAndDueDateAsync(
            int reminderId,
            DateTime dueDateTimeUtc)
        {
            return await _context.ReminderOccurrencesCache
                .FirstOrDefaultAsync(x => x.ReminderId == reminderId
                                       && x.DueDateTimeUtc == dueDateTimeUtc);
        }

        public async Task AddRangeAsync(List<ReminderOccurrencesCache> entries)
        {
            _context.ReminderOccurrencesCache.AddRange(entries);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteByDoctorAndDateRangeAsync(int doctorId, DateTime fromUtc, DateTime toUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
          WHERE DoctorId = {0}
            AND DueDateTimeUtc >= {1}
            AND DueDateTimeUtc < {2}",
                doctorId, fromUtc, toUtc);
        }

        public async Task DeleteByPatientAndDateRangeAsync(
            int patientId,
            DateTime fromUtc,
            DateTime toUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                  WHERE PatientId = {0}
                    AND DueDateTimeUtc >= {1}
                    AND DueDateTimeUtc < {2}",
                patientId, fromUtc, toUtc);
        }

        public async Task DeletePastOccurrencesAsync(int patientId, DateTime beforeUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                  WHERE PatientId = {0}
                    AND DueDateTimeUtc < {1}",
                patientId, beforeUtc);
        }

        public async Task UpdateStatusAsync(
            int reminderId,
            DateTime dueDateTimeUtc,
            Enums.OccurrenceStatus status)
        {
            await _context.Database.ExecuteSqlInterpolatedAsync($@"
                UPDATE ReminderOccurrencesCache 
                SET Status = {(byte)status}, 
                    UpdatedAt = GETUTCDATE()
                WHERE ReminderId = {reminderId} 
                  AND DueDateTimeUtc = {dueDateTimeUtc}");
        }

        public async Task BulkInsertAsync(List<ReminderOccurrencesCache> entries)
        {
            var dataTable = new DataTable();
            dataTable.Columns.Add("CreatedAt", typeof(DateTime));
            dataTable.Columns.Add("PatientId", typeof(int));
            dataTable.Columns.Add("DoctorId", typeof(int));
            dataTable.Columns.Add("ReminderId", typeof(int));
            dataTable.Columns.Add("DueDateTimeUtc", typeof(DateTime));
            dataTable.Columns.Add("DueDateTime", typeof(DateTime));
            dataTable.Columns.Add("TimeZoneId", typeof(string));
            dataTable.Columns.Add("Title", typeof(string));
            dataTable.Columns.Add("Message", typeof(string));
            dataTable.Columns.Add("Type", typeof(int));
            dataTable.Columns.Add("Dosage", typeof(string));
            dataTable.Columns.Add("Status", typeof(byte));

            foreach (var e in entries)
            {
                dataTable.Rows.Add(
                    e.CreatedAt,
                    e.PatientId,
                    e.DoctorId,
                    e.ReminderId,
                    e.DueDateTimeUtc,
                    e.DueDateTime,
                    e.TimeZoneId ?? "Africa/Cairo",
                    e.Title,
                    e.Message,
                    (int)e.Type,
                    e.Dosage,
                    (byte)e.Status);
            }

            var connection = _context.Database.GetDbConnection();

            if (connection.State != ConnectionState.Open)
                await connection.OpenAsync();

            using var bulkCopy = new SqlBulkCopy((SqlConnection)connection)
            {
                DestinationTableName = "ReminderOccurrencesCache",
                EnableStreaming = true,
                BatchSize = 1000
            };

            bulkCopy.ColumnMappings.Add("CreatedAt", "CreatedAt");
            bulkCopy.ColumnMappings.Add("PatientId", "PatientId");
            bulkCopy.ColumnMappings.Add("DoctorId", "DoctorId");
            bulkCopy.ColumnMappings.Add("ReminderId", "ReminderId");
            bulkCopy.ColumnMappings.Add("DueDateTimeUtc", "DueDateTimeUtc");
            bulkCopy.ColumnMappings.Add("DueDateTime", "DueDateTime");
            bulkCopy.ColumnMappings.Add("TimeZoneId", "TimeZoneId");
            bulkCopy.ColumnMappings.Add("Title", "Title");
            bulkCopy.ColumnMappings.Add("Message", "Message");
            bulkCopy.ColumnMappings.Add("Type", "Type");
            bulkCopy.ColumnMappings.Add("Dosage", "Dosage");
            bulkCopy.ColumnMappings.Add("Status", "Status");

            await bulkCopy.WriteToServerAsync(dataTable);
        }

        public async Task DeleteByReminderIdAsync(int reminderId)
        {
            var toDelete = await _context.ReminderOccurrencesCache
                .Where(c => c.ReminderId == reminderId)
                .ToListAsync();

            if (toDelete.Any())
            {
                _context.ReminderOccurrencesCache.RemoveRange(toDelete);
                await _context.SaveChangesAsync();
                _logger.LogInformation("🗑️ Deleted {Count} old cache entries for ReminderId {ReminderId}", toDelete.Count, reminderId);
            }
        }

        public async Task DeleteByReminderAndDateRangeAsync(int reminderId, DateTime fromUtc, DateTime toUtc)
        {
            var toDelete = await _context.ReminderOccurrencesCache
                .Where(c => c.ReminderId == reminderId &&
                            c.DueDateTimeUtc >= fromUtc &&
                            c.DueDateTimeUtc < toUtc)
                .ToListAsync();

            if (toDelete.Any())
            {
                _context.ReminderOccurrencesCache.RemoveRange(toDelete);
                await _context.SaveChangesAsync();
                _logger.LogInformation(
                    "Deleted {Count} old cache entries for Reminder {ReminderId} in range {From} to {To}",
                    toDelete.Count, reminderId, fromUtc, toUtc);
            }
        }

        public async Task DeletePastOccurrencesExcludingPrescriptionsAsync(int patientId, DateTime beforeUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                    WHERE PatientId = {0}
                    AND DueDateTimeUtc < {1}
                    AND ReminderId NOT IN (
                    SELECT Id FROM ReminderV2s
                    WHERE PrescriptionItemId IS NOT NULL
                )",
                patientId, beforeUtc);
        }
    }
}
