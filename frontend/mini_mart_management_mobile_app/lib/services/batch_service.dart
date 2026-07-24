import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/batch.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class BatchService {
  BatchService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<Batch>> fetchBatches() async {
    final response = await _client.get(
      ApiConfig.uri('/api/batches'),
      headers: const {'Accept': 'application/json'},
    );
    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    return _readItems(responseJson).map(Batch.fromJson).toList(growable: false);
  }

  Future<void> disposeExpiredBatch(int batchId) async {
    final csrfToken = await _fetchCsrfToken();
    final response = await _client.post(
      ApiConfig.uri('/api/batches/$batchId/dispose-expired'),
      headers: _mutationHeaders(csrfToken),
    );
    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }
  }

  Object? _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Máy chủ trả về phản hồi lô hàng không hợp lệ.');
    }
  }

  List<Map<String, dynamic>> _readItems(Object? responseJson) {
    final source = switch (responseJson) {
      List<dynamic> list => list,
      Map<String, dynamic> map => map['value'] ?? map['data'] ?? map['Data'],
      _ => null,
    };
    if (source is! List<dynamic>) {
      throw const ApiException('Phản hồi danh sách lô hàng thiếu dữ liệu.');
    }

    return source
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          throw const ApiException('Không thể đọc dữ liệu lô hàng.');
        })
        .toList(growable: false);
  }

  String _readMessage(Object? responseJson) {
    if (responseJson is Map<String, dynamic>) {
      final message = responseJson['message'] ?? responseJson['Message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Không thể tải danh sách lô hàng.';
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

    if (responseJson is! Map<String, dynamic>) {
      throw const ApiException('Phản hồi CSRF không hợp lệ.');
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
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }
    return headers;
  }

  String? _readCookieToken(String? setCookieHeader) {
    if (setCookieHeader == null || setCookieHeader.isEmpty) return null;
    return RegExp(
      r'XSRF-TOKEN=([^;,\s]+)',
    ).firstMatch(setCookieHeader)?.group(1);
  }
}

class _CsrfToken {
  const _CsrfToken({required this.value, required this.cookieHeader});

  final String value;
  final String? cookieHeader;
}
