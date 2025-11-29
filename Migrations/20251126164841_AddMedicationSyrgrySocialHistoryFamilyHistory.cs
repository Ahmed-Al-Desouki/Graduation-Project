using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class AddMedicationSyrgrySocialHistoryFamilyHistory : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "FamilyHistoryEntries",
                columns: table => new
                {
                    FamilyHistoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HistoryID = table.Column<int>(type: "int", nullable: false),
                    Condition = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Relative = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    OnsetAge = table.Column<int>(type: "int", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsVerified = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FamilyHistoryEntries", x => x.FamilyHistoryID);
                    table.ForeignKey(
                        name: "FK_FamilyHistoryEntries_MedicalHistories_HistoryID",
                        column: x => x.HistoryID,
                        principalTable: "MedicalHistories",
                        principalColumn: "HistoryID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SocialHistories",
                columns: table => new
                {
                    SocialHistoryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HistoryID = table.Column<int>(type: "int", nullable: false),
                    SmokingStatus = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    SmokingDetails = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    AlcoholUse = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    DrugUse = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Occupation = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Exercise = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SocialHistories", x => x.SocialHistoryID);
                    table.ForeignKey(
                        name: "FK_SocialHistories_MedicalHistories_HistoryID",
                        column: x => x.HistoryID,
                        principalTable: "MedicalHistories",
                        principalColumn: "HistoryID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Surgeries",
                columns: table => new
                {
                    SurgeryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    HistoryID = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: false),
                    Date = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Complications = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    Source = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    AppointmentID = table.Column<int>(type: "int", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Surgeries", x => x.SurgeryID);
                    table.ForeignKey(
                        name: "FK_Surgeries_MedicalHistories_HistoryID",
                        column: x => x.HistoryID,
                        principalTable: "MedicalHistories",
                        principalColumn: "HistoryID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_FamilyHistoryEntries_HistoryID",
                table: "FamilyHistoryEntries",
                column: "HistoryID");

            migrationBuilder.CreateIndex(
                name: "IX_SocialHistories_HistoryID",
                table: "SocialHistories",
                column: "HistoryID");

            migrationBuilder.CreateIndex(
                name: "IX_Surgeries_HistoryID",
                table: "Surgeries",
                column: "HistoryID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FamilyHistoryEntries");

            migrationBuilder.DropTable(
                name: "SocialHistories");

            migrationBuilder.DropTable(
                name: "Surgeries");
        }
    }
}
