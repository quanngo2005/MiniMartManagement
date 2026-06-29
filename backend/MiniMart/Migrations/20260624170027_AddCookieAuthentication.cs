using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddCookieAuthentication : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FailedLoginAttempts",
                table: "Employees",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastFailedLoginAt",
                table: "Employees",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "LockoutEnd",
                table: "Employees",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordChangedAt",
                table: "Employees",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    RefreshTokenId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TokenHash = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RevokedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ReplacedByTokenHash = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TokenFamilyId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    DeviceName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IpAddress = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserAgent = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    EmployeeId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.RefreshTokenId);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_Employees_EmployeeId",
                        column: x => x.EmployeeId,
                        principalTable: "Employees",
                        principalColumn: "EmployeeId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_EmployeeId_TokenFamilyId",
                table: "RefreshTokens",
                columns: new[] { "EmployeeId", "TokenFamilyId" });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_TokenHash",
                table: "RefreshTokens",
                column: "TokenHash",
                unique: true);

            migrationBuilder.Sql("""
                IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Admin')
                    INSERT INTO Roles (RoleName, Description, Status, CreatedAt) VALUES (N'Admin', N'Full system administrator', 1, SYSUTCDATETIME());
                IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Manager')
                    INSERT INTO Roles (RoleName, Description, Status, CreatedAt) VALUES (N'Manager', N'Store manager', 1, SYSUTCDATETIME());
                IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Cashier')
                    INSERT INTO Roles (RoleName, Description, Status, CreatedAt) VALUES (N'Cashier', N'Point of sale employee', 1, SYSUTCDATETIME());
                IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Warehouse')
                    INSERT INTO Roles (RoleName, Description, Status, CreatedAt) VALUES (N'Warehouse', N'Warehouse employee', 1, SYSUTCDATETIME());
                IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Staff')
                    INSERT INTO Roles (RoleName, Description, Status, CreatedAt) VALUES (N'Staff', N'General employee', 1, SYSUTCDATETIME());
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropColumn(
                name: "FailedLoginAttempts",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "LastFailedLoginAt",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "LockoutEnd",
                table: "Employees");

            migrationBuilder.DropColumn(
                name: "PasswordChangedAt",
                table: "Employees");
        }
    }
}
