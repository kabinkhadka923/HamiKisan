import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const String _kalimatiApiUrlKey = 'kalimati_api_url';
  static const String _kalimatiApiKeyKey = 'kalimati_api_key';
  static const String _weatherApiKeyKey = 'weather_api_key';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Kalimati API Configuration
  Future<void> setKalimatiApiUrl(String url) async {
    await _prefs?.setString(_kalimatiApiUrlKey, url);
  }

  Future<void> setKalimatiApiKey(String key) async {
    await _prefs?.setString(_kalimatiApiKeyKey, key);
  }

  String? getKalimatiApiUrl() {
    return _prefs?.getString(_kalimatiApiUrlKey);
  }

  String? getKalimatiApiKey() {
    return _prefs?.getString(_kalimatiApiKeyKey);
  }

  // Weather API Configuration
  Future<void> setWeatherApiKey(String key) async {
    await _prefs?.setString(_weatherApiKeyKey, key);
  }

  String? getWeatherApiKey() {
    return _prefs?.getString(_weatherApiKeyKey);
  }

  // Clear all API configurations
  Future<void> clearAllConfigs() async {
    await _prefs?.remove(_kalimatiApiUrlKey);
    await _prefs?.remove(_kalimatiApiKeyKey);
    await _prefs?.remove(_weatherApiKeyKey);
  }

  // Test API connection
  Future<bool> testKalimatiConnection() async {
    final url = getKalimatiApiUrl();
    if (url == null || url.isEmpty) return false;
    // Add actual connection test logic here
    return true;
  }
}
