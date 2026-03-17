using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDoctorSlotConfigs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TimeSlots_DoctorScheduleTemplates_DoctorScheduleTemplateId",
                table: "TimeSlots");

            migrationBuilder.DropForeignKey(
                name: "FK_TimeSlots_DoctorScheduleTemplates_GeneratedFromTemplateId",
                table: "TimeSlots");

            migrationBuilder.DropTable(
                name: "ScheduleTimeRanges");

            migrationBuilder.DropTable(
                name: "DoctorScheduleTemplates");

            migrationBuilder.DropIndex(
                name: "IX_TimeSlots_DoctorScheduleTemplateId",
                table: "TimeSlots");

            migrationBuilder.DropIndex(
                name: "IX_TimeSlots_GeneratedFromTemplateId",
                table: "TimeSlots");

            migrationBuilder.DropColumn(
                name: "DoctorScheduleTemplateId",
                table: "TimeSlots");

            migrationBuilder.AlterColumn<string>(
                name: "FilePath",
                table: "Reviews",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500);

            migrationBuilder.CreateTable(
                name: "DoctorSlotConfigs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    DoctorId = table.Column<int>(type: "int", nullable: false),
                    DayOfWeek = table.Column<int>(type: "int", nullable: false),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    SlotDurationMinutes = table.Column<int>(type: "int", nullable: false),
                    BufferTimeMinutes = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DoctorSlotConfigs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DoctorSlotConfigs_Doctors_DoctorId",
                        column: x => x.DoctorId,
                        principalTable: "Doctors",
                        principalColumn: "DoctorId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DoctorSlotConfigs_DoctorId",
                table: "DoctorSlotConfigs",
                column: "DoctorId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DoctorSlotConfigs");

            migrationBuilder.AddColumn<Guid>(
                name: "DoctorScheduleTemplateId",
                table: "TimeSlots",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "FilePath",
                table: "Reviews",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);

            migrationBuilder.CreateTable(
                name: "DoctorScheduleTemplates",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    DoctorId = table.Column<int>(type: "int", nullable: false),
                    BufferTimeMinutes = table.Column<int>(type: "int", nullable: false, defaultValue: 0),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    EffectiveFromDate = table.Column<DateTime>(type: "date", nullable: false),
                    EffectiveToDate = table.Column<DateTime>(type: "date", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    IsOpenEnded = table.Column<bool>(type: "bit", nullable: false),
                    SlotDurationMinutes = table.Column<int>(type: "int", nullable: false),
                    TemplateName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DoctorScheduleTemplates", x => x.Id);
                    table.ForeignKey(
                        name: "FK_DoctorScheduleTemplates_Doctors_DoctorId",
                        column: x => x.DoctorId,
                        principalTable: "Doctors",
                        principalColumn: "DoctorId");
                });

            migrationBuilder.CreateTable(
                name: "ScheduleTimeRanges",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ScheduleTemplateId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DayOfWeek = table.Column<int>(type: "int", nullable: false),
                    EndTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    StartTime = table.Column<TimeSpan>(type: "time", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ScheduleTimeRanges", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ScheduleTimeRanges_DoctorScheduleTemplates_ScheduleTemplateId",
                        column: x => x.ScheduleTemplateId,
                        principalTable: "DoctorScheduleTemplates",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_TimeSlots_DoctorScheduleTemplateId",
                table: "TimeSlots",
                column: "DoctorScheduleTemplateId");

            migrationBuilder.CreateIndex(
                name: "IX_TimeSlots_GeneratedFromTemplateId",
                table: "TimeSlots",
                column: "GeneratedFromTemplateId");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorScheduleTemplates_DoctorId_Active",
                table: "DoctorScheduleTemplates",
                columns: new[] { "DoctorId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_DoctorScheduleTemplates_EffectiveFromDate",
                table: "DoctorScheduleTemplates",
                column: "EffectiveFromDate");

            migrationBuilder.CreateIndex(
                name: "IX_ScheduleTimeRanges_TemplateId_Day",
                table: "ScheduleTimeRanges",
                columns: new[] { "ScheduleTemplateId", "DayOfWeek" });

            migrationBuilder.CreateIndex(
                name: "UQ_ScheduleTimeRange",
                table: "ScheduleTimeRanges",
                columns: new[] { "ScheduleTemplateId", "DayOfWeek", "StartTime", "EndTime" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_TimeSlots_DoctorScheduleTemplates_DoctorScheduleTemplateId",
                table: "TimeSlots",
                column: "DoctorScheduleTemplateId",
                principalTable: "DoctorScheduleTemplates",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_TimeSlots_DoctorScheduleTemplates_GeneratedFromTemplateId",
                table: "TimeSlots",
                column: "GeneratedFromTemplateId",
                principalTable: "DoctorScheduleTemplates",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
