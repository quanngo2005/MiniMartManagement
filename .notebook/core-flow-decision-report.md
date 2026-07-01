# Core Flow Decision Report

## Summary

Created `docs/core-flow-decision-report.md` as the current source-backed decision report for choosing the MiniMart core flow.

Key conclusion: use POS checkout as the core flow, surrounded by auth, shift operation, catalog/inventory, payments, and reporting.

## Source anchors

- Backend runtime composition: `backend/MiniMart/Program.cs`
- Auth flow: `backend/MiniMart/Controllers/AuthController.cs`, `backend/MiniMart/Services/Implementations/AuthService.cs`, `backend/MiniMart/Shared/Extensions/ServiceExtensions.cs`
- Checkout transaction: `backend/MiniMart/Controllers/OrdersController.cs`, `backend/MiniMart/Repositories/Implementations/OrderRepository.cs`
- Payment flow: `backend/MiniMart/Controllers/PaymentsController.cs`, `backend/MiniMart/Repositories/Implementations/PaymentRepository.cs`
- Inventory flow: `backend/MiniMart/Controllers/InventoryController.cs`, `backend/MiniMart/Services/Implementations/InventoryService.cs`
- Domain relationships: `backend/MiniMart/Data/MiniMartDbContext.cs`, `backend/MiniMart/Models/`
- Flutter shell/auth/category state: `frontend/mini_mart_management_mobile_app/lib/app.dart`, `frontend/mini_mart_management_mobile_app/lib/services/auth_service.dart`, `frontend/mini_mart_management_mobile_app/lib/screens/login_screen.dart`, `frontend/mini_mart_management_mobile_app/lib/screens/category_management_screen.dart`

## Notes

- The older `package-architecture.md` note says the frontend is only a placeholder, but source now contains a real Flutter app with auth plumbing and a static category screen.
- Checkout currently contains business logic in `OrderRepository.CheckoutAsync`; if the team formalizes the core flow, this is the prime candidate to move behind a service boundary.
