using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddNotificationNavigationMetadata : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NavigationPayloadJson",
                table: "Notifications",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NavigationTarget",
                table: "Notifications",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RelatedEntityKey",
                table: "Notifications",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_RelatedEntityType_RelatedEntityKey",
                table: "Notifications",
                columns: new[] { "RelatedEntityType", "RelatedEntityKey" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Notifications_RelatedEntityType_RelatedEntityKey",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "NavigationPayloadJson",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "NavigationTarget",
                table: "Notifications");

            migrationBuilder.DropColumn(
                name: "RelatedEntityKey",
                table: "Notifications");
        }
    }
}
