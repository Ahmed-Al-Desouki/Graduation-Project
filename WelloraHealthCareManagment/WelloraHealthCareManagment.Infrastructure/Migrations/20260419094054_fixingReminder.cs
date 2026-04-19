using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class fixingReminder : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_DoctorId",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_PatientId",
                table: "ReminderOccurrencesCache");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_DoctorId",
                table: "ReminderOccurrencesCache",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_PatientId",
                table: "ReminderOccurrencesCache",
                column: "PatientId");
        }
    }
}
