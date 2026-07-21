# MiniMart Management System

A retail management platform with inventory tracking, POS operations, employee management, promotions, order returns, stock counting, e-invoicing, and real-time notifications.

| Layer | Technology |
|-------|-----------|
| **Backend API** | ASP.NET Core 8 Web API |
| **ORM** | Entity Framework Core 8 |
| **Database** | SQL Server |
| **Auth** | JWT Bearer + HttpOnly Cookies (dual-token, refresh rotation) |
| **API Query** | OData v8 |
| **Real-time** | SignalR |
| **Mapping** | AutoMapper 12 |
| **Mobile** | Flutter 3.x + Provider |
| **Desktop** | WPF .NET 8 + CommunityToolkit.Mvvm |

---

## Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────────┐
│  Flutter App  │    │  WPF Desktop │    │  3rd Party (VnPay)│
│  (Provider)   │    │  (MVVM)      │    │                  │
└──────┬───────┘    └──────┬───────┘    └────────┬─────────┘
       │                   │                      │
       └───────────────────┼──────────────────────┘
                          │
                   ┌──────▼───────┐
                   │  REST + OData │
                   │  SignalR      │
                   └──────┬───────┘
                          │
              ┌───────────▼───────────┐
              │   Controllers (thin)  │
              ├───────────────────────┤
              │   Services (logic)    │
              ├───────────────────────┤
              │   Repositories (data) │
              ├───────────────────────┤
              │  EF Core DbContext    │
              ├───────────────────────┤
              │     SQL Server        │
              └───────────────────────┘
```

**Backend**: N-Layer — Controllers → Services → Repositories → EF Core → SQL Server. Controllers contain no business logic; Services contain no data access code; Repositories contain only EF Core queries.

**Mobile**: Provider pattern — Screens → Providers → Repositories → Services (HTTP + JWT) → Backend API.

---

## Project Structure

```
MiniMartManagement/
├── backend/
│   ├── MiniMart.sln
│   └── MiniMart/
│       ├── Controllers/        # 19 API controllers
│       ├── Services/           # Business logic (18 services)
│       ├── Repositories/       # Data access (17 repos)
│       ├── Models/             # 26 domain entities + 16 enums
│       ├── Dtos/               # Request/response DTOs
│       ├── Mapping/            # 14 AutoMapper profiles
│       ├── Data/               # DbContext, seed data
│       ├── Middleware/         # Exception, CSRF
│       ├── Shared/             # Auth, settings, extensions
│       ├── Hubs/               # SignalR NotificationHub
│       ├── Migrations/         # 28 EF Core migration sets
│       ├── Dockerfile
│       ├── database.sql        # Standalone schema script
│       └── Program.cs
├── frontend/
│   ├── mini_mart_management_mobile_app/   # Flutter app (primary)
│   └── MiniMart/                          # WPF desktop app
├── docs/                       # Architecture, API, UML docs
└── stitch_exports/             # UI mockups
```

---

## Features

- **Inventory Management** — products, categories, suppliers, batches, stock counts
- **Point of Sale** — orders, payments, receipts, refunds
- **Employee Management** — roles, permissions, shifts, attendance
- **Promotions** — multi-condition discounts, product-level promotion rules
- **Order Returns** — return processing with inventory rollback
- **E-Invoicing / VAT** — tax rate tiers, electronic invoice generation
- **Payments** — cash, card, VnPay integration
- **Real-time Notifications** — SignalR hub for live updates
- **RBAC** — role-based access control with granular permissions (Admin, Manager, Cashier, Warehouse)
- **OData Querying** — filter, sort, paginate, expand on all list endpoints

---

## Prerequisites

- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (LocalDB, Express, Developer, or Azure SQL)
- [Flutter SDK ^3.11.5](https://docs.flutter.dev/get-started/install)
- [Visual Studio 2022](https://visualstudio.microsoft.com/) / [VS Code](https://code.visualstudio.com/) / [Rider](https://www.jetbrains.com/rider/)
- (Optional) [EF Core CLI](https://learn.microsoft.com/en-us/ef/core/cli/dotnet) — `dotnet tool install --global dotnet-ef`

---

## Quick Start — Backend

### 1. Configure connection string

Edit `backend/MiniMart/appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=.;Database=MiniMartDB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"
}
```

Replace `Server=.` with your SQL Server instance name.

### 2. Set JWT secret

In the same file, replace the `SecretKey` value with a random string **at least 32 characters long**:

```json
"Jwt": {
  "SecretKey": "YOUR_RANDOM_MIN_32_CHAR_SECRET_KEY_HERE"
}
```

### 3. Create the database

**Option A — EF Core migrations** (recommended for development):

```bash
cd backend/MiniMart
dotnet ef database update
```

**Option B — SQL script** (use if you don't have the EF CLI):

Open `backend/MiniMart/database.sql` in SSMS or run:

```bash
sqlcmd -S . -d MiniMartDB -i database.sql
```

### 4. Run the API

```bash
cd backend/MiniMart
dotnet run --launch-profile http
```

The API starts at `http://localhost:5005`. Swagger UI: `http://localhost:5005/swagger`.

