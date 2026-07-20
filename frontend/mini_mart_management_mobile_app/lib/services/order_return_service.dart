import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';
import 'package:mini_mart_management_mobile_app/models/order_return.dart';
import 'package:mini_mart_management_mobile_app/services/http_client_factory.dart';

class OrderReturnService {
  OrderReturnService({http.Client? client})
    : _client = client ?? createConfiguredClient();

  final http.Client _client;

  Future<List<OrderReturn>> fetchOrderReturns() async {
    final response = await _client.get(
      ApiConfig.uri('/api/refunds'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    final items = _readItems(responseJson);
    return items.map((item) => OrderReturn.fromJson(item)).toList();
  }

  Future<OrderReturn?> fetchOrderReturnById(int id) async {
    final response = await _client.get(
      ApiConfig.uri('/api/refunds/$id'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    if (responseJson is Map<String, dynamic>) {
      return OrderReturn.fromJson(responseJson);
    }
    return null;
  }

  Future<OrderReturn> createOrderReturn(Map<String, dynamic> payload) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.post(
      ApiConfig.uri('/api/refunds/request'),
      headers: headers,
      body: jsonEncode(payload),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        responseJson is Map<String, dynamic>
            ? _readMessage(responseJson)
            : 'Tạo yêu cầu hoàn trả thất bại',
      );
    }

    if (responseJson is Map<String, dynamic>) {
      return OrderReturn.fromJson(responseJson);
    }
    throw const ApiException('Invalid response structure from server.');
  }

  Future<String> uploadImage(
    String filePath, {
    String? fileName,
    Uint8List? bytes,
  }) async {
    final csrfToken = await _fetchCsrfToken();
    final uri = ApiConfig.uri('/api/refunds/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    });
    if (csrfToken.cookieHeader != null) {
      request.headers['Cookie'] = csrfToken.cookieHeader!;
    }

    if (bytes != null) {
      final normalizedFileName = fileName?.trim();
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: normalizedFileName == null || normalizedFileName.isEmpty
              ? 'evidence.jpg'
              : normalizedFileName,
        ),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        responseJson is Map<String, dynamic>
            ? _readMessage(responseJson)
            : 'Upload ảnh thất bại',
      );
    }

    if (responseJson is Map<String, dynamic>) {
      final url = responseJson['url'] ?? responseJson['Url'];
      if (url is String) return url;
    }
    throw const ApiException('Không nhận được URL ảnh từ server.');
  }

  Future<OrderReturn> approveOrderReturn(int id) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.post(
      ApiConfig.uri('/api/refunds/$id/approve'),
      headers: headers,
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        responseJson is Map<String, dynamic>
            ? _readMessage(responseJson)
            : 'Duyệt yêu cầu hoàn trả thất bại',
      );
    }

    if (responseJson is Map<String, dynamic>) {
      return OrderReturn.fromJson(responseJson);
    }
    throw const ApiException('Invalid response structure from server.');
  }

  Future<OrderReturn> rejectOrderReturn(int id, String note) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.post(
      ApiConfig.uri('/api/refunds/$id/reject'),
      headers: headers,
      body: jsonEncode({'note': note}),
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        responseJson is Map<String, dynamic>
            ? _readMessage(responseJson)
            : 'Từ chối yêu cầu hoàn trả thất bại',
      );
    }

    if (responseJson is Map<String, dynamic>) {
      return OrderReturn.fromJson(responseJson);
    }
    throw const ApiException('Invalid response structure from server.');
  }

  Future<OrderReturn> confirmCashRefund(int id) async {
    final csrfToken = await _fetchCsrfToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-XSRF-TOKEN': csrfToken.value,
    };
    if (csrfToken.cookieHeader != null) {
      headers['Cookie'] = csrfToken.cookieHeader!;
    }

    final response = await _client.post(
      ApiConfig.uri('/api/refunds/$id/confirm-cash-refund'),
      headers: headers,
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        responseJson is Map<String, dynamic>
            ? _readMessage(responseJson)
            : 'Xác nhận hoàn tiền thất bại',
      );
    }

    if (responseJson is Map<String, dynamic>) {
      return OrderReturn.fromJson(responseJson);
    }
    throw const ApiException('Invalid response structure from server.');
  }

  Future<Map<String, dynamic>> fetchOrderDetailsForReturn(
    String orderCode,
  ) async {
    final response = await _client.get(
      ApiConfig.uri('/api/refunds/order/$orderCode'),
      headers: const {'Accept': 'application/json'},
    );

    final responseJson = _decodeResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_readMessage(responseJson));
    }

    if (responseJson is Map<String, dynamic>) {
      return responseJson;
    }
    throw const ApiException('Dữ liệu trả về không đúng cấu trúc.');
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

    final data = responseJson is Map<String, dynamic>
        ? (responseJson['data'] ?? responseJson['Data'])
        : null;
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

  Object? _decodeResponse(http.Response response) {
    try {
      final body = response.body;
      if (body.isEmpty) return null;
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException('Server returned an invalid response.');
    }
  }

  List<Map<String, dynamic>> _readItems(Object? responseJson) {
    final source = switch (responseJson) {
      List<dynamic> list => list,
      Map<String, dynamic> map => map['value'] ?? map['data'] ?? map['Data'],
      _ => null,
    };

    if (source is! List<dynamic>) {
      throw const ApiException('Response is missing refunds list.');
    }

    return source
        .map((item) {
          if (item is Map<String, dynamic>) return item;
          throw const ApiException('Refund request could not be read.');
        })
        .toList(growable: false);
  }

  String _readMessage(Object? responseJson) {
    if (responseJson is Map<String, dynamic>) {
      final message = responseJson['message'] ?? responseJson['Message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Yêu cầu thất bại. Vui lòng thử lại.';
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
