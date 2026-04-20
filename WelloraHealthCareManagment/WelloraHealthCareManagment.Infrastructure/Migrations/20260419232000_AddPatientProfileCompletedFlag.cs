using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using WelloraHealthCareManagment.Infrastructure.Context;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    [DbContext(typeof(HealthCarePlusContext))]
    [Migration("20260419232000_AddPatientProfileCompletedFlag")]
    public partial class AddPatientProfileCompletedFlag : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsProfileCompleted",
                table: "Patients",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsProfileCompleted",
                table: "Patients");
        }
    }
}