### 5. Test accounts

| Username | Password | Role |
|----------|----------|------|
| `admin.test` | `Admin@123` | Admin |
| `manager.test` | `Manager@123` | Manager |

> Other seeded employees use the same password pattern. See `Data/DataSource.cs` for the full list.

---

## Quick Start — Flutter Mobile App

### 1. Install dependencies

```bash
cd frontend/mini_mart_management_mobile_app
flutter pub get
```

### 2. Configure API URL

The app auto-detects the backend URL. For Android emulator, it defaults to `http://10.0.2.2:5005` (maps to `localhost` on the host).

Override at runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:5005
```

Or edit `lib/config/api_config.dart` permanently.

### 3. Run

```bash
flutter run
```

---

## Quick Start — WPF Desktop App

```bash
cd frontend/MiniMart/MiniMart
dotnet restore
dotnet run
```

---

## API Documentation

| Resource | URL |
|----------|-----|
| **Swagger UI** | `http://localhost:5005/swagger` (dev only) |
| **OData endpoint** | `http://localhost:5005/odata/$metadata` |
| **SignalR hub** | `http://localhost:5005/hubs/notifications` |
| **Auth docs** | `docs/authentication-jwt-cookies.md` |
| **API spec** | `docs/auth-api.md` |
| **Postman collection** | `docs/MiniMart_RBAC_Tests.postman_collection.json` |

All list endpoints support OData query parameters: `$filter`, `$select`, `$expand`, `$orderby`, `$top`, `$skip`, `$count`.

---

## Deployment

### Backend — Docker

Build the image:

```bash
cd backend/MiniMart
docker build -t minimart-api .
```

Run with environment configuration:

```bash
docker run -d \
  --name minimart-api \
  -p 5005:5005 \
  --env-file .env \
  minimart-api
```

Create a `.env` file from the template in `backend/MiniMart/.env` and replace all `CHANGE_ME` values:

```bash
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__DefaultConnection=Server=YOUR_SERVER;Database=MiniMartDB;...
Jwt__SecretKey=YOUR_32_CHAR_SECRET
```

> Double-underscore (`__`) is the .NET configuration key separator for environment variables (maps to `ConnectionStrings:DefaultConnection`).

### Backend — Azure App Service

1. Publish the project:

```bash
cd backend/MiniMart
dotnet publish -c Release -o ./publish
```

2. ZIP the `publish/` folder and deploy via [Azure App Service Deploy](https://learn.microsoft.com/en-us/azure/app-service/deploy-zip).

3. Configure App Settings in Azure Portal:
   - `ConnectionStrings__DefaultConnection` → your Azure SQL connection string
   - `Jwt__SecretKey` → your secret
   - `ASPNETCORE_ENVIRONMENT` → `Production`

### Backend — IIS

1. Publish: `dotnet publish -c Release -o ./publish`
2. Create an IIS site pointing to the `publish/` folder.
3. Install the [ASP.NET Core Hosting Bundle](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/iis/hosting-bundle) on the server.
4. Configure JWT secret and connection string in `appsettings.Production.json` or as environment variables.

### Flutter — Android APK

```bash
cd frontend/mini_mart_management_mobile_app
flutter build apk --dart-define=API_BASE_URL=https://your-api.azurewebsites.net
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Flutter — iOS IPA

```bash
cd frontend/mini_mart_management_mobile_app
flutter build ios --dart-define=API_BASE_URL=https://your-api.azurewebsites.net
```

Then open the Xcode workspace and archive (Product → Archive) for App Store distribution.

---

## Authentication Overview

The system uses **dual-token cookie-based JWT authentication**:

- `access_token` — HttpOnly, Secure, SameSite=Strict, 15 min expiry
- `refresh_token` — HttpOnly, Secure, SameSite=Strict, path restricted to `/api/auth`, 7 or 30 days
- CSRF protection via double-submit cookie pattern
- Refresh token rotation with reuse detection
- Max 3 active sessions per employee
- Account lockout after 5 failed attempts (15 min duration)

See `docs/authentication-jwt-cookies.md` for the full auth system documentation.

---

## Documentation

| File | Description |
|------|-------------|
| `docs/authentication-jwt-cookies.md` | Full auth system design |
| `docs/auth-api.md` | Auth endpoint reference with examples |
| `docs/minimartdb-implementation-phases.md` | Database schema evolution |
| `docs/stock-count-implementation-plan.md` | Stock counting feature spec |
| `docs/core-flow-decision-report.md` | Architecture decisions |
| `docs/MiniMart_RBAC_Tests.postman_collection.json` | API test collection |
| `AGENTS.md` | Codebase conventions (dev reference) |
