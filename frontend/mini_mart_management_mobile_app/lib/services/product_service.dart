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
    final response = await _client.get(
      ApiConfig.uri('/api/products'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return _items(json).map(Product.fromJson).toList();
  }

  Future<Product> getById(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/products/$id'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return Product.fromJson(json);
  }

  Future<Product> create(Map<String, dynamic> data) async {
    final response = await _client.post(
      ApiConfig.uri('/api/products'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return Product.fromJson(json);
  }

  Future<Product> update(int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      ApiConfig.uri('/api/products/$id'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }
    return Product.fromJson(json);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Map<String, dynamic> _decode(http.Response r) {
    if (r.body.isEmpty) return {};
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
      if (d is List) return {'value': d};
    } on FormatException {
      throw const ApiException('Server trả về dữ liệu không hợp lệ.');
    }
    throw const ApiException('Server trả về phản hồi không mong đợi.');
  }

  List<Map<String, dynamic>> _items(Map<String, dynamic> json) {
    final src =
        json['value'] ??
        json['Value'] ??
        json['data'] ??
        json['Data'];
    if (src is List) {
      return src.whereType<Map<String, dynamic>>().toList();
    }
    // single object response
    return [json];
  }

  String _message(Map<String, dynamic> json) {
    final m = json['message'] ?? json['Message'];
    return m is String && m.isNotEmpty ? m : 'Đã xảy ra lỗi.';
  }
}
