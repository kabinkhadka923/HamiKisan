class BackendConfig {
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }

    return 'https://hamikisan.onrender.com';
  }

  static Uri uri(String path, {Map<String, String>? query}) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query);
  }
}
