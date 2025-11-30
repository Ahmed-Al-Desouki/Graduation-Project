using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class addPrescriptionMedandAppointmentToReminderV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_ReminderV2s_AppointmentId",
                table: "ReminderV2s",
                column: "AppointmentId");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderV2s_PrescriptionMedId",
                table: "ReminderV2s",
                column: "PrescriptionMedId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Appointments_AppointmentId",
                table: "ReminderV2s",
                column: "AppointmentId",
                principalTable: "Appointments",
                principalColumn: "AppointmentID");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_PrescriptionMeds_PrescriptionMedId",
                table: "ReminderV2s",
                column: "PrescriptionMedId",
                principalTable: "PrescriptionMeds",
                principalColumn: "ID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Appointments_AppointmentId",
                table: "ReminderV2s");

            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_PrescriptionMeds_PrescriptionMedId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_ReminderV2s_AppointmentId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_ReminderV2s_PrescriptionMedId",
                table: "ReminderV2s");
        }
    }
}
