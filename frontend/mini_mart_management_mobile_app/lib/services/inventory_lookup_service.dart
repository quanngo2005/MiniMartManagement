import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/product_lookup.dart';
import 'package:mini_mart_management_mobile_app/models/supplier.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class InventoryLookupService {
  InventoryLookupService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<ProductLookup>> fetchProducts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/products'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return _readItems(responseJson)
        .map(ProductLookup.fromJson)
        .where((product) => product.status)
        .toList(growable: false);
  }

  Future<List<Supplier>> fetchSuppliers() async {
    final response = await _client.get(
      ApiConfig.uri('/api/suppliers'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return _readItems(responseJson)
        .map(Supplier.fromJson)
        .where((supplier) => supplier.status)
        .toList(growable: false);
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

  List<Map<String, dynamic>> _readItems(Map<String, dynamic> responseJson) {
    final source =
        responseJson['value'] ??
        responseJson['Value'] ??
        responseJson['data'] ??
        responseJson['Data'];

    if (source is! List<dynamic>) {
      throw const ApiException('Không thể đọc dữ liệu gợi ý.');
    }

    return source
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          throw const ApiException('Không thể đọc dữ liệu gợi ý.');
        })
        .toList(growable: false);
  }

  String _readMessage(Map<String, dynamic> responseJson) {
    final message = responseJson['message'] ?? responseJson['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Không thể tải dữ liệu gợi ý.';
  }
}
