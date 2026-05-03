using HealthCare_.Models.V2;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Data;
using WelloraHealthCareManagment.Infrastructure.Context;
using WelloraHealthCareManagment.Domain.Enums;
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

        public async Task<List<ReminderOccurrencesCache>> GetByDoctorAndDateRangeAsync(
            int doctorId,
            DateTime fromUtcInclusive,
            DateTime toUtcExclusive)
        {
            return await _context.ReminderOccurrencesCache
                .AsNoTracking()
                .Where(x => x.DoctorId == doctorId
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
            OccurrenceStatus status)
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
            var distinctEntries = entries
                .GroupBy(e => new
                {
                    e.PatientId,
                    e.DoctorId,
                    e.ReminderId,
                    e.DueDateTimeUtc
                })
                .Select(g => g.OrderByDescending(x => x.CreatedAt).First())
                .ToList();

            if (!distinctEntries.Any())
            {
                return;
            }

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

            foreach (var e in distinctEntries)
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
            var stageTableName = $"#ReminderOccurrencesCacheStage_{Guid.NewGuid():N}";
            var connectionOpenedHere = false;

            try
            {
                if (connection.State != ConnectionState.Open)
                {
                    await connection.OpenAsync();
                    connectionOpenedHere = true;
                }

                await using var transaction = await connection.BeginTransactionAsync();

                await using (var createStageCommand = connection.CreateCommand())
                {
                    createStageCommand.Transaction = transaction;
                    createStageCommand.CommandText = $@"
                    CREATE TABLE {stageTableName}
                    (
                        CreatedAt DATETIME2 NOT NULL,
                        PatientId INT NULL,
                        DoctorId INT NULL,
                        ReminderId INT NOT NULL,
                        DueDateTimeUtc DATETIME2 NOT NULL,
                        DueDateTime DATETIME2 NOT NULL,
                        TimeZoneId NVARCHAR(50) NOT NULL,
                        Title NVARCHAR(200) NOT NULL,
                        Message NVARCHAR(500) NULL,
                        Type INT NOT NULL,
                        Dosage NVARCHAR(100) NULL,
                        Status TINYINT NOT NULL
                    );";
                    await createStageCommand.ExecuteNonQueryAsync();
                }

                using var bulkCopy = new SqlBulkCopy((SqlConnection)connection, SqlBulkCopyOptions.Default, (SqlTransaction)transaction)
                {
                    DestinationTableName = stageTableName,
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

                await using (var mergeCommand = connection.CreateCommand())
                {
                    mergeCommand.Transaction = transaction;
                    mergeCommand.CommandText = $@"
                    INSERT INTO ReminderOccurrencesCache
                    (
                        CreatedAt,
                        PatientId,
                        DoctorId,
                        ReminderId,
                        DueDateTimeUtc,
                        DueDateTime,
                        TimeZoneId,
                        Title,
                        Message,
                        Type,
                        Dosage,
                        Status
                    )
                    SELECT
                        s.CreatedAt,
                        s.PatientId,
                        s.DoctorId,
                        s.ReminderId,
                        s.DueDateTimeUtc,
                        s.DueDateTime,
                        s.TimeZoneId,
                        s.Title,
                        s.Message,
                        s.Type,
                        s.Dosage,
                        s.Status
                    FROM
                    (
                        SELECT DISTINCT
                            CreatedAt,
                            PatientId,
                            DoctorId,
                            ReminderId,
                            DueDateTimeUtc,
                            DueDateTime,
                            TimeZoneId,
                            Title,
                            Message,
                            Type,
                            Dosage,
                            Status
                        FROM {stageTableName}
                    ) s
                    WHERE NOT EXISTS
                    (
                        SELECT 1
                        FROM ReminderOccurrencesCache t WITH (UPDLOCK, HOLDLOCK)
                        WHERE t.ReminderId = s.ReminderId
                          AND t.DueDateTimeUtc = s.DueDateTimeUtc
                          AND ((t.PatientId = s.PatientId) OR (t.PatientId IS NULL AND s.PatientId IS NULL))
                          AND ((t.DoctorId = s.DoctorId) OR (t.DoctorId IS NULL AND s.DoctorId IS NULL))
                    );";

                    await mergeCommand.ExecuteNonQueryAsync();
                }

                await using (var dropStageCommand = connection.CreateCommand())
                {
                    dropStageCommand.Transaction = transaction;
                    dropStageCommand.CommandText = $"DROP TABLE IF EXISTS {stageTableName};";
                    await dropStageCommand.ExecuteNonQueryAsync();
                }

                await transaction.CommitAsync();
            }
            finally
            {
                if (connectionOpenedHere && connection.State == ConnectionState.Open)
                    await connection.CloseAsync();
            }
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
        public async Task DeleteAllPastOccurrencesAsync(DateTime beforeUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                 WHERE DueDateTimeUtc < {0}",
                beforeUtc);

            _logger.LogInformation(
                "Deleted all past cache rows before {BeforeUtc}", beforeUtc);
        }
        public async Task DeleteFutureNonPrescriptionByPatientAsync(
            int patientId,
            DateTime fromUtc,
            DateTime toUtc)
        {
            await _context.Database.ExecuteSqlRawAsync(
                @"DELETE FROM ReminderOccurrencesCache
                  WHERE PatientId = {0}
                    AND DueDateTimeUtc >= {1}
                    AND DueDateTimeUtc < {2}
                    AND ReminderId NOT IN (
                        SELECT Id FROM ReminderV2s
                        WHERE PrescriptionItemId IS NOT NULL
                )",
                patientId, fromUtc, toUtc);

            _logger.LogInformation(
                "Deleted all future non-prescription cache for Patient {PatientId} in range [{From}, {To})",
                patientId, fromUtc, toUtc);
        }
    }
}

