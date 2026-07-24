import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/auth_response.dart';
import 'package:mini_mart_management_mobile_app/models/employee_user.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class AuthService {
  AuthService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<void> logout() async {
    try {
      final csrfToken = await _fetchCsrfToken();
      final headers = <String, String>{
        'Accept': 'application/json',
        'X-XSRF-TOKEN': csrfToken.value,
      };
      if (csrfToken.cookieHeader != null) {
        headers['Cookie'] = csrfToken.cookieHeader!;
      }
      await _client.post(ApiConfig.uri('/api/auth/logout'), headers: headers);
    } catch (_) {
    } finally {
      clearClientCookies();
    }
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };

    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.post(
      ApiConfig.uri('/api/auth/login'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        'rememberMe': rememberMe,
      }),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi đăng nhập thiếu dữ liệu người dùng.');
    }

    return AuthResponse.fromJson(data);
  }

  Future<EmployeeUser> getCurrentUser() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/me'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi hồ sơ thiếu dữ liệu người dùng.');
    }

    return EmployeeUser.fromJson(data);
  }

  Future<_CsrfToken> _fetchCsrfToken() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi CSRF thiếu dữ liệu token.');
    }

    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Thiếu token CSRF.');
    }

    final cookieToken = _readCookieToken(response.headers['set-cookie']);
    return _CsrfToken(
      value: token,
      cookieHeader: cookieToken == null ? null : 'XSRF-TOKEN=$cookieToken',
    );
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      throw const ApiException('Máy chủ trả về phản hồi không hợp lệ.');
    }

    throw const ApiException('Máy chủ trả về phản hồi không mong đợi.');
  }

  String _readMessage(Map<String, dynamic> responseJson) {
    final message = responseJson['message'] ?? responseJson['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Yêu cầu thất bại. Vui lòng thử lại.';
  }

  String? _readCookieToken(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return null;

    final match = RegExp(r'XSRF-TOKEN=([^;,\s]+)').firstMatch(setCookieHeader);
    return match?.group(1);
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, required this.cookieHeader});

  final String value;
  final String? cookieHeader;
}
