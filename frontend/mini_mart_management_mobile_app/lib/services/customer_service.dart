import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/customer_order.dart';
import 'package:mini_mart_management_mobile_app/models/customer_point_transaction.dart';
import 'package:mini_mart_management_mobile_app/models/customer_summary.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class CustomerService {
  CustomerService({http.Client? client})
      : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<CustomerSummary>> getAllCustomers() async {
    final response = await _client.get(
      ApiConfig.uri('/api/customers'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('[${response.statusCode}] ${_readMessage(responseJson)}');
    }

    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    if (data is List) {
      return data.map((j) => CustomerSummary.fromJson(j)).toList();
    }
    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) {
        return value.map((j) => CustomerSummary.fromJson(j)).toList();
      }
    }
    throw ApiException('[${response.statusCode}] Không thể parse response: ${response.body.substring(0, response.body.length.clamp(0, 200))}');
  }

  Future<CustomerSummary> getCustomerById(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/customers/$id'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
    return CustomerSummary.fromJson(responseJson);
  }

  Future<CustomerSummary> createCustomer(Map<String, dynamic> data) async {
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
      ApiConfig.uri('/api/customers'),
      headers: headers,
      body: jsonEncode(data),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
    return CustomerSummary.fromJson(responseJson);
  }

  Future<CustomerSummary> updateCustomer(
      int id, Map<String, dynamic> data) async {
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
      ApiConfig.uri('/api/customers/$id'),
      headers: headers,
      body: jsonEncode(data),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
    return CustomerSummary.fromJson(responseJson);
  }

  Future<void> deleteCustomer(int id) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.delete(
      ApiConfig.uri('/api/customers/$id'),
      headers: headers,
    );

    if (response.statusCode != 204) {
      final responseJson = _decodeResponse(response);
      throw ApiException(_readMessage(responseJson));
    }
  }

  Future<List<CustomerOrder>> getCustomerOrders(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/customers/$id/orders'),
      headers: const {'Accept': 'application/json'},
    );
    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('[${response.statusCode}] ${_readMessage(responseJson)}');
    }
    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    final list = data is List ? data : (data is Map ? data['value'] ?? [] : []);
    return (list as List).map((j) => CustomerOrder.fromJson(j)).toList();
  }

  Future<List<CustomerPointTransaction>> getCustomerPointTransactions(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/customers/$id/point-transactions'),
      headers: const {'Accept': 'application/json'},
    );
    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('[${response.statusCode}] ${_readMessage(responseJson)}');
    }
    final data = responseJson['data'] ?? responseJson['Data'] ?? responseJson;
    final list = data is List ? data : (data is Map ? data['value'] ?? [] : []);
    return (list as List).map((j) => CustomerPointTransaction.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> getCustomerPoints(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/customers/$id/points'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
    return responseJson;
  }

  Future<Map<String, dynamic>> updateCustomerPoints(
      int id, int delta) async {
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
      ApiConfig.uri('/api/customers/$id/points'),
      headers: headers,
      body: jsonEncode({'delta': delta}),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
    return responseJson;
  }

  // ── Helpers ──────────────────────────────────────────────────────

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
      // body không phải JSON (HTML error page, etc.)
      return {'message': 'Server error (${response.statusCode})'};
    }
    return {'message': 'Unexpected response format'};
  }

  String _readMessage(Map<String, dynamic> json) {
    final message = json['message'] ?? json['Message']
        ?? json['title'] ?? json['Title'];
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
