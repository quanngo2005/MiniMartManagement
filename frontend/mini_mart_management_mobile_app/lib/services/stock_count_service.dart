import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/stock_count.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class StockCountService {
  StockCountService({http.Client? client}) : _client = client ?? createConfiguredClient();
  final http.Client _client;
  Future<List<StockCount>> fetchStockCounts() async { final json = await _request('GET', '/api/stock-counts'); final items = json['value'] ?? json['Value'] ?? json['data'] ?? json['Data']; if (items is! List) throw const ApiException('Không thể đọc lịch sử kiểm kê.'); return items.whereType<Map<String, dynamic>>().map(StockCount.fromJson).toList(growable: false); }
  Future<StockCount> getDetail(int id) async => StockCount.fromJson(await _request('GET', '/api/stock-counts/$id'));
  Future<StockCount> create(StockCountScope scope) async => StockCount.fromJson(await _request('POST', '/api/stock-counts', body: {'scope': scope.apiValue, 'categoryIds': const <int>[] }));
  Future<StockCount> start(StockCount count) async => _transition('PUT', '/api/stock-counts/${count.stockCountId}/start', count.rowVersion);
  Future<StockCount> submit(StockCount count) async => _transition('PUT', '/api/stock-counts/${count.stockCountId}/submit', count.rowVersion);
  Future<StockCount> approve(StockCount count) async => _transition('POST', '/api/stock-counts/${count.stockCountId}/approve', count.rowVersion);
  Future<StockCount> reject(StockCount count, String reason) async => StockCount.fromJson(await _request('POST', '/api/stock-counts/${count.stockCountId}/reject', body: {'rowVersion': count.rowVersion, 'reason': reason}));
  Future<StockCount> updateLines(StockCount count, List<StockCountLine> lines) async => StockCount.fromJson(await _request('PUT', '/api/stock-counts/${count.stockCountId}/lines', body: {'stockCountRowVersion': count.rowVersion, 'lines': lines.map((line) => {'stockCountLineId': line.stockCountLineId, 'actualQuantity': line.actualQuantity, 'note': line.note, 'rowVersion': line.rowVersion}).toList()}));
  Future<StockCount> _transition(String method, String path, String rowVersion) async => StockCount.fromJson(await _request(method, path, body: {'rowVersion': rowVersion}));
  Future<Map<String, dynamic>> _request(String method, String path, {Object? body}) async { final headers = {'Accept': 'application/json', if (body != null) 'Content-Type': 'application/json'}; final uri = ApiConfig.uri(path); final response = switch (method) { 'GET' => await _client.get(uri, headers: headers), 'POST' => await _client.post(uri, headers: headers, body: body == null ? null : jsonEncode(body)), 'PUT' => await _client.put(uri, headers: headers, body: body == null ? null : jsonEncode(body)), _ => throw UnsupportedError(method) }; final json = _decode(response); if (response.statusCode < 200 || response.statusCode >= 300) throw ApiException(_message(json)); return json; }
  Map<String, dynamic> _decode(http.Response response) { if (response.body.isEmpty) return {}; final decoded = jsonDecode(response.body); if (decoded is Map<String, dynamic>) return decoded; if (decoded is List) return {'data': decoded}; throw const ApiException('Server returned an unexpected response.'); }
  String _message(Map<String, dynamic> json) { final message = json['message'] ?? json['Message']; return message is String && message.isNotEmpty ? message : 'Không thể xử lý phiếu kiểm kê.'; }
}
