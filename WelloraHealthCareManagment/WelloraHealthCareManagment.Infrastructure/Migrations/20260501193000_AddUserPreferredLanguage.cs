using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using WelloraHealthCareManagment.Infrastructure.Context;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    [DbContext(typeof(HealthCarePlusContext))]
    [Migration("20260501193000_AddUserPreferredLanguage")]
    public partial class AddUserPreferredLanguage : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PreferredLanguage",
                table: "Users",
                type: "nvarchar(10)",
                maxLength: 10,
                nullable: false,
                defaultValue: "en");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PreferredLanguage",
                table: "Users");
        }
    }
}
