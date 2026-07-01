# MiniMart Core Flow Decision Report

## Purpose

This report summarizes the current source code so the team can choose the project's core user flow and avoid designing around stale assumptions.

The current codebase is a management/POS-oriented MiniMart system with:

- ASP.NET 8 backend in `backend/MiniMart`.
- Flutter management app in `frontend/mini_mart_management_mobile_app`.
- SQL Server persistence through EF Core.
- JWT cookie authentication with CSRF protection.
- OData-enabled read/query endpoints on several backend resources.

## Executive Recommendation

Use this as the core product flow:

```text
Employee login
-> open or select active shift
-> manage catalog/inventory data
-> checkout order
-> update stock, customer points, shift revenue, payment state
-> generate receipt/reporting data
```

This is the strongest flow because the backend already contains the most business logic around orders, stock, shifts, customers, loyalty points, payments, and reports. The Flutter app currently only implements a real auth path plus a static category management screen, so the frontend should grow toward this backend core instead of treating category management as the product center.

## Current Architecture

### Backend Runtime

`backend/MiniMart/Program.cs` is the backend composition root. It wires:

- `MiniMartDbContext` with SQL Server.
- Controllers plus OData query support.
- Repository and service dependencies.
- Swagger.
- localhost CORS for development.
- Exception middleware.
- CSRF middleware.
- JWT authentication and role policies.

Important runtime flow:

```text
HTTP request
-> ExceptionMiddleware
-> routing
-> CsrfMiddleware
-> JWT authentication
-> authorization policy
-> controller
-> service or repository
-> MiniMartDbContext
-> SQL Server
```

### Backend Layers

The project has a partial layered architecture:

- Controllers expose REST/OData endpoints.
- Some controllers call services: auth, inventory, batch, staff, shift.
- Some controllers call repositories directly: orders, customers, promotions, payments, reports, roles.
- Repositories own most EF Core queries and writes.
- `MiniMartDbContext` owns entity relationships, indexes, seed data, and promotion-overlap validation on save.
- DTOs exist for most API shapes.
- AutoMapper is used in newer service-backed areas, but some controllers/repositories still map manually.

Decision note: treat the intended direction as `Controller -> Service -> Repository -> DbContext`, but expect existing exceptions in order/customer/payment/report/promotion/role areas.

### Frontend Runtime

The Flutter app currently has:

- `MiniMartManagementApp` as the root widget.
- `AuthProvider -> AuthRepository -> AuthService` for login.
- HTTP calls through the `http` package.
- API base URL centralized in `lib/config/api_config.dart`.
- Login screen with real backend login integration.
- Category management screen with static local sample data.

Important current frontend flow:

```text
Flutter screen
-> Provider
-> Repository
-> Service
-> backend API
```

The app root currently opens `CategoryManagementScreen` directly, not the login screen. That means the app shell is not yet enforcing auth/navigation as the primary runtime flow.

## Domain Model Summary

The backend model suggests these major business areas:

| Area | Main entities | Meaning |
|---|---|---|
| Identity and access | `Employee`, `Role`, `RefreshToken` | Staff accounts, role policies, login sessions |
| Shift operation | `Shift`, `Employee`, `Order` | Cashier/manager work sessions and revenue |
| Catalog | `Category`, `Product`, `Supplier`, `TaxRate` | Sellable products and VAT categorization |
| Stock intake | `Receipt`, `Batch`, `Supplier`, `InventoryTransaction` | Purchasing/importing goods and batch stock |
| Sales | `Order`, `OrderDetail`, `Payment`, `Customer` | POS checkout and payment recording |
| Loyalty | `Customer`, `PointTransaction` | Customer point balance and point history |
| Promotions | `Promotion`, `PromotionProduct` | Product discount rules and overlap guard |
| Returns/invoices | `OrderReturn`, `OrderReturnDetail`, `EInvoice`, `EInvoiceDetail` | Refund and e-invoice foundation |
| Reporting | report DTOs/repository | Revenue, daily/monthly totals, cashier performance, inventory status |

## Candidate Core Flows

### Flow A: POS Sales Flow

```text
Login
-> open/current shift
-> scan/select products
-> optional customer and loyalty points
-> checkout
-> reduce product stock
-> create inventory sale transactions
-> update shift revenue
-> update customer points
-> receipt/payment/reporting
```

