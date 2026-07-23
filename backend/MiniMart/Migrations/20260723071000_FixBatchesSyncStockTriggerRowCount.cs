using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    public partial class FixBatchesSyncStockTriggerRowCount : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                ALTER TRIGGER [dbo].[trg_Batches_SyncStock]
                ON [dbo].[Batches]
                AFTER INSERT, UPDATE
                AS
                BEGIN
                    SET NOCOUNT ON;

                    DECLARE @OriginalRowCount INT = @@ROWCOUNT;

                    UPDATE p
                    SET StockQuantity = ISNULL(stock.QuantityRemaining, 0)
                    FROM [dbo].[Products] p
                    INNER JOIN (SELECT DISTINCT ProductId FROM inserted) changed
                        ON changed.ProductId = p.ProductId
                    OUTER APPLY (
                        SELECT SUM(b.QuantityRemaining) AS QuantityRemaining
                        FROM [dbo].[Batches] b
                        WHERE b.ProductId = p.ProductId AND b.Status = 1
                    ) stock;

                    SELECT TOP (@OriginalRowCount) 1 FROM inserted;
                END
                """);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
                ALTER TRIGGER [dbo].[trg_Batches_SyncStock]
                ON [dbo].[Batches]
                AFTER INSERT, UPDATE
                AS
                BEGIN
                    SET NOCOUNT ON;

                    UPDATE p
                    SET StockQuantity = ISNULL(stock.QuantityRemaining, 0)
                    FROM [dbo].[Products] p
                    INNER JOIN (SELECT DISTINCT ProductId FROM inserted) changed
                        ON changed.ProductId = p.ProductId
                    OUTER APPLY (
                        SELECT SUM(b.QuantityRemaining) AS QuantityRemaining
                        FROM [dbo].[Batches] b
                        WHERE b.ProductId = p.ProductId AND b.Status = 1
                    ) stock;
                END
                """);
        }
    }
}
