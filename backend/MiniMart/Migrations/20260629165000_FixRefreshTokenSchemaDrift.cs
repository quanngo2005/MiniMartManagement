using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniMart.Data;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(MiniMartDbContext))]
    [Migration("20260629165000_FixRefreshTokenSchemaDrift")]
    public partial class FixRefreshTokenSchemaDrift : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[RefreshTokens]', N'U') IS NOT NULL
                BEGIN
                    IF EXISTS (
                        SELECT 1
                        FROM sys.indexes
                        WHERE [name] = N'IX_RefreshTokens_EmployeeId_TokenFamilyId'
                            AND [object_id] = OBJECT_ID(N'[dbo].[RefreshTokens]')
                    )
                    BEGIN
                        DROP INDEX [IX_RefreshTokens_EmployeeId_TokenFamilyId] ON [dbo].[RefreshTokens];
                    END

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'ReplacedByTokenHash') IS NOT NULL
                        ALTER TABLE [dbo].[RefreshTokens] DROP COLUMN [ReplacedByTokenHash];

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'TokenFamilyId') IS NOT NULL
                        ALTER TABLE [dbo].[RefreshTokens] DROP COLUMN [TokenFamilyId];

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'DeviceName') IS NOT NULL
                        ALTER TABLE [dbo].[RefreshTokens] DROP COLUMN [DeviceName];

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'IpAddress') IS NOT NULL
                        ALTER TABLE [dbo].[RefreshTokens] DROP COLUMN [IpAddress];

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'UserAgent') IS NOT NULL
                        ALTER TABLE [dbo].[RefreshTokens] DROP COLUMN [UserAgent];
                END
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF OBJECT_ID(N'[dbo].[RefreshTokens]', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH(N'dbo.RefreshTokens', N'ReplacedByTokenHash') IS NULL
                        ALTER TABLE [dbo].[RefreshTokens] ADD [ReplacedByTokenHash] nvarchar(max) NULL;

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'TokenFamilyId') IS NULL
                        ALTER TABLE [dbo].[RefreshTokens] ADD [TokenFamilyId] nvarchar(450) NOT NULL CONSTRAINT [DF_RefreshTokens_TokenFamilyId_Restore] DEFAULT N'legacy';

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'DeviceName') IS NULL
                        ALTER TABLE [dbo].[RefreshTokens] ADD [DeviceName] nvarchar(max) NULL;

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'IpAddress') IS NULL
                        ALTER TABLE [dbo].[RefreshTokens] ADD [IpAddress] nvarchar(max) NULL;

                    IF COL_LENGTH(N'dbo.RefreshTokens', N'UserAgent') IS NULL
                        ALTER TABLE [dbo].[RefreshTokens] ADD [UserAgent] nvarchar(max) NULL;

                    IF NOT EXISTS (
                        SELECT 1
                        FROM sys.indexes
                        WHERE [name] = N'IX_RefreshTokens_EmployeeId_TokenFamilyId'
                            AND [object_id] = OBJECT_ID(N'[dbo].[RefreshTokens]')
                    )
                    BEGIN
                        CREATE INDEX [IX_RefreshTokens_EmployeeId_TokenFamilyId]
                        ON [dbo].[RefreshTokens] ([EmployeeId], [TokenFamilyId]);
                    END
                END
                """);
        }
    }
}
