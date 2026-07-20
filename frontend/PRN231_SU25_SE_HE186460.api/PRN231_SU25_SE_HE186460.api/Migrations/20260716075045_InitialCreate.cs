using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PRN231_SU25_SE_HE186460.api.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "LeopardAccount",
                columns: table => new
                {
                    AccountID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Password = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Phone = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LeopardAccount", x => x.AccountID);
                });

            migrationBuilder.CreateTable(
                name: "LeopardType",
                columns: table => new
                {
                    LeopardTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LeopardTypeName = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: true),
                    Origin = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: true),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LeopardType", x => x.LeopardTypeId);
                });

            migrationBuilder.CreateTable(
                name: "LeopardProfile",
                columns: table => new
                {
                    LeopardProfileId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LeopardTypeId = table.Column<int>(type: "int", nullable: false),
                    LeopardName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Weight = table.Column<double>(type: "float", nullable: false),
                    Characteristics = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    CareNeeds = table.Column<string>(type: "nvarchar(1500)", maxLength: 1500, nullable: false),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LeopardProfile", x => x.LeopardProfileId);
                    table.ForeignKey(
                        name: "FK_LeopardProfile_LeopardType_LeopardTypeId",
                        column: x => x.LeopardTypeId,
                        principalTable: "LeopardType",
                        principalColumn: "LeopardTypeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_LeopardProfile_LeopardTypeId",
                table: "LeopardProfile",
                column: "LeopardTypeId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "LeopardAccount");

            migrationBuilder.DropTable(
                name: "LeopardProfile");

            migrationBuilder.DropTable(
                name: "LeopardType");
        }
    }
}
