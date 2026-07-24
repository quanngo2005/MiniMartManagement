import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/employee.dart';
import 'package:mini_mart_management_mobile_app/models/role.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class EmployeeService {
  EmployeeService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Employee>> getAllEmployees() async {
    final response = await _client.get(
      ApiConfig.uri('/api/employees'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    if (data is List) {
      return data.map((json) => Employee.fromJson(json)).toList();
    }

    // In case OData or envelope shape is returned
    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) {
        return value.map((json) => Employee.fromJson(json)).toList();
      }
    }

    throw const ApiException('Không thể đọc danh sách nhân viên.');
  }

  Future<Employee> createEmployee(Map<String, dynamic> data) async {
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
      ApiConfig.uri('/api/employees'),
      headers: headers,
      body: jsonEncode(data),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Employee.fromJson(responseJson);
  }

  Future<Employee> updateEmployee(int id, Map<String, dynamic> data) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };

    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.put(
      ApiConfig.uri('/api/employees/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Employee.fromJson(responseJson);
  }

  Future<void> disableEmployee(int id) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };

    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.delete(
      ApiConfig.uri('/api/employees/$id'),
      headers: headers,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final responseJson = _decodeResponse(response);
      throw ApiException(_readMessage(responseJson));
    }
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
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
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

  Future<List<Role>> getRoles() async {
    final response = await _client.get(
      ApiConfig.uri('/api/roles'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    if (data is List) {
      return data.map((json) => Role.fromJson(json)).toList();
    }

    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) {
        return value.map((json) => Role.fromJson(json)).toList();
      }
    }

    throw const ApiException('Không thể đọc danh sách vai trò.');
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, required this.cookieHeader});

  final String value;
  final String? cookieHeader;
}
