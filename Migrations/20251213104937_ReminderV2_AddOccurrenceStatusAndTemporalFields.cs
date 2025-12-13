using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class ReminderV2_AddOccurrenceStatusAndTemporalFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MedicationsIntakes_ReminderInstances_ReminderInstanceID",
                table: "MedicationsIntakes");

            migrationBuilder.DropTable(
                name: "ReminderInstances");

            migrationBuilder.DropTable(
                name: "Reminders");

            migrationBuilder.DropIndex(
                name: "IX_MedicationsIntakes_ReminderInstanceID",
                table: "MedicationsIntakes");

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "ReminderOccurrencesCache",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AlterColumn<byte>(
                name: "Status",
                table: "ReminderOccurrenceLogs",
                type: "tinyint",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<DateTime>(
                name: "ActionedAt",
                table: "ReminderOccurrenceLogs",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "ActionedWithinWindow",
                table: "ReminderOccurrenceLogs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsSnoozeFromOriginal",
                table: "ReminderOccurrenceLogs",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "OriginalDueDateTime",
                table: "ReminderOccurrenceLogs",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PatientId",
                table: "ReminderOccurrenceLogs",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_ReminderV2s_PatientId",
                table: "ReminderV2s",
                column: "PatientId");

            migrationBuilder.CreateIndex(
                name: "IX_MedicationsIntakes_ReminderInstanceID",
                table: "MedicationsIntakes",
                column: "ReminderInstanceID");

            migrationBuilder.AddForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s",
                column: "PatientId",
                principalTable: "Patients",
                principalColumn: "PatientID",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReminderV2s_Patients_PatientId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_ReminderV2s_PatientId",
                table: "ReminderV2s");

            migrationBuilder.DropIndex(
                name: "IX_MedicationsIntakes_ReminderInstanceID",
                table: "MedicationsIntakes");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropColumn(
                name: "ActionedAt",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.DropColumn(
                name: "ActionedWithinWindow",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.DropColumn(
                name: "IsSnoozeFromOriginal",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.DropColumn(
                name: "OriginalDueDateTime",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.DropColumn(
                name: "PatientId",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.AlterColumn<int>(
                name: "Status",
                table: "ReminderOccurrenceLogs",
                type: "int",
                nullable: false,
                oldClrType: typeof(byte),
                oldType: "tinyint");

            migrationBuilder.CreateTable(
                name: "Reminders",
                columns: table => new
                {
                    ReminderID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AppointmentID = table.Column<int>(type: "int", nullable: true),
                    PatientID = table.Column<int>(type: "int", nullable: false),
                    PrescriptionMedID = table.Column<int>(type: "int", nullable: true),
                    BaseTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Frequency = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IntervalHours = table.Column<int>(type: "int", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    IsLocalNotification = table.Column<bool>(type: "bit", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Type = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reminders", x => x.ReminderID);
                    table.ForeignKey(
                        name: "FK_Reminders_Appointments_AppointmentID",
                        column: x => x.AppointmentID,
                        principalTable: "Appointments",
                        principalColumn: "AppointmentID",
                        onDelete: ReferentialAction.SetNull);
                    table.ForeignKey(
                        name: "FK_Reminders_Patients_PatientID",
                        column: x => x.PatientID,
                        principalTable: "Patients",
                        principalColumn: "PatientID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reminders_PrescriptionMeds_PrescriptionMedID",
                        column: x => x.PrescriptionMedID,
                        principalTable: "PrescriptionMeds",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "ReminderInstances",
                columns: table => new
                {
                    InstanceID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ReminderID = table.Column<int>(type: "int", nullable: false),
                    ConfirmedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DueDateTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IntakeID = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReminderInstances", x => x.InstanceID);
                    table.ForeignKey(
                        name: "FK_ReminderInstances_Reminders_ReminderID",
                        column: x => x.ReminderID,
                        principalTable: "Reminders",
                        principalColumn: "ReminderID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_MedicationsIntakes_ReminderInstanceID",
                table: "MedicationsIntakes",
                column: "ReminderInstanceID",
                unique: true,
                filter: "[ReminderInstanceID] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderInstances_DueDateTime",
                table: "ReminderInstances",
                column: "DueDateTime");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderInstances_ReminderID",
                table: "ReminderInstances",
                column: "ReminderID");

            migrationBuilder.CreateIndex(
                name: "IX_ReminderInstances_Status",
                table: "ReminderInstances",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_Reminders_AppointmentID",
                table: "Reminders",
                column: "AppointmentID");

            migrationBuilder.CreateIndex(
                name: "IX_Reminders_PatientID",
                table: "Reminders",
                column: "PatientID");

            migrationBuilder.CreateIndex(
                name: "IX_Reminders_PrescriptionMedID_AppointmentID",
                table: "Reminders",
                columns: new[] { "PrescriptionMedID", "AppointmentID" });

            migrationBuilder.AddForeignKey(
                name: "FK_MedicationsIntakes_ReminderInstances_ReminderInstanceID",
                table: "MedicationsIntakes",
                column: "ReminderInstanceID",
                principalTable: "ReminderInstances",
                principalColumn: "InstanceID",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
