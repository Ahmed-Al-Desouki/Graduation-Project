using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddAppointmentIdToReminderV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Guid>(
                name: "AppointmentId",
                table: "ReminderV2s",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ReminderV2s_AppointmentId",
                table: "ReminderV2s",
                column: "AppointmentId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Appointments_AppointmentId",
                table: "ReminderV2s",
                column: "AppointmentId",
                principalTable: "Appointments",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Appointments_AppointmentId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_ReminderV2s_AppointmentId",
                table: "ReminderV2s");

            migrationBuilder.AlterColumn<int>(
                name: "AppointmentId",
                table: "ReminderV2s",
                type: "int",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);
        }
    }
}
