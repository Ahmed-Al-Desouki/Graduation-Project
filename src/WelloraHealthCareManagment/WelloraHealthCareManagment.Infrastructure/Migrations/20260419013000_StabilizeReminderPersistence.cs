using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    public partial class StabilizeReminderPersistence : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
;WITH CachePatientDuplicates AS
(
    SELECT
        Id,
        ROW_NUMBER() OVER
        (
            PARTITION BY ReminderId, PatientId, DueDateTimeUtc
            ORDER BY Id
        ) AS RowNum
    FROM ReminderOccurrencesCache
    WHERE PatientId IS NOT NULL AND DoctorId IS NULL
),
CacheDoctorDuplicates AS
(
    SELECT
        Id,
        ROW_NUMBER() OVER
        (
            PARTITION BY ReminderId, DoctorId, DueDateTimeUtc
            ORDER BY Id
        ) AS RowNum
    FROM ReminderOccurrencesCache
    WHERE DoctorId IS NOT NULL AND PatientId IS NULL
)
DELETE FROM ReminderOccurrencesCache
WHERE Id IN
(
    SELECT Id FROM CachePatientDuplicates WHERE RowNum > 1
    UNION ALL
    SELECT Id FROM CacheDoctorDuplicates WHERE RowNum > 1
);

;WITH LogDuplicates AS
(
    SELECT
        Id,
        ROW_NUMBER() OVER
        (
            PARTITION BY ReminderId, PatientId, DueDateTimeUtc
            ORDER BY Id
        ) AS RowNum
    FROM ReminderOccurrenceLogs
)
DELETE FROM ReminderOccurrenceLogs
WHERE Id IN
(
    SELECT Id FROM LogDuplicates WHERE RowNum > 1
);");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_Patient_DueUtc",
                table: "ReminderOccurrencesCache",
                columns: new[] { "PatientId", "DueDateTimeUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_Doctor_DueUtc",
                table: "ReminderOccurrencesCache",
                columns: new[] { "DoctorId", "DueDateTimeUtc" });

            migrationBuilder.CreateIndex(
                name: "UX_ReminderOccurrencesCache_Patient_Reminder_DueUtc",
                table: "ReminderOccurrencesCache",
                columns: new[] { "PatientId", "ReminderId", "DueDateTimeUtc" },
                unique: true,
                filter: "[PatientId] IS NOT NULL AND [DoctorId] IS NULL");

            migrationBuilder.CreateIndex(
                name: "UX_ReminderOccurrencesCache_Doctor_Reminder_DueUtc",
                table: "ReminderOccurrencesCache",
                columns: new[] { "DoctorId", "ReminderId", "DueDateTimeUtc" },
                unique: true,
                filter: "[DoctorId] IS NOT NULL AND [PatientId] IS NULL");

            migrationBuilder.CreateIndex(
                name: "UX_ReminderOccurrenceLogs_Reminder_Patient_DueUtc",
                table: "ReminderOccurrenceLogs",
                columns: new[] { "PatientId", "ReminderId", "DueDateTimeUtc" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_Patient_DueUtc",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_Doctor_DueUtc",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "UX_ReminderOccurrencesCache_Patient_Reminder_DueUtc",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "UX_ReminderOccurrencesCache_Doctor_Reminder_DueUtc",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "UX_ReminderOccurrenceLogs_Reminder_Patient_DueUtc",
                table: "ReminderOccurrenceLogs");
        }
    }
}
