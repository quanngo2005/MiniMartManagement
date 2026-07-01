import 'package:http/http.dart' as http;

http.Client createHttpClient() => CookieClient(http.Client());

class CookieClient extends http.BaseClient {
  CookieClient(this._inner);

  final http.Client _inner;
  static final Map<String, String> _cookies = {};

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

    final response = await _inner.send(request);

    final setCookie = response.headers['set-cookie'];
    if (setCookie != null && setCookie.isNotEmpty) {
      _updateCookies(setCookie);
    }

    return response;
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
