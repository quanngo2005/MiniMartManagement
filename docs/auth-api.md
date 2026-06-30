# Auth API Documentation

Base path: `/api/auth`

Auth uses HttpOnly Secure cookies:

- `access_token`: JWT for authenticated requests, cookie path `/`.
- `refresh_token`: refresh token for token rotation, cookie path `/api/auth`.
- Tokens are not returned in JSON response bodies.

For every unsafe request (`POST`, `PUT`, `PATCH`, `DELETE`), send CSRF header:

```http
X-XSRF-TOKEN: <csrf-token>
```

Get the token from `GET /api/auth/csrf-token`. Frontend clients must also send credentials/cookies with requests.

## Response Envelope

All successful Auth APIs return:

```json
{
  "success": true,
  "message": "Success",
  "data": {}
}
```

Controller/domain/CSRF error responses use the same envelope:

```json
{
  "success": false,
  "message": "Invalid username or password.",
  "data": null
}
```

Authorization failures produced directly by `[Authorize]` can return only HTTP `401`/`403` without this JSON body because the JWT bearer challenge/forbid events are not customized.

## Common DTOs

### AuthResponse

```json
{
  "user": {
    "employeeId": 1,
    "fullName": "Nguyen Van A",
    "username": "manager.test",
    "email": "manager@example.com",
    "status": 1,
    "roleId": 2,
    "roleName": "Manager",
    "permissions": [
      "inventory.read"
    ]
  },
  "accessTokenExpiresAt": "2026-06-30T10:15:00Z"
}
```

### EmployeeUserDto

```json
{
  "employeeId": 1,
  "fullName": "Nguyen Van A",
  "username": "manager.test",
  "email": "manager@example.com",
  "status": 1,
  "roleId": 2,
  "roleName": "Manager",
  "permissions": [
    "inventory.read"
  ]
}
```

`status` values:

| Value | Meaning |
| --- | --- |
| `1` | `Active` |
| `2` | `Inactive` |
| `3` | `Resigned` |

## Endpoint Summary

| Method | Endpoint | Chuc nang | Phan quyen |
| --- | --- | --- | --- |
| `GET` | `/api/auth/csrf-token` | Lay CSRF token cho cac request unsafe | Public |
| `POST` | `/api/auth/login` | Dang nhap, set `access_token` va `refresh_token` cookies | Public + CSRF |
| `POST` | `/api/auth/refresh-token` | Rotate refresh token, cap token cookies moi | Refresh cookie + CSRF |
| `POST` | `/api/auth/logout` | Dang xuat thiet bi hien tai | AnyEmployee + CSRF |
| `POST` | `/api/auth/logout-all` | Dang xuat tat ca thiet bi | AnyEmployee + CSRF |
| `POST` | `/api/auth/register` | Tao tai khoan nhan vien | ManagerUp + CSRF |
| `POST` | `/api/auth/change-password` | Doi mat khau va revoke sessions | AnyEmployee + CSRF |
| `GET` | `/api/auth/me` | Lay thong tin user hien tai | AnyEmployee |
| `POST` | `/api/auth/toggle-active/{employeeId}?isActive={bool}` | Bat/tat trang thai active cua nhan vien | ManagerUp + CSRF |

Policies:

| Policy | Roles |
| --- | --- |
| `ManagerUp` | `Admin`, `Manager` |
| `AnyEmployee` | `Admin`, `Manager`, `Cashier`, `Warehouse`, `Staff` |

## GET /api/auth/csrf-token

Lay CSRF token. Response cung set cookie readable `XSRF-TOKEN`.

### Request Body

None.

### Response 200

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "csrfToken": "a9d4f9a2f1e64d24a0d09d6a83f1a123"
  }
}
```

## POST /api/auth/login

Dang nhap bang username/password. Neu thanh cong, server set cookies `access_token` va `refresh_token`.

### Headers

```http
Content-Type: application/json
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

```json
{
  "username": "manager.test",
  "password": "Manager@123",
  "rememberMe": true
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `username` | `string` | Yes | Ten dang nhap nhan vien |
| `password` | `string` | Yes | Mat khau |
| `rememberMe` | `boolean` | No | `true` de refresh token song lau hon |

### Response 200

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "user": {
      "employeeId": 2,
      "fullName": "Manager Test",
      "username": "manager.test",
      "email": null,
      "status": 1,
      "roleId": 2,
      "roleName": "Manager",
      "permissions": []
    },
    "accessTokenExpiresAt": "2026-06-30T10:15:00Z"
  }
}
```

### Error Responses

`400 Bad Request` when CSRF token is missing or invalid.

```json
{
  "success": false,
  "message": "Invalid CSRF token.",
  "data": null
}
```

`401 Unauthorized` when username/password is invalid or account is locked.

```json
{
  "success": false,
  "message": "Invalid username or password.",
  "data": null
}
```

`403 Forbidden` when employee or role is inactive.

```json
{
  "success": false,
  "message": "Account is inactive.",
  "data": null
}
```

## POST /api/auth/refresh-token

Cap lai token pair bang `refresh_token` cookie. Refresh token la single-use; token cu se bi revoke.

### Headers

```http
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

None. Backend reads `refresh_token` from cookie.

### Response 200

```json
{
  "success": true,
  "message": "Token refreshed.",
  "data": {
    "user": {
      "employeeId": 2,
      "fullName": "Manager Test",
      "username": "manager.test",
      "email": null,
      "status": 1,
      "roleId": 2,
      "roleName": "Manager",
      "permissions": []
    },
    "accessTokenExpiresAt": "2026-06-30T10:30:00Z"
  }
}
```

### Error Responses

`401 Unauthorized` when refresh cookie is missing, invalid, expired, revoked, or reused.

```json
{
  "success": false,
  "message": "Refresh token is missing.",
  "data": null
}
```

Other possible messages include:

- `Invalid refresh token.`
- `Refresh token expired.`
- `Refresh token reuse detected.`

## POST /api/auth/logout

Dang xuat thiet bi hien tai. Backend revoke current refresh token neu co va xoa auth cookies.

### Headers

```http
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

