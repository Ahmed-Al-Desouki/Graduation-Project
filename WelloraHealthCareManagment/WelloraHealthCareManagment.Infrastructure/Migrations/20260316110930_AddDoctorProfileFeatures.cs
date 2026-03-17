using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDoctorProfileFeatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ClinicAddress",
                table: "Doctors",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "ClinicLatitude",
                table: "Doctors",
                type: "float",
                nullable: true);

            migrationBuilder.AddColumn<double>(
                name: "ClinicLongitude",
                table: "Doctors",
                type: "float",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DateOfBirth",
                table: "Doctors",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "HospitalName",
                table: "Doctors",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsProfileCompleted",
                table: "Doctors",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "NationalId",
                table: "Doctors",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "DoctorAchievements",
                columns: table => new
                {
                    AchievementId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DoctorId = table.Column<int>(type: "int", nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    FileId = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DoctorAchievements", x => x.AchievementId);
                    table.ForeignKey(
                        name: "FK_DoctorAchievements_Doctors_DoctorId",
                        column: x => x.DoctorId,
                        principalTable: "Doctors",
                        principalColumn: "DoctorId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DoctorAchievements_ExternalFiles_FileId",
                        column: x => x.FileId,
                        principalTable: "ExternalFiles",
                        principalColumn: "FileID");
                });

            migrationBuilder.CreateTable(
                name: "DoctorVerifications",
                columns: table => new
                {
                    VerificationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DoctorId = table.Column<int>(type: "int", nullable: false),
                    DocumentType = table.Column<int>(type: "int", nullable: false),
                    FileId = table.Column<int>(type: "int", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    AdminNotes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    ReviewedByAdminId = table.Column<int>(type: "int", nullable: true),
                    ReviewedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    SubmittedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DoctorVerifications", x => x.VerificationId);
                    table.ForeignKey(
                        name: "FK_DoctorVerifications_Doctors_DoctorId",
                        column: x => x.DoctorId,
                        principalTable: "Doctors",
                        principalColumn: "DoctorId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_DoctorVerifications_ExternalFiles_FileId",
                        column: x => x.FileId,
                        principalTable: "ExternalFiles",
                        principalColumn: "FileID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_DoctorAchievements_DoctorId",
                table: "DoctorAchievements",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorAchievements_FileId",
                table: "DoctorAchievements",
                column: "FileId");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_DoctorId",
                table: "DoctorVerifications",
                column: "DoctorId");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_FileId",
                table: "DoctorVerifications",
                column: "FileId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "DoctorAchievements");

            migrationBuilder.DropTable(
                name: "DoctorVerifications");

            migrationBuilder.DropColumn(
                name: "ClinicAddress",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "ClinicLatitude",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "ClinicLongitude",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "DateOfBirth",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "HospitalName",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "IsProfileCompleted",
                table: "Doctors");

            migrationBuilder.DropColumn(
                name: "NationalId",
                table: "Doctors");
        }
    }
}
