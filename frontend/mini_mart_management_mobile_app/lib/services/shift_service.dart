import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/shift.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class ShiftService {
  ShiftService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Shift>> getAllShifts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/shifts'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    if (data is List) {
      return data.map((json) => Shift.fromJson(json)).toList();
    }

    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) {
        return value.map((json) => Shift.fromJson(json)).toList();
      }
    }

    throw const ApiException('Không thể đọc danh sách ca làm việc.');
  }

  Future<Shift> createShift(Map<String, dynamic> data) async {
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
      ApiConfig.uri('/api/shifts'),
      headers: headers,
      body: jsonEncode(data),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Shift.fromJson(responseJson);
  }

  Future<Shift?> getCurrentShift() async {
    final response = await _client.get(
      ApiConfig.uri('/api/shifts/current'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode == 404) {
      return null;
    }

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Shift.fromJson(responseJson);
  }

  Future<Shift> openShift({
    required int shiftId,
    required int cashierId,
    required double startCash,
    String? note,
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

    final body = {
      'shiftId': shiftId,
      'cashierId': cashierId,
      'startCash': startCash,
      'note': note,
    };

    final response = await _client.post(
      ApiConfig.uri('/api/shifts/open'),
      headers: headers,
      body: jsonEncode(body),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Shift.fromJson(responseJson);
  }

  Future<Shift> closeShift({
    required int shiftId,
    required double endCash,
    String? note,
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

    final body = {'endCash': endCash, 'note': note};

    final response = await _client.post(
      ApiConfig.uri('/api/shifts/$shiftId/close'),
      headers: headers,
      body: jsonEncode(body),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Shift.fromJson(responseJson);
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
      throw const ApiException('CSRF response is missing token data.');
    }

    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('CSRF token is missing.');
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
      throw const ApiException('Server returned an invalid response.');
    }
    throw const ApiException('Server returned an unexpected response.');
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
