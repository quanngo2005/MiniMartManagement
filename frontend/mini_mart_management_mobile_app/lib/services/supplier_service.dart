import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class SupplierService {
  SupplierService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Supplier>> getAllSuppliers() async {
    final response = await _client.get(
      ApiConfig.uri('/api/suppliers'),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Lỗi ${response.statusCode}: ${_message(json)}');
    }

    final data = json['value'] ?? json['data'] ?? json['Data'] ?? json;
    if (data is List) return data.map((e) => Supplier.fromJson(e)).toList();
    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) return value.map((e) => Supplier.fromJson(e)).toList();
    }
    throw const ApiException('Không thể đọc danh sách nhà cung cấp.');
  }

  Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final response = await _client.post(
      ApiConfig.uri('/api/suppliers'),
      headers: _headers(csrf),
      body: jsonEncode(data),
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return Supplier.fromJson(json);
  }

  Future<Supplier> updateSupplier(int id, Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final response = await _client.put(
      ApiConfig.uri('/api/suppliers/$id'),
      headers: _headers(csrf),
      body: jsonEncode(data),
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return Supplier.fromJson(json);
  }

  Future<void> deleteSupplier(int id) async {
    final csrf = await _fetchCsrf();
    final response = await _client.delete(
      ApiConfig.uri('/api/suppliers/$id'),
      headers: _headers(csrf),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final json = _decode(response);
      throw ApiException(_message(json));
    }
  }

  // ── helpers ─────────────────────────────────────────────────────

  Map<String, String> _headers(_CsrfToken csrf) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrf.value,
    };
    if (csrf.cookieHeader != null) h['Cookie'] = csrf.cookieHeader!;
    return h;
  }

  Future<_CsrfToken> _fetchCsrf() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    final data = json['data'] ?? json['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('CSRF response is missing token data.');
    }
    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('CSRF token is missing.');
    }
    final cookieVal = _parseCookie(response.headers['set-cookie']);
    return _CsrfToken(
      value: token,
      cookieHeader: cookieVal == null ? null : 'XSRF-TOKEN=$cookieVal',
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'value': decoded};
    } on FormatException {
      throw const ApiException('Server trả về phản hồi không hợp lệ.');
    }
    throw const ApiException('Server trả về phản hồi không mong đợi.');
  }

  String _message(Map<String, dynamic> json) {
    final m = json['message'] ?? json['Message'];
    return m is String && m.isNotEmpty
        ? m
        : 'Yêu cầu thất bại. Vui lòng thử lại.';
  }

  String? _parseCookie(String? header) {
    if (header == null || header.isEmpty) return null;
    return RegExp(r'XSRF-TOKEN=([^;,\s]+)').firstMatch(header)?.group(1);
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, this.cookieHeader});
  final String value;
  final String? cookieHeader;
}
