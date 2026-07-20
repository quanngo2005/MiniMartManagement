import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/supplier_debt_tracking.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class SupplierDebtService {
  SupplierDebtService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<SupplierDebtSummary>> getDebtSummaries() async {
    final response = await _client.get(
      ApiConfig.uri('/api/suppliers/debts'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);

    final data = json['data'] ?? json['Data'] ?? json['value'] ?? json['Value'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(SupplierDebtSummary.fromJson)
        .toList(growable: false);
  }

  Future<SupplierDebtDetail> getDebtDetail(int supplierId) async {
    final response = await _client.get(
      ApiConfig.uri('/api/suppliers/$supplierId/debt'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    return SupplierDebtDetail.fromJson(json);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
    } on FormatException {
      throw const ApiException('Server trả về phản hồi không hợp lệ.');
    }
    throw const ApiException('Server trả về phản hồi không mong đợi.');
  }

  void _checkStatus(http.Response response, Map<String, dynamic> json) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = json['message'] ?? json['Message'];
      throw ApiException(
        message is String && message.isNotEmpty
            ? message
            : 'Không thể tải công nợ nhà cung cấp.',
      );
    }
  }
}
