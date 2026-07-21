using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class AddDiscountAmmout : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF COL_LENGTH(N'dbo.Promotions', N'DiscountAmount') IS NULL
                BEGIN
                    IF COL_LENGTH(N'dbo.Promotions', N'MinOrderValue') IS NOT NULL
                    BEGIN
                        EXEC sp_rename N'dbo.Promotions.MinOrderValue', N'DiscountAmount', N'COLUMN';
                    END
                    ELSE
                    BEGIN
                        ALTER TABLE [dbo].[Promotions] ADD [DiscountAmount] decimal(18,2) NULL;
                    END
                END
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                IF COL_LENGTH(N'dbo.Promotions', N'MinOrderValue') IS NULL
                    AND COL_LENGTH(N'dbo.Promotions', N'DiscountAmount') IS NOT NULL
                BEGIN
                    EXEC sp_rename N'dbo.Promotions.DiscountAmount', N'MinOrderValue', N'COLUMN';
                END
                """);
        }
    }
}