Why this is the best core:

- `OrderRepository.CheckoutAsync` already performs the densest transaction in the system.
- It validates active shift, product existence, stock quantity, cash payment, loyalty discount, and points.
- It writes `Order`, `OrderDetail`, `InventoryTransaction`, customer point balance changes, and shift revenue in one database transaction.
- It naturally touches the highest-value tables: products, stock, customers, employees, shifts, orders, payments, reports.

Current gaps:

- Checkout lives in a repository instead of a service.
- Checkout does not currently snapshot VAT fields even though VAT models exist.
- It updates `Customers.Point` directly instead of writing a `PointTransaction` first.
- It reduces `Products.StockQuantity` directly, while documentation says batch quantity should be the stock source of truth.
- Flutter has no POS checkout screen yet.

Recommendation: choose this as the main project flow.

### Flow B: Inventory Management Flow

```text
Login
-> warehouse/manager access
-> manage products/categories/suppliers
-> receive stock into batches
-> create inventory transactions
-> monitor low stock
```

Why it is strong:

- Product, category, supplier, batch, receipt, inventory transaction, and minimum stock fields already exist.
- Inventory endpoints are protected by `WarehouseUp`.
- Flutter category screen is already visually started.

Current gaps:

- Category screen uses static sample data.
- Product/supplier/receipt frontend flows are not implemented.
- Batch/stock source-of-truth behavior appears split between model, documentation, and checkout logic.

Recommendation: make this the first supporting flow after POS, not the sole core.

### Flow C: Admin/Staff Management Flow

```text
Login
-> manager/admin access
-> manage roles and staff
-> register employees
-> toggle accounts
-> assign policies through roles
```

Why it matters:

- Auth and staff management are implemented with role policies.
- Login includes lockout, refresh-token rotation, cookie delivery, and device limiting.
- Registration and account toggling are manager/admin protected.

Current gaps:

- Flutter does not persist session state or enforce app-wide auth routing yet.
- Some role management code uses `DbContext` directly in the controller.

Recommendation: make this an enabling flow, not the business core.

### Flow D: Finance/Reporting Flow

```text
Orders and payments
-> revenue summaries
-> daily/monthly revenue
-> cashier performance
-> inventory report
```

Why it matters:

- Reports repository already aggregates orders and inventory.
- Payment gateway integration exists for VNPAY-style callback flow.

Current gaps:

- Reports controller authorization appears commented out.
- Payment flow is separate from checkout and needs clearer relationship to order completion.
- Flutter finance/reporting screens are not implemented.

Recommendation: make this a downstream flow after sales data is reliable.

## Recommended Core Flow Definition

The project should be positioned as:

> A MiniMart management and POS system where employees authenticate, operate shifts, sell products, track stock/customer points/payments, and let managers administer inventory and reports.

The first full end-to-end flow should be:

```text
1. Employee logs in.
2. App loads current user and role permissions.
3. Cashier opens or selects an active shift.
4. Cashier browses/searches products.
5. Cashier builds a cart.
6. Optional customer is attached.
7. Loyalty points are applied if requested.
8. Checkout creates the order.
9. Backend updates order details, stock movement, customer balance, and shift revenue atomically.
10. App shows receipt and payment status.
11. Manager can view reports from completed orders.
```

## Role-Based Navigation Suggestion

Use backend roles/policies to drive frontend navigation:

| Role/policy | Primary screens |
|---|---|
| `AnyEmployee` | login, profile, current shift, basic order lookup |
| `Cashier` via `AnyEmployee` | POS checkout, receipt |
| `WarehouseUp` | inventory transactions, batches, products, categories, suppliers |
| `ManagerUp` | staff, roles, reports, promotions, admin product data |
| `Admin` | all management screens |

Backend policies currently defined:

- `ManagerUp`: `Admin`, `Manager`
- `WarehouseUp`: `Admin`, `Manager`, `Warehouse`
- `AnyEmployee`: `Admin`, `Manager`, `Cashier`, `Warehouse`, `Staff`

## API Surface by Flow

### Auth

