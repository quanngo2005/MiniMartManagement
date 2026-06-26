# Package Architecture

## Summary

MiniMartManagement is currently centered on the ASP.NET Core project in `backend/MiniMart`. The `frontend` folder is only a placeholder.

## Runtime Package Flow

- `backend/MiniMart/Program.cs` wires EF Core, OData, Swagger, authentication, middleware, static files, and controller routing.
- `MiniMart.Controllers` currently exposes `AuthController`, which calls `MiniMart.Services`.
- `MiniMart.Services` contains auth and JWT services. `AuthService` directly uses `MiniMart.Data:MiniMartDbContext` for persistence.
- `MiniMart.Data:MiniMartDbContext` owns DbSets, EF relationships, seed data, and promotion-overlap validation.
- `MiniMart.Models`, `MiniMart.Models.Base`, and `MiniMart.Models.Enums` define the domain shape used by OData, EF Core, DTOs, and services.
- `MiniMart.Repositories.RepoInterface` contains empty repository interfaces, but no implementations are wired into the runtime path.

## Diagram

The PlantUML package diagram is in `docs/package-diagram.puml`.
