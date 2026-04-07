using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class Fix_UQ_Appointment_TimeSlot_FilteredIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UQ_Appointment_TimeSlot",
                table: "Appointments");

            migrationBuilder.CreateIndex(
                name: "UQ_Appointment_TimeSlot",
                table: "Appointments",
                column: "TimeSlotId",
                unique: true,
                filter: "[Status] <> 'Cancelled' AND [Status] <> 'NoShow'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "UQ_Appointment_TimeSlot",
                table: "Appointments");

            migrationBuilder.CreateIndex(
                name: "UQ_Appointment_TimeSlot",
                table: "Appointments",
                column: "TimeSlotId",
                unique: true);
        }
    }
}
