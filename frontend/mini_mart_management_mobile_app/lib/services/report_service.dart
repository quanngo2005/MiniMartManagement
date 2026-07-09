import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class ReportService {
  ReportService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<TopProduct>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int top = 10,
  }) async {
    final queryParams = <String, String>{'top': top.toString()};
    if (startDate != null) {
      // Gửi dạng date-only để tránh timezone mismatch với backend
      queryParams['startDate'] =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    }
    if (endDate != null) {
      queryParams['endDate'] =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    }

    final uri = ApiConfig.uri('/api/reports/top-products')
        .replace(queryParameters: queryParams);

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    debugPrint('[ReportService] status=${response.statusCode} body=${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    // Parse list từ response
    List<dynamic> rawList;
    final body = responseJson['data'] ?? responseJson['Data'];
    if (body is List) {
      rawList = body;
    } else if (responseJson.containsKey('value')) {
      final v = responseJson['value'];
      rawList = v is List ? v : [];
    } else {
      // responseJson chính là wrapped list {'data': [...]}
      // hoặc là Map với các key khác — thử lấy first list value
      final firstList = responseJson.values.whereType<List>().firstOrNull;
      rawList = firstList ?? [];
    }

    final result = rawList
        .whereType<Map<String, dynamic>>()
        .map(TopProduct.fromJson)
        .toList();
    debugPrint('[ReportService] rawList.length=${rawList.length} parsed=${result.length}');
    return result;
  }

  // ── Helpers ──────────────────────────────────────────────────────

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

  String _readMessage(Map<String, dynamic> json) {
    final message = json['message'] ?? json['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Yêu cầu thất bại. Vui lòng thử lại.';
  }
}
