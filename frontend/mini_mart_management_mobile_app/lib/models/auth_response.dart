import 'package:mini_mart_management_mobile_app/models/employee_user.dart';

class AuthResponse {
  const AuthResponse({
    required this.user,
    required this.accessTokenExpiresAt,
  });

  final EmployeeUser user;
  final DateTime accessTokenExpiresAt;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? json['User'];
    final expiresAt = json['accessTokenExpiresAt'] ?? json['AccessTokenExpiresAt'];

    if (userJson is! Map<String, dynamic> || expiresAt is! String) {
      throw const FormatException('Invalid auth response.');
    }

    return AuthResponse(
      user: EmployeeUser.fromJson(userJson),
      accessTokenExpiresAt: DateTime.parse(expiresAt),
    );
  }
}
