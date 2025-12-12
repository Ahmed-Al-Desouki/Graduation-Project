using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class NotificationLogAdded1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TimeZoneId",
                table: "ReminderOccurrencesCache",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "Africa/Cairo");

            migrationBuilder.AddColumn<string>(
                name: "TimeZoneId",
                table: "NotificationLogs",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TimeZoneId",
                table: "ReminderOccurrencesCache");

            migrationBuilder.DropColumn(
                name: "TimeZoneId",
                table: "NotificationLogs");
        }
    }
}
