using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using MiniMart.Data;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(MiniMartDbContext))]
    [Migration("20260630103000_EnsureBatchColumns")]
    public partial class EnsureBatchColumns : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF COL_LENGTH(N'dbo.Batches', N'IsDeleted') IS NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches]
                    ADD [IsDeleted] bit NOT NULL CONSTRAINT [DF_Batches_IsDeleted] DEFAULT CAST(0 AS bit);
                END

                IF COL_LENGTH(N'dbo.Batches', N'Quantity') IS NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches]
                    ADD [Quantity] int NOT NULL CONSTRAINT [DF_Batches_Quantity] DEFAULT 0;

                    EXEC(N'UPDATE [dbo].[Batches] SET [Quantity] = [QuantityImported];');
                END

                IF COL_LENGTH(N'dbo.Batches', N'TotalPrice') IS NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches]
                    ADD [TotalPrice] decimal(18,2) NOT NULL CONSTRAINT [DF_Batches_TotalPrice] DEFAULT 0;

                    EXEC(N'UPDATE [dbo].[Batches] SET [TotalPrice] = [ImportPrice] * [QuantityImported];');
                END
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF COL_LENGTH(N'dbo.Batches', N'TotalPrice') IS NOT NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches] DROP CONSTRAINT IF EXISTS [DF_Batches_TotalPrice];
                    ALTER TABLE [dbo].[Batches] DROP COLUMN [TotalPrice];
                END

                IF COL_LENGTH(N'dbo.Batches', N'Quantity') IS NOT NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches] DROP CONSTRAINT IF EXISTS [DF_Batches_Quantity];
                    ALTER TABLE [dbo].[Batches] DROP COLUMN [Quantity];
                END

                IF COL_LENGTH(N'dbo.Batches', N'IsDeleted') IS NOT NULL
                BEGIN
                    ALTER TABLE [dbo].[Batches] DROP CONSTRAINT IF EXISTS [DF_Batches_IsDeleted];
                    ALTER TABLE [dbo].[Batches] DROP COLUMN [IsDeleted];
                END
                """);
        }
    }
}
