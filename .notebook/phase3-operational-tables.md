# Phase 3 Operational Tables

## Scope

Phase 3 adds operational records around payments, customer points, returns, and low-stock thresholds.

## Tables and Models

- `Payments` records split or external payment rows for an order. `Orders.PaymentMethod` remains the dominant/primary method, while `Payments` stores detailed rows with `PaymentMethod`, `Amount`, optional `TransactionRef`, and `PaidAt`.
- `PointTransactions` records loyalty point movements. Application code should write a transaction first, then update `Customers.Point` from `BalanceAfter`; it should not update the customer point balance directly.
- `OrderReturns` and `OrderReturnDetails` model returned sales. They intentionally use `OrderReturn` naming instead of the ambiguous `Return`.
- `Products.MinimumStock` is a required integer with database default `0`.

## Relationship Notes

- `Payments.OrderId` cascades when an order is deleted.
- `PointTransactions.CustomerId` is restricted and `PointTransactions.OrderId` is set null if the order is removed.
- `OrderReturns.OriginalOrderId` and `OrderReturns.EmployeeId` are restricted.
- `OrderReturns.EInvoiceId` is optional and uses no-action delete behavior.
- `OrderReturnDetails.OrderReturnId` cascades and `OrderReturnDetails.ProductId` is restricted.

## Enum Bounds

- `PointTransactionType`: `Earn = 1`, `Redeem = 2`, `Adjust = 3`, `Expire = 4`.
- `OrderReturnStatus`: `Pending = 1`, `Approved = 2`, `Rejected = 3`.
- `PaymentMethod`: existing bounds now include `Cash = 1`, `CreditCard = 2`, `BankTransfer = 3`, `Momo = 4`, `VNPay = 5`, `ZaloPay = 6`.
- Return inventory references use `ReferenceType.OrderReturn = 5` and `InventoryTransactionType.OrderReturn = 6`.

## Migration

Migration `20260625142155_Phase3OperationalFeatureTables` creates `Payments`, `PointTransactions`, `OrderReturns`, and `OrderReturnDetails`, adds `Products.MinimumStock`, and applies check constraints for the bounded enums.
