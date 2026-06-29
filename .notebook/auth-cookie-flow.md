# Cookie authentication flow

MiniMart auth is integrated into the existing `backend/MiniMart` project and uses `Employee` plus `Role` as the account and authorization source.

Key pointers:

- `backend/MiniMart/Controllers/AuthController.cs` exposes `/api/auth/csrf-token`, login, refresh-token, logout, logout-all, register, change-password, me, and toggle-active.
- `backend/MiniMart/Services/AuthService.cs` handles PBKDF2 password hashing, login lockout, refresh-token rotation, reuse detection, logout-all, and the 3-device limit.
- `backend/MiniMart/Services/JwtService.cs` creates access tokens and hashes refresh tokens before storage.
- `backend/MiniMart/Middleware/CsrfMiddleware.cs` requires the `X-XSRF-TOKEN` header to match the readable `XSRF-TOKEN` cookie for unsafe HTTP methods.
- `backend/MiniMart/Extensions/ServiceExtensions.cs` configures JWT Bearer to read `access_token` from an HttpOnly cookie when no bearer header is present.
- `backend/MiniMart/Migrations/20260624170027_AddCookieAuthentication.cs` adds auth columns, `RefreshTokens`, and safe role seed SQL.

Operational notes:

- Frontend must call `GET /api/auth/csrf-token` first, then send `X-XSRF-TOKEN` on `POST`, `PUT`, `PATCH`, and `DELETE`.
- Replace `Jwt:SecretKey` in appsettings before production.
- Existing employees must have PBKDF2-formatted `PasswordHash` values before they can log in with this service.
