import 'package:flutter/foundation.dart';

class BackendConfig {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  static Uri uri(String path, {Map<String, String>? query}) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }
}
