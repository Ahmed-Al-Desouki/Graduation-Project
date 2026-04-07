using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDoctorVerificationWithRejectionReason : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DoctorVerifications_Doctors_DoctorId",
                table: "DoctorVerifications");

            migrationBuilder.DropForeignKey(
                name: "FK_DoctorVerifications_ExternalFiles_FileId",
                table: "DoctorVerifications");

            migrationBuilder.AlterColumn<DateTime>(
                name: "SubmittedAt",
                table: "DoctorVerifications",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.AlterColumn<string>(
                name: "Status",
                table: "DoctorVerifications",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "Pending",
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "DocumentType",
                table: "DoctorVerifications",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_DoctorId_Status",
                table: "DoctorVerifications",
                columns: new[] { "DoctorId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_ReviewedByAdminId",
                table: "DoctorVerifications",
                column: "ReviewedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_Status",
                table: "DoctorVerifications",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_DoctorVerifications_SubmittedAt",
                table: "DoctorVerifications",
                column: "SubmittedAt");

            migrationBuilder.AddForeignKey(
                name: "FK_DoctorVerifications_Doctors_DoctorId",
                table: "DoctorVerifications",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_DoctorVerifications_ExternalFiles_FileId",
                table: "DoctorVerifications",
                column: "FileId",
                principalTable: "ExternalFiles",
                principalColumn: "FileID",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_DoctorVerifications_Users_ReviewedByAdminId",
                table: "DoctorVerifications",
                column: "ReviewedByAdminId",
                principalTable: "Users",
                principalColumn: "UserID",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_DoctorVerifications_Doctors_DoctorId",
                table: "DoctorVerifications");

            migrationBuilder.DropForeignKey(
                name: "FK_DoctorVerifications_ExternalFiles_FileId",
                table: "DoctorVerifications");

            migrationBuilder.DropForeignKey(
                name: "FK_DoctorVerifications_Users_ReviewedByAdminId",
                table: "DoctorVerifications");

            migrationBuilder.DropIndex(
                name: "IX_DoctorVerifications_DoctorId_Status",
                table: "DoctorVerifications");

            migrationBuilder.DropIndex(
                name: "IX_DoctorVerifications_ReviewedByAdminId",
                table: "DoctorVerifications");

            migrationBuilder.DropIndex(
                name: "IX_DoctorVerifications_Status",
                table: "DoctorVerifications");

            migrationBuilder.DropIndex(
                name: "IX_DoctorVerifications_SubmittedAt",
                table: "DoctorVerifications");

            migrationBuilder.AlterColumn<DateTime>(
                name: "SubmittedAt",
                table: "DoctorVerifications",
                type: "datetime2",
                nullable: false,
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AlterColumn<int>(
                name: "Status",
                table: "DoctorVerifications",
                type: "int",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)",
                oldDefaultValue: "Pending");

            migrationBuilder.AlterColumn<int>(
                name: "DocumentType",
                table: "DoctorVerifications",
                type: "int",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.AddForeignKey(
                name: "FK_DoctorVerifications_Doctors_DoctorId",
                table: "DoctorVerifications",
                column: "DoctorId",
                principalTable: "Doctors",
                principalColumn: "DoctorId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_DoctorVerifications_ExternalFiles_FileId",
                table: "DoctorVerifications",
                column: "FileId",
                principalTable: "ExternalFiles",
                principalColumn: "FileID");
        }
    }
}
