using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HealthCare_.Migrations
{
    /// <inheritdoc />
    public partial class fixAbludeFiles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Category",
                table: "ExternalFiles");

            migrationBuilder.AddColumn<string>(
                name: "CategoryType",
                table: "ExternalFiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CategoryValue",
                table: "ExternalFiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "UploadedById",
                table: "ExternalFiles",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "UploadedByRole",
                table: "ExternalFiles",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "Doctors",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500);

            migrationBuilder.CreateIndex(
                name: "IX_ExternalFiles_Category",
                table: "ExternalFiles",
                columns: new[] { "CategoryType", "CategoryValue" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_ExternalFiles_Category",
                table: "ExternalFiles");

            migrationBuilder.DropColumn(
                name: "CategoryType",
                table: "ExternalFiles");

            migrationBuilder.DropColumn(
                name: "CategoryValue",
                table: "ExternalFiles");

            migrationBuilder.DropColumn(
                name: "UploadedById",
                table: "ExternalFiles");

            migrationBuilder.DropColumn(
                name: "UploadedByRole",
                table: "ExternalFiles");

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "ExternalFiles",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AlterColumn<string>(
                name: "Description",
                table: "Doctors",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(500)",
                oldMaxLength: 500,
                oldNullable: true);
        }
    }
}
