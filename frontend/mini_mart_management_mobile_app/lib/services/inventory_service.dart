import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/inventory_transaction.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class InventoryService {
  InventoryService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<InventoryTransaction>> fetchTransactions() async {
    final response = await _client.get(
      ApiConfig.uri('/api/inventory'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final items = _readItems(responseJson);
    return items
        .map((item) => InventoryTransaction.fromJson(item))
        .toList(growable: false);
  }

  Object? _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Máy chủ trả về phản hồi không hợp lệ.');
    }
  }

  List<Map<String, dynamic>> _readItems(Object? responseJson) {
    final source = switch (responseJson) {
      List<dynamic> list => list,
      Map<String, dynamic> map => map['value'] ?? map['data'] ?? map['Data'],
      _ => null,
    };

    if (source is! List<dynamic>) {
      throw const ApiException('Phản hồi kho thiếu danh sách giao dịch.');
    }

    return source
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          throw const ApiException('Giao dịch kho không thể đọc được.');
        })
        .toList(growable: false);
  }

  String _readMessage(Object? responseJson) {
    if (responseJson is Map<String, dynamic>) {
      final message = responseJson['message'] ?? responseJson['Message'];
      if (message is String && message.isNotEmpty) return message;
    }

    return 'Yêu cầu kho thất bại. Vui lòng thử lại.';
  }
}
