import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/cashier_performance.dart';
import 'package:mini_mart_management_mobile_app/models/top_product.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class ReportService {
  ReportService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<CashierPerformance>> getCashierPerformance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String, String>{};
    if (startDate != null) {
      params['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate.toIso8601String();
    }

    final response = await _client.get(
      ApiConfig.uri(
        '/api/reports/cashier-performance',
      ).replace(queryParameters: params),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    return _list(json)
        .whereType<Map<String, dynamic>>()
        .map(CashierPerformance.fromJson)
        .toList();
  }

  Future<List<TopProduct>> getTopProducts({
    DateTime? startDate,
    DateTime? endDate,
    int top = 10,
  }) async {
    final params = <String, String>{'top': top.toString()};
    if (startDate != null) params['startDate'] = startDate.toIso8601String();
    if (endDate != null) params['endDate'] = endDate.toIso8601String();

    final response = await _client.get(
      ApiConfig.uri(
        '/api/reports/top-products',
      ).replace(queryParameters: params),
      headers: const {'Accept': 'application/json'},
    );

    if (response.body.isEmpty) return [];
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(TopProduct.fromJson)
            .toList();
      }
      if (decoded is Map<String, dynamic>) {
        final raw =
            decoded['data'] ??
            decoded['Data'] ??
            decoded['value'] ??
            decoded['Value'];
        if (raw is List) {
          return raw
              .whereType<Map<String, dynamic>>()
              .map(TopProduct.fromJson)
              .toList();
        }
      }
    } on FormatException {
      throw const ApiException('Server trả về dữ liệu không hợp lệ.');
    }
    if (response.statusCode >= 400) {
      throw const ApiException('Không thể tải hiệu suất sản phẩm.');
    }
    return [];
  }

  Future<List<dynamic>> getDailyRevenue(int month, int year) async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/revenue/daily').replace(
        queryParameters: {'month': month.toString(), 'year': year.toString()},
      ),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    return _list(json);
  }

  Future<List<dynamic>> getHourlyRevenue(DateTime date) async {
    final response = await _client.get(
      ApiConfig.uri(
        '/api/reports/revenue/hourly',
      ).replace(queryParameters: {'date': date.toIso8601String()}),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    return _list(json);
  }

  Future<List<dynamic>> getLowStockAlerts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/inventory'),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    final all = _list(json);
    return all.where((item) {
      if (item is Map<String, dynamic>) {
        final current =
            (item['currentStock'] ?? item['CurrentStock'] ?? 0) as num;
        final minimum =
            (item['minimumStock'] ?? item['MinimumStock'] ?? 0) as num;
        return current <= minimum;
      }
      return false;
    }).toList();
  }

  Future<List<dynamic>> getSupplierDebt() async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/supplier-debt'),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    return _list(json);
  }

  Future<Map<String, dynamic>> getMonthlyFinancialReport(
    int month,
    int year,
  ) async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/financial/monthly').replace(
        queryParameters: {'month': month.toString(), 'year': year.toString()},
      ),
      headers: const {'Accept': 'application/json'},
    );

    final json = _decode(response);
    _checkStatus(response, json);
    return json;
  }

  Map<String, dynamic> _decode(http.Response r) {
    if (r.body.isEmpty) return {};
    try {
      final d = jsonDecode(r.body);
      if (d is Map<String, dynamic>) return d;
      if (d is List) return {'data': d};
    } on FormatException {
      throw const ApiException('Server trả về dữ liệu không hợp lệ.');
    }
    throw const ApiException('Server trả về phản hồi không mong đợi.');
  }

  void _checkStatus(http.Response r, Map<String, dynamic> json) {
    if (r.statusCode < 200 || r.statusCode >= 300) {
      final m = json['message'] ?? json['Message'];
      throw ApiException(m is String && m.isNotEmpty ? m : 'Yêu cầu thất bại.');
    }
  }

  List<dynamic> _list(Map<String, dynamic> json) {
    final src = json['data'] ?? json['Data'] ?? json['value'] ?? json['Value'];
    if (src is List) return src;
    return [];
  }
}
