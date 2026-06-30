using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniMart.Data;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(MiniMartDbContext))]
    [Migration("20260629170500_AlignRoleNamesWithAuthorizationPolicies")]
    public partial class AlignRoleNamesWithAuthorizationPolicies : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Manager'
                WHERE [RoleId] = 1 AND [RoleName] <> N'Manager';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Cashier'
                WHERE [RoleId] = 2 AND [RoleName] <> N'Cashier';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Warehouse'
                WHERE [RoleId] = 3 AND [RoleName] <> N'Warehouse';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Admin'
                WHERE [RoleId] = 4 AND [RoleName] <> N'Admin';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Quản lý'
                WHERE [RoleId] = 1 AND [RoleName] = N'Manager';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Thu ngân'
                WHERE [RoleId] = 2 AND [RoleName] = N'Cashier';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Kho'
                WHERE [RoleId] = 3 AND [RoleName] = N'Warehouse';

                UPDATE [dbo].[Roles]
                SET [RoleName] = N'Quản trị'
                WHERE [RoleId] = 4 AND [RoleName] = N'Admin';
                """);
        }
    }
}
