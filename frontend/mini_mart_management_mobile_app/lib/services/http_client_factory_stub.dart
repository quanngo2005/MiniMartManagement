import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_mart_management_mobile_app/config/api_config.dart';
import 'package:mini_mart_management_mobile_app/core/api_exception.dart';

http.Client createHttpClient() => CookieClient(http.Client());

void clearCookieStore() => CookieClient.clearCookies();

class CookieClient extends http.BaseClient {
  CookieClient(this._inner);

  final http.Client _inner;
  static final Map<String, String> _cookies = {};
  static bool _isRefreshing = false;
  static Future<void>? _refreshFuture;

  static void clearCookies() {
    _cookies.clear();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_cookies.isNotEmpty) {
      final cookieHeader = _cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');

      final existingCookie = request.headers['Cookie'];
      if (existingCookie != null && existingCookie.isNotEmpty) {
        request.headers['Cookie'] = '$existingCookie; $cookieHeader';
      } else {
        request.headers['Cookie'] = cookieHeader;
      }
    }

    var response = await _inner.send(request);

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      _updateCookies(setCookie);
    }

    if (response.statusCode == 401 && _shouldAttemptRefresh(request)) {
      try {
        await _performTokenRefresh();
        response = await _retryRequest(request);
      } on UnauthorizedException {
        rethrow;
      } catch (_) {}
    }

    return response;
  }

  bool _shouldAttemptRefresh(http.BaseRequest request) {
    if (request.url.path.endsWith('/api/auth/refresh-token')) return false;
    if (request.url.path.endsWith('/api/auth/login')) return false;
    if (request.url.path.endsWith('/api/auth/csrf-token')) return false;
    return _cookies.containsKey('refresh_token');
  }

  Future<void> _performTokenRefresh() async {
    if (_isRefreshing) {
      await _refreshFuture;
      return;
    }
    _isRefreshing = true;
    _refreshFuture = _doRefresh();
    try {
      await _refreshFuture;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Future<void> _doRefresh() async {
    final tempClient = http.Client();
    try {
      final csrfResponse = await tempClient.get(
        ApiConfig.uri('/api/auth/csrf-token'),
        headers: const {'Accept': 'application/json'},
      );
      _updateCookies(csrfResponse.headers['set-cookie'] ?? '');

      if (csrfResponse.statusCode < 200 || csrfResponse.statusCode >= 300) {
        _cookies.clear();
        throw const UnauthorizedException();
      }

      final responseJson =
          jsonDecode(csrfResponse.body) as Map<String, dynamic>;
      final data =
          (responseJson['data'] ?? responseJson['Data'])
              as Map<String, dynamic>;
      final csrfValue = data['csrfToken'] ?? data['CsrfToken'] as String;

      final refreshResponse = await tempClient.post(
        ApiConfig.uri('/api/auth/refresh-token'),
        headers: {
          'Accept': 'application/json',
          'X-XSRF-TOKEN': csrfValue,
          'Cookie': 'XSRF-TOKEN=$csrfValue',
        },
      );
      _updateCookies(refreshResponse.headers['set-cookie'] ?? '');

      if (refreshResponse.statusCode == 401) {
        _cookies.clear();
        throw const UnauthorizedException();
      }
    } finally {
      tempClient.close();
    }
  }

  Future<http.StreamedResponse> _retryRequest(http.BaseRequest request) async {
    final originalMethod = request.method;
    final originalUrl = request.url;
    final originalHeaders = Map<String, String>.from(request.headers);
    final originalBodyBytes = (request is http.Request)
        ? request.bodyBytes
        : null;

    if (originalBodyBytes == null) {
      throw const UnauthorizedException();
    }

    final retryRequest = http.Request(originalMethod, originalUrl)
      ..headers.addAll(originalHeaders)
      ..bodyBytes = originalBodyBytes;

    if (_cookies.isNotEmpty) {
      final cookieHeader = _cookies.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join('; ');
      retryRequest.headers['Cookie'] = cookieHeader;
    }

    return await _inner.send(retryRequest);
  }

  void _updateCookies(String setCookieHeader) {
    final regex = RegExp(r'(access_token|refresh_token|XSRF-TOKEN)=([^;,\s]+)');
    final matches = regex.allMatches(setCookieHeader);
    for (final match in matches) {
      final name = match.group(1);
      final value = match.group(2);
      if (name != null && value != null) {
        _cookies[name] = value;
      }
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
