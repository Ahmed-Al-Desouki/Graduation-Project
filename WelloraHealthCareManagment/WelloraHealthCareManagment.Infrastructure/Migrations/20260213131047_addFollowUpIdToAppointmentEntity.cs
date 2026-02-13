using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WelloraHealthCareManagment.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class addFollowUpIdToAppointmentEntity : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "FollowUpFromAppointmentId",
                table: "Appointments",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "FollowUpFromId",
                table: "Appointments",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Appointments_FollowUpFromId",
                table: "Appointments",
                column: "FollowUpFromId");

            migrationBuilder.AddForeignKey(
                name: "FK_Appointments_Appointments_FollowUpFromId",
                table: "Appointments",
                column: "FollowUpFromId",
                principalTable: "Appointments",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Appointments_Appointments_FollowUpFromId",
                table: "Appointments");

            migrationBuilder.DropIndex(
                name: "IX_Appointments_FollowUpFromId",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "FollowUpFromAppointmentId",
                table: "Appointments");

            migrationBuilder.DropColumn(
                name: "FollowUpFromId",
                table: "Appointments");
        }
    }
}
