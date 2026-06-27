# MiniMart Notebook

## Entries

- [Staff employee contract](staff-employee-contract.md) - staff DTO password mapping and removed audit columns.
- [Cookie authentication flow](auth-cookie-flow.md) - how employee-based auth, cookies, CSRF, and refresh-token storage are wired.
- [Invoice and VAT foundation](invoice-vat-foundation.md) - TaxRates, category VAT assignments, order-detail VAT snapshots, and e-invoice relationships.
- [Phase 2 core architecture cleanup](phase2-core-cleanup.md) - store ownership, promotion discount rename, stock trigger, payment constraint, and searchable label bounds.
- [Phase 3 operational tables](phase3-operational-tables.md) - payments, point transactions, order returns, return inventory references, and minimum stock thresholds.
- [Phase 4 promotion overlap guard](phase4-promotion-overlap-guard.md) - SaveChanges validation that rejects overlapping active promotions for the same product and promotion type.
- [Package architecture](package-architecture.md) - package-level structure and current runtime dependency direction.
