# MiniMart Notebook

## Entries

- [Batch write boundary](batch-write-boundary.md) - batch API is read-only; all writes require an inventory workflow and audit trail.

- [Receipt import flow](receipt-import-flow.md) - mobile receipt creation and completion path, plus atomicity risk.

- [Flutter stock count scanning](flutter-stock-count-scanning.md) - live count screen reuses barcode scan flow.
- [Flutter stock-count API flow](flutter-stock-count-api-flow.md) - create, save, cancel, submit, approve/reject, and transaction refresh.

- [Stock count domain foundation](stock-count-domain-foundation.md) - stock-count tables, row versions, and batch provenance.

- [Expiry and batch stock gotcha](expiry-stock-flow-gotcha.md) - expiry is not enforced in checkout; batch stock drifts.

- [Staff employee contract](staff-employee-contract.md) - staff DTO password mapping and removed audit columns.
- [Cookie authentication flow](auth-cookie-flow.md) - how employee-based auth, cookies, CSRF, and refresh-token storage are wired.
- [Invoice and VAT foundation](invoice-vat-foundation.md) - TaxRates, category VAT assignments, order-detail VAT snapshots, and e-invoice relationships.
- [Phase 2 core architecture cleanup](phase2-core-cleanup.md) - store ownership, promotion discount rename, stock trigger, payment constraint, and searchable label bounds.
- [Phase 3 operational tables](phase3-operational-tables.md) - payments, point transactions, order returns, return inventory references, and minimum stock thresholds.
- [Phase 4 promotion overlap guard](phase4-promotion-overlap-guard.md) - SaveChanges validation that rejects overlapping active promotions for the same product and promotion type.
- [Package architecture](package-architecture.md) - package-level structure and current runtime dependency direction.
- [Inventory CRUD architecture](inventory-crud-architecture.md) - current inventory source anchors and proposed CRUD layering.
- [API route auth and OData controller gotcha](api-route-auth-odata-controller.md) - REST/OData mixed controllers should use ControllerBase so auth returns 401/403 instead of route parse fallout.
- [Batch schema drift](batch-schema-drift.md) - Batches migration repair for missing Quantity, TotalPrice, and IsDeleted columns.
- [Flutter Stitch login screen](flutter-stitch-login-screen.md) - frontend app location, downloaded Stitch references, and Dart/Flutter verification notes.
- [Flutter Stitch category screen](flutter-stitch-category-screen.md) - category management Stitch screen implementation and verification notes.
- [Flutter Stitch inventory documents screens](flutter-stitch-inventory-documents.md) - goods document list and receipt/detail Stitch screen implementation notes.
- [Current ERD source](current-erd-source.md) - current entity/FK source pointers and ERD caveats.
- [Core flow decision report](core-flow-decision-report.md) - source-backed recommendation to center the project on POS checkout, with supporting auth, shift, inventory, payments, and reporting flows.
- [Flutter inventory API models](flutter-inventory-api-models.md) - Dart model mapping for inventory status, batch, and inventory transaction DTOs.
