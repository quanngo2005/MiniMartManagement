using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MiniMart.Migrations
{
    /// <inheritdoc />
    public partial class SeedTaxRates : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Seed TaxRates
            migrationBuilder.Sql(@"
                SET IDENTITY_INSERT TaxRates ON;
                INSERT INTO TaxRates (TaxRateId, Rate, Description, EffectiveFrom, EffectiveTo, Status)
                SELECT 1, 0.00, 'Không chịu thuế', '2024-01-01', NULL, 1
                WHERE NOT EXISTS (SELECT 1 FROM TaxRates WHERE TaxRateId = 1);
                INSERT INTO TaxRates (TaxRateId, Rate, Description, EffectiveFrom, EffectiveTo, Status)
                SELECT 2, 0.05, 'Thuế 5%', '2024-01-01', NULL, 1
                WHERE NOT EXISTS (SELECT 1 FROM TaxRates WHERE TaxRateId = 2);
                INSERT INTO TaxRates (TaxRateId, Rate, Description, EffectiveFrom, EffectiveTo, Status)
                SELECT 3, 0.08, 'Thuế 8%', '2024-01-01', NULL, 1
                WHERE NOT EXISTS (SELECT 1 FROM TaxRates WHERE TaxRateId = 3);
                INSERT INTO TaxRates (TaxRateId, Rate, Description, EffectiveFrom, EffectiveTo, Status)
                SELECT 4, 0.10, 'Thuế 10%', '2024-01-01', NULL, 1
                WHERE NOT EXISTS (SELECT 1 FROM TaxRates WHERE TaxRateId = 4);
                SET IDENTITY_INSERT TaxRates OFF;
            ");

            // Update Categories to use TaxRateId (0% as default for testing)
            migrationBuilder.Sql("UPDATE Categories SET TaxRateId = 1 WHERE TaxRateId IS NULL");
            migrationBuilder.Sql("UPDATE Categories SET TaxRateId = 3 WHERE TaxRateId NOT IN (1,2,3,4)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DELETE FROM TaxRates WHERE TaxRateId IN (1,2,3,4)");
        }
    }
}
