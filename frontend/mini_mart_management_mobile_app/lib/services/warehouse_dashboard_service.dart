import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/warehouse_dashboard.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class WarehouseDashboardService {
  WarehouseDashboardService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<InventoryStatus>> getInventoryReport() async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/inventory'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    if (data is List) {
      return data.map((e) => InventoryStatus.fromJson(e)).toList();
    }
    throw const ApiException('Không thể đọc báo cáo tồn kho.');
  }

  Future<List<InventoryStatus>> getLowStockAlerts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/reports/inventory/low-stock'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    if (data is List) {
      return data.map((e) => InventoryStatus.fromJson(e)).toList();
    }
    throw const ApiException('Không thể đọc cảnh báo tồn kho thấp.');
  }

  Future<List<NearExpiryProduct>> getNearExpiryProducts({int days = 30}) async {
    final response = await _client.get(
      ApiConfig.uri('/api/products/near-expirationdate?days=$days'),
      headers: const {'Accept': 'application/json'},
    );
    final json = _decode(response);
    _checkStatus(response, json);
    final data = json['data'] ?? json['Data'] ?? json;
    if (data is List) {
      return data.map((e) => NearExpiryProduct.fromJson(e)).toList();
    }
    if (data is Map<String, dynamic>) {
      final value = data['value'] ?? data['Value'];
      if (value is List) {
        return value.map((e) => NearExpiryProduct.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<List<RecentBatch>> getRecentBatches() async {
    final today = DateTime.now();
    final from = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 7));
    final response = await _client.get(
      ApiConfig.uri(
        '/odata/Batches?\$filter=ImportDate ge ${from.toIso8601String()}&\$orderby=ImportDate desc&\$top=10',
      ),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) return [];
    try {
      final decoded = jsonDecode(response.body);
      final value = decoded is Map ? (decoded['value'] ?? decoded) : decoded;
      if (value is List) {
        return value.map((e) => RecentBatch.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
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
