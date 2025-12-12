using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class fixandupdatesomecolumnonreminderv2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "StartDate",
                table: "ReminderV2s",
                newName: "StartDateUtc");

            migrationBuilder.RenameColumn(
                name: "EndDate",
                table: "ReminderV2s",
                newName: "EndDateUtc");

            migrationBuilder.AddColumn<DateTime>(
                name: "DueDateTimeUtc",
                table: "ReminderOccurrencesCache",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DueDateTimeUtc",
                table: "ReminderOccurrenceLogs",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DueDateTimeUtc",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropColumn(
                name: "DueDateTimeUtc",
                table: "ReminderOccurrenceLogs");

            migrationBuilder.RenameColumn(
                name: "StartDateUtc",
                table: "ReminderV2s",
                newName: "StartDate");

            migrationBuilder.RenameColumn(
                name: "EndDateUtc",
                table: "ReminderV2s",
                newName: "EndDate");
        }
    }
}
