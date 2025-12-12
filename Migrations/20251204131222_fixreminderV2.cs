using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class fixreminderV2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "BaseTime",
                table: "ReminderV2s",
                newName: "FirstDoseTime");

            migrationBuilder.AddColumn<int>(
                name: "IntervalHours",
                table: "ReminderV2s",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsSimpleEveryXHours",
                table: "ReminderV2s",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IntervalHours",
                table: "ReminderV2s");

            migrationBuilder.DropColumn(
                name: "IsSimpleEveryXHours",
                table: "ReminderV2s");

            migrationBuilder.RenameColumn(
                name: "FirstDoseTime",
                table: "ReminderV2s",
                newName: "BaseTime");
        }
    }
}
