using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class ResetTestAccountPasswords : Migration
    {
        // Passwords reset to: Manager@123
        // Hash: PBKDF2-SHA256, 100000 iterations, SHA256
        private const string AdminHash    = "PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAA==:r0GIBpkS8e7GxDqGPi9RRGMTbz3e+lNuLZZL8JSwPCY=";
        private const string ManagerHash  = "PBKDF2-SHA256:100000:4i06mXfdgXI4rFm+51SILA==:TSBEaTARkBveb/293mpk1+oJ98Ai3yoTyDllFlZIiO0=";

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                $"""
                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAA==:r0GIBpkS8e7GxDqGPi9RRGMTbz3e+lNuLZZL8JSwPCY='
                WHERE [Username] = N'admin.test';

                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:4i06mXfdgXI4rFm+51SILA==:TSBEaTARkBveb/293mpk1+oJ98Ai3yoTyDllFlZIiO0='
                WHERE [Username] = N'manager.test';
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Restore original hashes
            migrationBuilder.Sql(
                """
                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:vECvXvSIQjcJHLryzwWLiA==:bpMkS8sN5DSw0AfpAUBvxc4IScpN1iWkTzLPrhFSk5g='
                WHERE [Username] = N'admin.test';

                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:4i06mXfdgXI4rFm+51SILA==:TSBEaTARkBveb/293mpk1+oJ98Ai3yoTyDllFlZIiO0='
                WHERE [Username] = N'manager.test';
                """);
        }
    }
}
