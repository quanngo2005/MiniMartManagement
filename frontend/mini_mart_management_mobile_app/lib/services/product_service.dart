import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class ProductService {
  ProductService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Product>> getAll() async {
    final r = await _client.get(
      ApiConfig.uri('/api/products'),
      headers: const {'Accept': 'application/json'},
    );
    if (r.body.isEmpty) return [];
    final decoded = jsonDecode(r.body);
    List<dynamic> list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final v =
          decoded['value'] ??
          decoded['Value'] ??
          decoded['data'] ??
          decoded['Data'];
      list = v is List ? v : [];
    } else {
      return [];
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<Product> create(Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final r = await _client.post(
      ApiConfig.uri('/api/products'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-XSRF-TOKEN': csrf,
      },
      body: jsonEncode(data),
    );
    final json = _decodeMap(r.body);
    if (r.statusCode >= 400) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Lỗi tạo sản phẩm.',
      );
    }
    return Product.fromJson(json);
  }

  Future<Product> update(int id, Map<String, dynamic> data) async {
    final csrf = await _fetchCsrf();
    final r = await _client.put(
      ApiConfig.uri('/api/products/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-XSRF-TOKEN': csrf,
      },
      body: jsonEncode(data),
    );
    final json = _decodeMap(r.body);
    if (r.statusCode >= 400) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Lỗi cập nhật sản phẩm.',
      );
    }
    return Product.fromJson(json);
  }

  Future<String> _fetchCsrf() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decodeMap(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        json['message'] ?? json['Message'] ?? 'Không thể lấy token CSRF.',
      );
    }
    final data = json['data'] ?? json['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi CSRF thiếu dữ liệu token.');
    }
    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Thiếu token CSRF.');
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
