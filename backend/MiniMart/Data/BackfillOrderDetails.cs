using Microsoft.EntityFrameworkCore;
using MiniMart.Shared.Utils;

namespace MiniMart.Data
{
    /// <summary>
    /// Backfill script for existing OrderDetail rows created under Model A (VatRate=0, VatAmount=0).
    /// Run this ONCE after migration AddAmountBeforeVATToOrderDetail to recalculate VAT for existing orders.
    /// </summary>
    public static class BackfillOrderDetails
    {
        public static async Task RunAsync(MiniMartDbContext context)
        {
            Console.WriteLine("=== Backfill OrderDetails — Model A → Model B ===");

            var strategy = context.Database.CreateExecutionStrategy();
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await context.Database.BeginTransactionAsync();
                try
                {
                    var details = await context.OrderDetails
                        .Include(od => od.Product)
                            .ThenInclude(p => p.Category)
                                .ThenInclude(c => c.TaxRate)
                        .Where(od => od.VatRate == 0 && od.TotalPrice > 0)
                        .ToListAsync();

                    Console.WriteLine($"Found {details.Count} OrderDetail(s) with VatRate = 0.");

                    var affectedOrderIds = new HashSet<int>();
                    int updatedCount = 0;

                    foreach (var detail in details)
                    {
                        var taxRate = detail.Product?.Category?.TaxRate?.Rate ?? 0m;
                        detail.VatRate = taxRate;

                        if (detail.IsGift)
                        {
                            detail.VatAmount = 0;
                            detail.AmountBeforeVAT = 0;
                        }
                        else
                        {
                            var netLineTotal = detail.TotalPrice - detail.DiscountAmount;
                            if (netLineTotal <= 0)
                            {
                                detail.VatAmount = 0;
                                detail.AmountBeforeVAT = 0;
                            }
                            else
                            {
                                // Khi VatRate = 0: (1 + 0/100) = 1 → AmountBeforeVAT = netLineTotal, VatAmount = 0
                                detail.AmountBeforeVAT = Math.Round(
                                    netLineTotal / (1 + taxRate / 100m), 0, MidpointRounding.AwayFromZero);
                                detail.VatAmount = netLineTotal - detail.AmountBeforeVAT;
                            }
                        }

                        affectedOrderIds.Add(detail.OrderId);
                        updatedCount++;
                    }

                    Console.WriteLine($"Updated {updatedCount} OrderDetail(s).");

                    // Recalculate parent Order.TaxAmount
                    foreach (var orderId in affectedOrderIds)
                    {
                        var order = await context.Orders
                            .Include(o => o.OrderDetails)
                            .FirstOrDefaultAsync(o => o.OrderId == orderId);

                        if (order != null)
                        {
                            order.TaxAmount = order.OrderDetails.Sum(od => od.VatAmount);
                            Console.WriteLine($"  Order {order.OrderCode} (ID {orderId}): TaxAmount = {order.TaxAmount}");
                        }
                    }

                    await context.SaveChangesAsync();
                    await transaction.CommitAsync();
                    Console.WriteLine("=== Backfill complete ===");
                }
                catch
                {
                    await transaction.RollbackAsync();
                    Console.WriteLine("=== Backfill failed — transaction rolled back ===");
                    throw;
                }
            });
        }
    }
}