using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class MakeDeleteActionSoftOnMedicalHistory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Surgeries",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "SocialHistories",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "SocialHistories",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "PatientSelfMedications",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "PatientSelfMedications",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "FamilyHistoryEntries",
                type: "datetime2",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Surgeries");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "SocialHistories");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "SocialHistories");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "PatientSelfMedications");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "PatientSelfMedications");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "FamilyHistoryEntries");
        }
    }
}
