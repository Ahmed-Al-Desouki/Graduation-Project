using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixMedicalHistoryAccessGrantDoctorFK : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId",
                table: "MedicalHistoryAccessGrants");

            migrationBuilder.DropForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId1",
                table: "MedicalHistoryAccessGrants");

            migrationBuilder.DropIndex(
                name: "IX_MedicalHistoryAccessGrants_DoctorId1",
                table: "MedicalHistoryAccessGrants");

            migrationBuilder.DropColumn(
                name: "DoctorId1",
                table: "MedicalHistoryAccessGrants");

            migrationBuilder.AddForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId",
                table: "MedicalHistoryAccessGrants",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId",
                table: "MedicalHistoryAccessGrants");

            migrationBuilder.AddColumn<int>(
                name: "DoctorId1",
                table: "MedicalHistoryAccessGrants",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_MedicalHistoryAccessGrants_DoctorId1",
                table: "MedicalHistoryAccessGrants",
                column: "DoctorId1");

            migrationBuilder.AddForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId",
                table: "MedicalHistoryAccessGrants",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId");

            migrationBuilder.AddForeignKey(
                name: "FK_MedicalHistoryAccessGrants_Doctors_DoctorId1",
                table: "MedicalHistoryAccessGrants",
                column: "DoctorId1",
                principalTable: "Doctors",
                principalColumn: "DoctorId");
        }
    }
}
