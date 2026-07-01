using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniMart.Data;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(MiniMartDbContext))]
    [Migration("20260629153259_AddAdminManagerTestAccounts")]
    public partial class AddAdminManagerTestAccounts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                SET IDENTITY_INSERT [dbo].[Employees] ON;

                IF NOT EXISTS (
                    SELECT 1 FROM [dbo].[Employees]
                    WHERE [EmployeeId] = 13 OR [Username] = N'admin.test' OR [PhoneNumber] = N'0901000013'
                )
                BEGIN
                    INSERT INTO [dbo].[Employees]
                        ([EmployeeId], [Address], [Avatar], [DateOfBirth], [Email], [FailedLoginAttempts], [FullName], [Gender], [HireDate], [LockoutEnd], [PasswordHash], [PhoneNumber], [RoleId], [Salary], [Status], [Username])
                    VALUES
                        (13, NULL, NULL, '1990-01-01T00:00:00', N'admin.test@minimart.vn', 0, N'Admin Test', CAST(1 AS bit), '2024-01-01T00:00:00', NULL, N'PBKDF2-SHA256:100000:vECvXvSIQjcJHLryzwWLiA==:bpMkS8sN5DSw0AfpAUBvxc4IScpN1iWkTzLPrhFSk5g=', N'0901000013', 4, 15000000, 1, N'admin.test');
                END

                IF NOT EXISTS (
                    SELECT 1 FROM [dbo].[Employees]
                    WHERE [EmployeeId] = 14 OR [Username] = N'manager.test' OR [PhoneNumber] = N'0901000014'
                )
                BEGIN
                    INSERT INTO [dbo].[Employees]
                        ([EmployeeId], [Address], [Avatar], [DateOfBirth], [Email], [FailedLoginAttempts], [FullName], [Gender], [HireDate], [LockoutEnd], [PasswordHash], [PhoneNumber], [RoleId], [Salary], [Status], [Username])
                    VALUES
                        (14, NULL, NULL, '1990-01-02T00:00:00', N'manager.test@minimart.vn', 0, N'Manager Test', CAST(1 AS bit), '2024-01-01T00:00:00', NULL, N'PBKDF2-SHA256:100000:CZNdjBIPynM3lzo4e7gK7A==:xiVhxkMlNdGago6CisgLJpYB9nXckw5sQW4HjrIVN1I=', N'0901000014', 1, 13000000, 1, N'manager.test');
                END

                SET IDENTITY_INSERT [dbo].[Employees] OFF;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                DELETE FROM [dbo].[Employees]
                WHERE [EmployeeId] IN (13, 14)
                    AND [Username] IN (N'admin.test', N'manager.test');
                """);
        }
    }
}
