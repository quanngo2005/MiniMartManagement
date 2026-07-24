import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kIsWeb) {
      return 'https://mmms-cvaka8c9bkfkduf3.southeastasia-01.azurewebsites.net';
    }
    // Dynamic mapping for mobile emulators
    return defaultTargetPlatform == TargetPlatform.android
        ? 'https://mmms-cvaka8c9bkfkduf3.southeastasia-01.azurewebsites.net'
        : 'http://10.0.2.2:5005';
  }

  static Uri uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }
}
