# Invoice and VAT foundation

## Context

`docs/minimartdb-implementation-phases.md` Phase 1 defines VAT rates as data and requires order-line VAT snapshots for e-invoice/legal reporting.

## Implementation pointers

- Tax rates are modeled in `backend/MiniMart/Models/TaxRate.cs` and configured in `backend/MiniMart/Data/MiniMartDbContext.cs`.
- Categories now require `TaxRateId`; the migration `backend/MiniMart/Migrations/20260625130654_AddInvoiceAndVat.cs` adds it nullable first, backfills all existing categories to `TaxRateId = 4`, then alters it to non-null.
- Order-line VAT snapshots live on `backend/MiniMart/Models/OrderDetail.cs`: `VatRate`, `UnitPriceAfterDiscount`, `VatAmount`, and `TotalWithVat`.
- E-invoice headers/details live in `backend/MiniMart/Models/EInvoice.cs` and `backend/MiniMart/Models/EInvoiceDetail.cs`.

## Gotchas

- Do not recalculate historical VAT from current category rates. Checkout/invoice generation should copy `Product -> Category -> TaxRate` into `OrderDetail.VatRate`.
- The migration backfills existing `OrderDetails` from product category tax rates using SQL after the category tax-rate FK exists.
- `EInvoiceDetails.OrderDetailId -> OrderDetails.OrderDetailId` is configured with no action so invoice cleanup cannot delete original order lines.
