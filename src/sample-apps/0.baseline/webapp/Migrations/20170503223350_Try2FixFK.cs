using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

namespace SampleWebAppBaseline.Migrations
{
    public partial class Try2FixFK : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets");

            migrationBuilder.RenameColumn(
                name: "AssignedToId",
                table: "Tickets",
                newName: "AssignedToKey");

            migrationBuilder.RenameIndex(
                name: "IX_Tickets_AssignedToId",
                table: "Tickets",
                newName: "IX_Tickets_AssignedToKey");

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_User_AssignedToKey",
                table: "Tickets",
                column: "AssignedToKey",
                principalTable: "User",
                principalColumn: "Key",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_User_AssignedToKey",
                table: "Tickets");

            migrationBuilder.RenameColumn(
                name: "AssignedToKey",
                table: "Tickets",
                newName: "AssignedToId");

            migrationBuilder.RenameIndex(
                name: "IX_Tickets_AssignedToKey",
                table: "Tickets",
                newName: "IX_Tickets_AssignedToId");

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_User_AssignedToId",
                table: "Tickets",
                column: "AssignedToId",
                principalTable: "User",
                principalColumn: "Key",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
