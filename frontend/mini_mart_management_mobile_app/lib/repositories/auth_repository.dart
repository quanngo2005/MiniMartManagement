import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/auth_response.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/services/auth_service.dart';

class AuthRepository {
  const AuthRepository(this._authService);

  final AuthService _authService;

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      return await _authService.login(username: username, password: password);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Phản hồi đăng nhập không thể đọc được.');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<EmployeeUser> fetchCurrentUser() async {
    try {
      return await _authService.getCurrentUser();
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException('Phản hồi hồ sơ không thể đọc được.');
    }
  }
}
