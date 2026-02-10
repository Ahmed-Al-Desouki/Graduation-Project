using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MakeDoctorIdAtReminderOcurrencecacheV22 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_DoctorId",
                table: "ReminderOccurrencesCache",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderOccurrencesCache_PatientId",
                table: "ReminderOccurrencesCache",
                column: "PatientId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderOccurrencesCache_Doctors_DoctorId",
                table: "ReminderOccurrencesCache",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderOccurrencesCache_Patients_PatientId",
                table: "ReminderOccurrencesCache",
                column: "PatientId",
                principalTable: "Patients",
                principalColumn: "PatientID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderOccurrencesCache_Doctors_DoctorId",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropForeignKey(
                name: "FK_ReminderOccurrencesCache_Patients_PatientId",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_DoctorId",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropIndex(
                name: "IX_ReminderOccurrencesCache_PatientId",
                table: "ReminderOccurrencesCache");
        }
    }
}