- `GET /api/auth/csrf-token`
- `POST /api/auth/login`
- `POST /api/auth/refresh-token`
- `POST /api/auth/logout`
- `POST /api/auth/logout-all`
- `POST /api/auth/register`
- `POST /api/auth/change-password`
- `GET /api/auth/me`
- `POST /api/auth/toggle-active/{employeeId}`

### Shift

- `GET /api/shifts`
- `GET /api/shifts/{id}`
- `POST /api/shifts`
- `PUT /api/shifts/{id}`
- `DELETE /api/shifts/{id}`
- `POST /api/shifts/open`
- `POST /api/shifts/{id}/close`
- `GET /api/shifts/current`

### Sales

- `GET /api/orders`
- `GET /api/orders/{id}`
- `GET /api/orders/{id}/receipt`
- `POST /api/orders`
- `POST /api/orders/checkout`

### Payments

- `POST /api/payments/create-url`
- `GET /api/payments/{gateway}/callback`
- `GET /api/payments/{transactionRef}/status`

### Inventory/Catalog

- Inventory transactions: `GET /api/inventory`, `GET /api/inventory/{id}`, `POST /api/inventory`
- Batches: `GET/POST/PUT/DELETE /api/batches`
- Customers, promotions, staff, roles, reports also have controllers.

## Current Implementation Risks

1. Architecture is inconsistent.
   Some controllers use services, some call repositories, and `RolesController` uses `MiniMartDbContext` directly. This matters if the team wants a clean service-based core.

2. Checkout is business-critical but sits in `OrderRepository`.
   It contains business rules for stock, shifts, loyalty points, cash payment, order creation, stock update, and shift revenue. This should eventually become an `OrderService` or `CheckoutService`.

3. Frontend does not yet reflect backend core.
   The app starts on static category management instead of auth or role-based shell navigation.

4. Auth is cookie/CSRF-based, while the high-level project instruction mentions JWT sent on every authenticated request.
   Current backend supports JWT bearer from an `Authorization` header, but it also reads `access_token` from an HttpOnly cookie. Flutter login currently fetches CSRF and posts login, but it does not yet implement durable session refresh/navigation.

5. VAT/e-invoice models exist but checkout does not fully use them.
   `OrderDetail` has VAT fields, but checkout only fills `UnitPrice`, `DiscountAmount`, and `TotalPrice`.

6. Loyalty ledger exists but checkout updates customer points directly.
   `PointTransaction` exists, but the checkout path does not write point transaction records.

7. Stock source of truth is unclear.
   Documentation says active batches should drive `Products.StockQuantity`, but checkout directly decrements product stock.

8. Reporting depends on order/payment correctness.
   Reports should be treated as downstream of a hardened checkout/payment model.

## Suggested Build Order

1. Stabilize auth shell in Flutter.
   Start at login, persist/refresh session, route by role/permission, call `/api/auth/me`.

2. Implement shift-first cashier flow.
   Current shift endpoint should be the first screen after login for cashier-like users.

3. Build product browse/cart/checkout UI.
   This should call `POST /api/orders/checkout` and show receipt data.

4. Harden checkout backend.
   Move checkout business logic into a service, align stock updates, point ledger, VAT snapshot, and payment behavior.

5. Connect category/product/inventory screens to real APIs.
   Replace static Flutter category data after the sales path is clear.

6. Add manager reports.
   Only after sales, payment, stock, and points are trustworthy.

## Decision Matrix

| Candidate core | Backend readiness | Frontend readiness | Business centrality | Recommendation |
|---|---:|---:|---:|---|
| POS sales/checkout | High | Low | Very high | Choose as core |
| Inventory/catalog | Medium-high | Medium for category UI only | High | Supporting core |
| Staff/admin/auth | High | Medium for login | Medium | Enabling flow |
| Finance/reporting | Medium | Low | Medium-high | Downstream flow |

## Bottom Line

Choose POS checkout as the core flow.

Inventory, staff, auth, and reports should orbit that flow:

```text
Auth controls who can act.
Shift defines when sales happen.
Catalog/inventory defines what can be sold.
Checkout performs the main business transaction.
Payments and receipts complete the sale.
Reports explain what happened.
```

That gives the project a clear center and prevents the frontend from drifting into disconnected management screens.
