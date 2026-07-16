import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class StockCountService {
  StockCountService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<StockCount>> fetchStockCounts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/stock-counts'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_message(json));
    }

    final items =
        json['value'] ?? json['Value'] ?? json['data'] ?? json['Data'];
    if (items is! List) {
      throw const ApiException('Không thể đọc lịch sử kiểm kê.');
    }
    return items
        .whereType<Map<String, dynamic>>()
        .map(StockCount.fromJson)
        .toList(growable: false);
  }

  Map<String, dynamic> _decode(http.Response response) {
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

  String _message(Map<String, dynamic> json) {
    final message = json['message'] ?? json['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Không thể tải lịch sử kiểm kê.';
  }
}
