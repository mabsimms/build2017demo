using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

namespace SampleWebAppBaseline.Migrations
{
    public partial class ChangedUserFK : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets");

            migrationBuilder.AlterColumn<long>(
                name: "AssignedToId",
                table: "Tickets",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets",
                column: "AssignedToId",
                principalTable: "User",
                principalColumn: "Key",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets");

            migrationBuilder.AlterColumn<long>(
                name: "AssignedToId",
                table: "Tickets",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets",
                column: "AssignedToId",
                principalTable: "User",
                principalColumn: "Key",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
