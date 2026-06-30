# API Route Auth And OData Controller Gotcha

## Context

REST endpoints such as `GET /api/shifts` and `GET /api/inventory` are protected by ASP.NET Core authorization policies in:

- `backend/MiniMart/Controllers/ShiftsController.cs`
- `backend/MiniMart/Controllers/InventoryController.cs`
- `backend/MiniMart/Shared/Extensions/ServiceExtensions.cs`

`ManagerUp` allows `Admin` and `Manager`; `WarehouseUp` allows `Admin`, `Manager`, and `Warehouse`.

## Gotcha

Controllers that expose both REST attribute routes (`api/...`) and OData-style routes (`odata/...`) should not inherit from `ODataController` when they also have non-OData action segments such as `open`, `current`, or `{id}/close`.

When `ShiftsController` inherited from `ODataController`, ASP.NET OData attempted to parse REST action routes as OData path templates, including `odata/Shifts/open`, which is not a valid OData path. That can prevent endpoints from being mapped cleanly and make clients see 404-like behavior instead of normal authorization status codes.

## Current Pattern

Use `ControllerBase` for these mixed REST controllers and keep `[EnableQuery]` on list actions that need query options.

With routes mapped normally:

- Missing/invalid JWT should be `401 Unauthorized`.
- Authenticated user without the required role should be `403 Forbidden`.
- Valid role should enter the action and only return `404 Not Found` for missing data.
