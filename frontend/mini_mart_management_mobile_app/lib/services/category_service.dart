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
    final decoded = response.body.isEmpty ? [] : jsonDecode(response.body);
    final data = decoded is List ? decoded : (decoded['data'] ?? decoded['Data'] ?? []);
    return (data as List).whereType<Map<String, dynamic>>().map(Category.fromJson).toList();
  }

  Future<Category> create(Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final response = await _client.post(
      ApiConfig.uri('/api/categories'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-XSRF-TOKEN': csrf,
      },
      body: jsonEncode(data),
    );
    final json = _decodeMap(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Tạo danh mục thất bại.',
      );
    }
    return Category.fromJson(json);
  }

  Future<Category> update(int id, Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final response = await _client.put(
      ApiConfig.uri('/api/categories/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-XSRF-TOKEN': csrf,
      },
      body: jsonEncode(data),
    );
    final json = _decodeMap(response.body);
    if (response.statusCode >= 400) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Cập nhật danh mục thất bại.',
      );
    }
    return Category.fromJson(json);
  }

  Future<void> delete(int id) async {
    final csrf = await _fetchCsrf();
    final response = await _client.delete(
      ApiConfig.uri('/api/categories/$id'),
      headers: {
        'Accept': 'application/json',
        'X-XSRF-TOKEN': csrf,
      },
    );
    if (response.statusCode != 204) {
      final json = _decodeMap(response.body);
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Xóa danh mục thất bại.',
      );
    }
  }

  Future<String> _fetchCsrf() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Không thể lấy CSRF token.',
      );
    }
    final data = json['data'] ?? json['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('CSRF response is missing token data.');
    }
    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('CSRF token is missing.');
    }
    return token;
  }

  Map<String, dynamic> _decodeMap(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is List) return {'value': decoded};
    return <String, dynamic>{};
  }
}
