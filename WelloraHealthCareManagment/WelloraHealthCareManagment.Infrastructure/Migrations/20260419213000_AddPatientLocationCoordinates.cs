using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using WelloraHealthCareManagment.API.Context;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    [DbContext(typeof(HealthCarePlusContext))]
    [Migration("20260419213000_AddPatientLocationCoordinates")]
    public partial class AddPatientLocationCoordinates : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "CurrentLatitude",
                table: "Patients",
                type: "float",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "CurrentLongitude",
                table: "Patients",
                type: "float",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrentLatitude",
                table: "Patients");

            migrationBuilder.DropColumn(
                name: "CurrentLongitude",
                table: "Patients");
        }
    }
}
