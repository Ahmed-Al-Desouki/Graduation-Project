using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPerformanceIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_DoctorSlotConfigs_DoctorId",
                table: "DoctorSlotConfigs");

            migrationBuilder.RenameIndex(
                name: "UQ_DoctorException",
                table: "ScheduleExceptions",
                newName: "IX_ScheduleExceptions_DoctorId_ExceptionDate");

            migrationBuilder.CreateIndex(
                name: "IX_TimeSlots_DoctorId_SlotDate",
                table: "TimeSlots",
                columns: new[] { "DoctorId", "SlotDate" });

            migrationBuilder.CreateIndex(
                name: "IX_TimeSlots_DoctorId_SlotDate_Status",
                table: "TimeSlots",
                columns: new[] { "DoctorId", "SlotDate", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_DoctorSlotConfigs_DoctorId_DayOfWeek_Unique",
                table: "DoctorSlotConfigs",
                columns: new[] { "DoctorId", "DayOfWeek" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DoctorSlotConfigs_DoctorId_IsActive",
                table: "DoctorSlotConfigs",
                columns: new[] { "DoctorId", "IsActive" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TimeSlots_DoctorId_SlotDate",
                table: "TimeSlots");

            migrationBuilder.DropIndex(
                name: "IX_TimeSlots_DoctorId_SlotDate_Status",
                table: "TimeSlots");

            migrationBuilder.DropIndex(
                name: "IX_DoctorSlotConfigs_DoctorId_DayOfWeek_Unique",
                table: "DoctorSlotConfigs");

            migrationBuilder.DropIndex(
                name: "IX_DoctorSlotConfigs_DoctorId_IsActive",
                table: "DoctorSlotConfigs");

            migrationBuilder.RenameIndex(
                name: "IX_ScheduleExceptions_DoctorId_ExceptionDate",
                table: "ScheduleExceptions",
                newName: "UQ_DoctorException");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorSlotConfigs_DoctorId",
                table: "DoctorSlotConfigs",
                column: "DoctorId");
        }
    }
}
