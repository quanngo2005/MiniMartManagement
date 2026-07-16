# Expiry and Batch Stock Gotcha

> Expiry is recorded and alerted, but checkout does not allocate batches.

Entry: `backend/MiniMart/Repositories/Implementations/OrderRepository.cs:CheckoutAsync()`

- `Models/Batch.cs` identifies `QuantityRemaining` as FEFO/expiry source of truth.
- Checkout validates and deducts only `Product.StockQuantity`; sale ledger entries have no `BatchId`.
- `ConfirmOrderCompletionAsync()` repeats the same product-only deduction for pending payments.
- `Repositories/Implementations/BatchRepository.cs:AdjustBatchRemainingQuantityAsync()` changes batch status only from remaining quantity; expiry date is ignored.
- `Repositories/Implementations/ProductRepository.cs:GetNearExpirationAsync()` can report batches with `ExpiryDate <= threshold`; it does not exclude already expired batches or change their status.
- `Services/Implementations/OrderReturnService.cs:ApproveAsync()` picks the earliest non-expired batch instead of the batch originally sold.
- Flutter has import-date entry only; no client use of the near-expiration endpoint was found.

Updated: 2026-07-12
