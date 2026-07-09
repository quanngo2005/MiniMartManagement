using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class ResetTestAccountPasswords : Migration
    {
        // Passwords reset to: Test@1234
        // Hash: PBKDF2-SHA256, 100000 iterations, SHA256
        private const string AdminHash    = "PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAA==:r0GIBpkS8e7GxDqGPi9RRGMTbz3e+lNuLZZL8JSwPCY=";
        private const string ManagerHash  = "PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAB==:fLt0cH9Q3iIYJa8l2GpBPY4cVbVPcE/xW7V4NpA7vUI=";

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                $"""
                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAA==:r0GIBpkS8e7GxDqGPi9RRGMTbz3e+lNuLZZL8JSwPCY='
                WHERE [Username] = N'admin.test';

                UPDATE [dbo].[Employees]
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:AAAAAAAAAAAAAAAAAAAAAB==:fLt0cH9Q3iIYJa8l2GpBPY4cVbVPcE/xW7V4NpA7vUI='
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
                SET [PasswordHash] = N'PBKDF2-SHA256:100000:CZNdjBIPynM3lzo4e7gK7A==:xiVhxkMlNdGago6CisgLJpYB9nXckw5sQW4HjrIVN1I='
                WHERE [Username] = N'manager.test';
                """);
        }
    }
}
