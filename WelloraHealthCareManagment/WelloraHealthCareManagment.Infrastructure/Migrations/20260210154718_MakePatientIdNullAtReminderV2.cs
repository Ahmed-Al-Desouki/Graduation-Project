using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MakePatientIdNullAtReminderV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s");

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "ReminderV2s",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s",
                column: "PatientId",
                principalTable: "Patients",
                principalColumn: "PatientID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s");

            migrationBuilder.AlterColumn<int>(
                name: "PatientId",
                table: "ReminderV2s",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s",
                column: "PatientId",
                principalTable: "Patients",
                principalColumn: "PatientID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
