import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/e_invoice.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class EInvoiceService {
  EInvoiceService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<EInvoice>> fetchInvoices() async {
    final response = await _client.get(
      ApiConfig.uri('/api/einvoices'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final items =
        responseJson['data'] ??
        responseJson['Data'] ??
        responseJson['value'] ??
        responseJson['Value'] ??
        responseJson;

    if (items is! List) {
      throw const ApiException('Phản hồi danh sách hóa đơn không hợp lệ.');
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(EInvoice.fromJson)
        .toList(growable: false);
  }

  Future<EInvoiceDetailResponse> fetchInvoiceById(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/einvoices/$id'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return EInvoiceDetailResponse.fromJson(responseJson);
  }

  Future<EInvoice> createInvoiceFromOrder(int orderId) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = _mutationHeaders(csrfToken);
    final response = await _client.post(
      ApiConfig.uri('/api/einvoices/from-order/$orderId'),
      headers: headers,
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return EInvoice.fromJson(responseJson);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) return {'data': decoded};
    } on FormatException {
      throw const ApiException('Máy chủ trả về phản hồi không hợp lệ.');
    }
    throw const ApiException('Máy chủ trả về phản hồi không mong đợi.');
  }

  String _readMessage(Map<String, dynamic> responseJson) {
    final message = responseJson['message'] ?? responseJson['Message'];
    return message is String && message.isNotEmpty
        ? message
        : 'Yêu cầu hóa đơn thất bại. Vui lòng thử lại.';
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
      throw const ApiException('Phản hồi CSRF thiếu dữ liệu token.');
    }

    final token = data['csrfToken'] ?? data['CsrfToken'];
    if (token is! String || token.isEmpty) {
      throw const ApiException('Thiếu token CSRF.');
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
