using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDoctorIdToReminderV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DoctorId",
                table: "ReminderV2s",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ReminderV2s_DoctorId",
                table: "ReminderV2s",
                column: "DoctorId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Doctors_DoctorId",
                table: "ReminderV2s",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Doctors_DoctorId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_ReminderV2s_DoctorId",
                table: "ReminderV2s");

            migrationBuilder.DropColumn(
                name: "DoctorId",
                table: "ReminderV2s");
        }
    }
}
