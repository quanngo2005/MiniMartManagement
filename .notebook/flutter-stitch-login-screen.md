# Flutter Stitch login screen

## Context

- Flutter frontend app lives at `frontend/mini_mart_management_mobile_app`.
- Stitch project `Inventory Notification System` screen `Đăng nhập` is implemented in `frontend/mini_mart_management_mobile_app/lib/features/auth/login_screen.dart`.
- Login widgets are split under `frontend/mini_mart_management_mobile_app/lib/features/auth/components`.
- Downloaded Stitch references are stored at:
  - `frontend/stitch_assets/dang_nhap.html`

## Verification notes

- The `dart.bat` / `flutter.bat` wrappers can hang silently in the sandbox when run without escalation.
- Direct Dart executable works for analysis when escalated:
  - `D:\Apps\flutter\bin\cache\dart-sdk\bin\dart.exe analyze`
- `flutter build web --no-pub` completed successfully under escalation.
