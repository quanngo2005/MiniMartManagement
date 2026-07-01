import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/receipt.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class ReceiptService {
  ReceiptService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Receipt>> fetchReceipts() async {
    final response = await _client.get(
      ApiConfig.uri('/api/receipts'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final items = _readItems(responseJson);
    return items.map(Receipt.fromJson).toList(growable: false);
  }

  Future<Receipt> createReceipt(CreateReceipt receipt) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = _mutationHeaders(csrfToken);
    final response = await _client.post(
      ApiConfig.uri('/api/receipts'),
      headers: headers,
      body: jsonEncode(receipt.toJson()),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Receipt.fromJson(responseJson);
  }

  Future<Receipt> updateReceipt(int id, UpdateReceipt receipt) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = _mutationHeaders(csrfToken);
    final response = await _client.put(
      ApiConfig.uri('/api/receipts/$id'),
      headers: headers,
      body: jsonEncode(receipt.toJson()),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Receipt.fromJson(responseJson);
  }

  Future<Receipt> completeReceipt(int id) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = _mutationHeaders(csrfToken);
    final response = await _client.post(
      ApiConfig.uri('/api/receipts/$id/complete'),
      headers: headers,
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return Receipt.fromJson(responseJson);
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
    final source = responseJson['value'] ??
        responseJson['Value'] ??
        responseJson['data'] ??
        responseJson['Data'];

    if (source is! List<dynamic>) {
      throw const ApiException('Không thể đọc danh sách chứng từ.');
    }

    return source.map((item) {
      if (item is Map<String, dynamic>) return item;
      throw const ApiException('Không thể đọc chứng từ.');
    }).toList(growable: false);
  }

  String _readMessage(Map<String, dynamic> responseJson) {
    final message = responseJson['message'] ?? responseJson['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Yêu cầu chứng từ thất bại. Vui lòng thử lại.';
  }

  Future<_CsrfToken> _fetchCsrfToken() async {
    final response = await _client.get(
      ApiConfig.uri('/api/auth/csrf-token'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final data = responseJson['data'] ?? responseJson['Data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException('CSRF response is missing token data.');
    }

    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('CSRF token is missing.');
    }

    final cookieToken = _readCookieToken(response.headers['set-cookie']);
    return _CsrfToken(
      value: token,
      cookieHeader: cookieToken == null ? null : 'XSRF-TOKEN=$cookieToken',
    );
  }

  Map<String, String> _mutationHeaders(_CsrfToken csrfToken) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };

    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    return headers;
  }

  String? _readCookieToken(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return null;
    final match = RegExp(r'XSRF-TOKEN=([^;,\s]+)').firstMatch(setCookieHeader);
    return match?.group(1);
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, required this.cookieHeader});

  final String value;
  final String? cookieHeader;
}
