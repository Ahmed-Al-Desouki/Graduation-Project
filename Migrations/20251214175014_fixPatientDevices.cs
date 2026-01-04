using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class fixPatientDevices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Id",
                table: "PatientDevices",
                newName: "DeviceId");

            migrationBuilder.AddColumn<DateTime>(
                name: "LastUpdated",
                table: "PatientDevices",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LastUpdated",
                table: "PatientDevices");

            migrationBuilder.RenameColumn(
                name: "DeviceId",
                table: "PatientDevices",
                newName: "Id");
        }
    }
}
