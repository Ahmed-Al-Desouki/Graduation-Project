using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class MakeDateOfBirthNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<DateTime>(
                name: "DateOfBirth",
                table: "MedicalHistories",
                type: "datetime2",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "datetime2");

            migrationBuilder.CreateIndex(
                name: "IX_ExternalFiles_UploadedById",
                table: "ExternalFiles",
                column: "UploadedById");

            migrationBuilder.AddForeignKey(
                name: "FK_ExternalFiles_Users_UploadedById",
                table: "ExternalFiles",
                column: "UploadedById",
                principalTable: "Users",
                principalColumn: "UserID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ExternalFiles_Users_UploadedById",
                table: "ExternalFiles");

            migrationBuilder.DropIndex(
                name: "IX_ExternalFiles_UploadedById",
                table: "ExternalFiles");

            migrationBuilder.AlterColumn<DateTime>(
                name: "DateOfBirth",
                table: "MedicalHistories",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldNullable: true);
        }
    }
}
