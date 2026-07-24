import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/category.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class CategoryService {
  CategoryService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Category>> getAll() async {
    final response = await _client.get(
      ApiConfig.uri('/api/categories'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    if (data is List) return data.map((e) => Category.fromJson(e)).toList();
    throw const ApiException('Không thể đọc danh sách danh mục.');
  }

  Future<Category> create(Map<String, dynamic> body) async {
    final csrf = await _csrf();
    final response = await _client.post(
      ApiConfig.uri('/api/categories'),
      headers: _headers(csrf),
      body: jsonEncode(body),
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<Category> update(int id, Map<String, dynamic> body) async {
    final csrf = await _csrf();
    final response = await _client.put(
      ApiConfig.uri('/api/categories/$id'),
      headers: _headers(csrf),
      body: jsonEncode(body),
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final csrf = await _csrf();
    final response = await _client.delete(
      ApiConfig.uri('/api/categories/$id'),
      headers: _headers(csrf),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _checkStatus(response, _decode(response));
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<_CsrfToken> _csrf() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi CSRF thiếu dữ liệu token.');
    }
    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Thiếu token CSRF.');
    }
    final cookieToken = RegExp(
      r'XSRF-TOKEN=([^;,\s]+)',
    ).firstMatch(response.headers['set-cookie'] ?? '')?.group(1);
    return _CsrfToken(
      value: token,
      cookieHeader: cookieToken == null ? null : 'XSRF-TOKEN=$cookieToken',
    );
  }

  Map<String, String> _headers(_CsrfToken csrf) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrf.value,
    };
    if (csrf.cookieHeader != null) h['Cookie'] = csrf.cookieHeader!;
    return h;
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
    } on FormatException {
      throw const ApiException('Server trả về response không hợp lệ.');
    }
    throw const ApiException('Server trả về response không mong đợi.');
  }

  void _checkStatus(http.Response response, Map<String, dynamic> json) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = json['message'] ?? json['Message'];
      throw ApiException(
        msg is String && msg.isNotEmpty ? msg : 'Yêu cầu thất bại.',
      );
    }
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, required this.cookieHeader});
  final String value;
  final String? cookieHeader;
}
