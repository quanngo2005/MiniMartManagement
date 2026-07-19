import 'package:flutter/foundation.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/repositories/auth_repository.dart';
import 'package:mini_mart_management_mobile_app/services/signalr_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  EmployeeUser? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  EmployeeUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<EmployeeUser?> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(
        username: username,
        password: password,
      );
      _currentUser = response.user;

      // Connect SignalR WebSocket connection
      await SignalrService.instance.connect();

      return _currentUser;
    } on UnauthorizedException {
      _currentUser = null;
      _errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      return null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Không thể đăng nhập. Vui lòng thử lại.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Terminate SignalR WebSocket session
    await SignalrService.instance.disconnect();
    await _authRepository.logout();
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