None.

### Response 200

```json
{
  "success": true,
  "message": "Logout successful.",
  "data": null
}
```

### Error Responses

`401 Unauthorized` when `access_token` is missing or expired.

`403 Forbidden` when user does not satisfy `AnyEmployee`.

## POST /api/auth/logout-all

Dang xuat tat ca thiet bi cua nhan vien hien tai. Backend revoke all refresh tokens cua employee va xoa auth cookies hien tai.

### Headers

```http
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

None.

### Response 200

```json
{
  "success": true,
  "message": "Logged out from all devices.",
  "data": null
}
```

## POST /api/auth/register

Tao tai khoan nhan vien moi. Chi `Admin` va `Manager` duoc goi.

### Headers

```http
Content-Type: application/json
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

```json
{
  "fullName": "Nguyen Van A",
  "gender": true,
  "dateOfBirth": "1995-04-20T00:00:00Z",
  "phoneNumber": "0901234567",
  "email": "nguyenvana@example.com",
  "address": "123 Nguyen Trai, Quan 1, TP.HCM",
  "username": "nguyenvana",
  "password": "Password@123",
  "salary": 12000000,
  "hireDate": "2026-06-30T00:00:00Z",
  "avatar": "https://example.com/avatar.png",
  "roleId": 3
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `fullName` | `string` | Yes | Ho ten nhan vien |
| `gender` | `boolean` | Yes | Gioi tinh theo quy uoc backend |
| `dateOfBirth` | `datetime` | Yes | Ngay sinh |
| `phoneNumber` | `string` | Yes | So dien thoai, phai unique |
| `email` | `string?` | No | Email |
| `address` | `string?` | No | Dia chi |
| `username` | `string` | Yes | Ten dang nhap, phai unique |
| `password` | `string` | Yes | Mat khau raw, backend hash PBKDF2 |
| `salary` | `decimal` | Yes | Luong |
| `hireDate` | `datetime` | Yes | Ngay vao lam |
| `avatar` | `string?` | No | URL/path avatar |
| `roleId` | `integer` | Yes | Role dang active |

### Response 200

```json
{
  "success": true,
  "message": "Employee registered.",
  "data": {
    "user": {
      "employeeId": 10,
      "fullName": "Nguyen Van A",
      "username": "nguyenvana",
      "email": "nguyenvana@example.com",
      "status": 1,
      "roleId": 3,
      "roleName": "Cashier",
      "permissions": []
    },
    "accessTokenExpiresAt": "2026-06-30T09:00:00Z"
  }
}
```

Note: Register returns user info but does not set login cookies for the created employee.

### Error Responses

`400 Bad Request` for domain validation failures.

```json
{
  "success": false,
  "message": "Username already exists.",
  "data": null
}
```

Other possible messages:

- `Phone number already exists.`
- `Role is invalid or inactive.`

`401 Unauthorized` if caller is not logged in.

`403 Forbidden` if caller is not `Admin` or `Manager`.

## POST /api/auth/change-password

Doi mat khau cua nhan vien hien tai. Sau khi doi thanh cong, backend revoke all sessions va xoa cookies hien tai; user can dang nhap lai.

### Headers

```http
Content-Type: application/json
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

```json
{
  "currentPassword": "OldPassword@123",
  "newPassword": "NewPassword@123"
}
```

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `currentPassword` | `string` | Yes | Mat khau hien tai |
| `newPassword` | `string` | Yes | Mat khau moi |

### Response 200

```json
{
  "success": true,
  "message": "Password changed. Please login again.",
  "data": null
}
```

### Error Responses

`401 Unauthorized` when current password is wrong or caller is not authenticated.

```json
{
  "success": false,
  "message": "Current password is incorrect.",
  "data": null
}
```

## GET /api/auth/me

Lay thong tin employee hien tai tu `access_token`.

### Request Body

None.

### Response 200

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "employeeId": 2,
    "fullName": "Manager Test",
    "username": "manager.test",
    "email": null,
    "status": 1,
    "roleId": 2,
    "roleName": "Manager",
    "permissions": []
  }
}
```

### Error Responses

`401 Unauthorized` when `access_token` is missing, expired, or invalid.

## POST /api/auth/toggle-active/{employeeId}?isActive={bool}

Cap nhat trang thai active/inactive cua nhan vien. Neu set inactive, backend revoke all refresh tokens cua nhan vien do.

### Path Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `employeeId` | `integer` | Yes | ID cua employee can cap nhat |

### Query Parameters

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `isActive` | `boolean` | Yes | `true` = Active, `false` = Inactive |

### Headers

```http
X-XSRF-TOKEN: <csrf-token>
```

### Request Body

None.

### Example Request

```http
POST /api/auth/toggle-active/10?isActive=false
X-XSRF-TOKEN: <csrf-token>
```

### Response 200

```json
{
  "success": true,
  "message": "Employee status updated.",
  "data": {
    "employeeId": 10,
    "fullName": "Nguyen Van A",
    "username": "nguyenvana",
    "email": "nguyenvana@example.com",
    "status": 2,
    "roleId": 3,
    "roleName": "Cashier",
    "permissions": []
  }
}
```

### Error Responses

`404 Not Found` when employee does not exist.

```json
{
  "success": false,
  "message": "Employee not found.",
  "data": null
}
```

`401 Unauthorized` if caller is not logged in.

`403 Forbidden` if caller is not `Admin` or `Manager`.
