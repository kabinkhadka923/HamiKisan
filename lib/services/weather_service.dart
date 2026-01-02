import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

class WeatherService {
  static const String _openWeatherMapUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _openWeatherMapApiKey = 'YOUR_OPENWEATHERMAP_API_KEY'; // Replace with actual API key

  // Nepal-specific weather APIs for better accuracy
  static const String _meteoblueUrl = 'https://my.meteoblue.com';

  SharedPreferences? _prefs;
  WeatherData? _cachedWeatherData;
  DateTime? _lastUpdateTime;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCachedData();
  }

  Future<WeatherData> getCurrentWeather(double latitude, double longitude) async {
    // Mock weather data
    return WeatherData(
      temperature: 25.0,
      weatherType: 'Sunny',
      rainChance: 10,
      humidity: 60.0,
      windSpeed: 15.0,
      timestamp: DateTime.now(),
      farmingTip: 'Water your crops in the early morning or late evening to minimize water loss due to evaporation.',
      location: _getLocationName(latitude, longitude),
    );
  }

  Future<List<WeatherData>> getWeeklyForecast(double latitude, double longitude) async {
    // Mock weekly forecast data
    return [
      WeatherData(
        temperature: 28.0,
        weatherType: 'Sunny',
        rainChance: 5,
        humidity: 55.0,
        windSpeed: 12.0,
        timestamp: DateTime.now().add(const Duration(days: 1)),
        farmingTip: 'Monitor soil moisture levels and adjust irrigation accordingly.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 26.0,
        weatherType: 'Cloudy',
        rainChance: 20,
        humidity: 70.0,
        windSpeed: 10.0,
        timestamp: DateTime.now().add(const Duration(days: 2)),
        farmingTip: 'Consider applying foliar fertilizers to provide essential nutrients to your crops.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 24.0,
        weatherType: 'Rainy',
        rainChance: 80,
        humidity: 85.0,
        windSpeed: 8.0,
        timestamp: DateTime.now().add(const Duration(days: 3)),
        farmingTip: 'Protect your crops from heavy rainfall by providing proper drainage.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 27.0,
        weatherType: 'Partly Cloudy',
        rainChance: 30,
        humidity: 65.0,
        windSpeed: 11.0,
        timestamp: DateTime.now().add(const Duration(days: 4)),
        farmingTip: 'Scout your fields for pests and diseases and take appropriate control measures.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 29.0,
        weatherType: 'Sunny',
        rainChance: 10,
        humidity: 50.0,
        windSpeed: 14.0,
        timestamp: DateTime.now().add(const Duration(days: 5)),
        farmingTip: 'Ensure adequate sunlight exposure for your crops to promote healthy growth.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 25.0,
        weatherType: 'Cloudy',
        rainChance: 40,
        humidity: 75.0,
        windSpeed: 9.0,
        timestamp: DateTime.now().add(const Duration(days: 6)),
        farmingTip: 'Monitor weather forecasts and adjust your farming practices accordingly.',
        location: _getLocationName(latitude, longitude),
      ),
      WeatherData(
        temperature: 23.0,
        weatherType: 'Rainy',
        rainChance: 90,
        humidity: 90.0,
        windSpeed: 7.0,
        timestamp: DateTime.now().add(const Duration(days: 7)),
        farmingTip: 'Take necessary precautions to protect your crops from waterlogging and fungal diseases.',
        location: _getLocationName(latitude, longitude),
      ),
    ];
  }

  List<WeatherNotification> generateWeatherAlerts(WeatherData current, List<WeatherData> forecast) {
    final List<WeatherNotification> alerts = [];

    // Temperature alerts
    if (current.temperature > 35) {
      alerts.add(WeatherNotification(
        type: 'weather',
        title: 'Extreme Heat Warning',
        message: 'Temperature reached ${current.temperature.toStringAsFixed(1)}°C. Avoid field work during peak hours.',
        timestamp: DateTime.now(),
        isUrgent: true,
      ));
    }

    if (current.temperature < 5) {
      alerts.add(WeatherNotification(
        type: 'weather',
        title: 'Frost Warning',
        message: 'Low temperature detected. Protect sensitive crops from frost damage.',
        timestamp: DateTime.now(),
        isUrgent: true,
      ));
    }

    // Rain alerts
    if (current.rainChance > 70) {
      alerts.add(WeatherNotification(
        type: 'weather',
        title: 'Heavy Rain Expected',
        message: 'High chance of rain (${current.rainChance}%). Consider postponing pesticide spraying.',
        timestamp: DateTime.now(),
        isUrgent: true,
      ));
    }

    // Weekly forecast alerts
    for (int i = 0; i < forecast.length && i < 3; i++) {
      final day = forecast[i];
      if (day.temperature < 0) {
        alerts.add(WeatherNotification(
          type: 'weather',
          title: 'Freeze Warning',
          message: 'Freezing temperatures expected in ${i + 1} days. Prepare crop protection measures.',
          timestamp: DateTime.now(),
          isUrgent: true,
        ));
        break;
      }
    }

    return alerts;
  }

  int _calculateRainChance(double pop) {
    return (pop * 100).round();
  }

  String _getLocationName(double lat, double lon) {
    // Simple location name generator based on coordinates
    // In a real app, you'd use reverse geocoding
    final locations = [
      'Kathmandu',
      'Pokhara', 
      'Biratnagar',
      'Birgunj',
      'Dharan',
      'Butwal',
      'Hetauda',
      'Janakpur',
      'Dhangadhi',
      'Tulsipur'
    ];
    
    final index = ((lat + lon).abs() * 10).round() % locations.length;
    return locations[index];
  }

  Future<void> _saveCachedData(WeatherData data) async {
    if (_prefs == null) return;
    
    final cachedData = {
      'temperature': data.temperature,
      'weatherType': data.weatherType,
      'rainChance': data.rainChance,
      'humidity': data.humidity,
      'windSpeed': data.windSpeed,
      'timestamp': data.timestamp.toIso8601String(),
      'farmingTip': data.farmingTip,
      'location': data.location,
    };
    
    await _prefs!.setString('cached_weather', json.encode(cachedData));
  }

  Future<void> _loadCachedData() async {
    if (_prefs == null) return;
    
    final cachedString = _prefs!.getString('cached_weather');
    if (cachedString != null) {
      try {
        final cachedData = json.decode(cachedString);
        _cachedWeatherData = WeatherData(
          temperature: cachedData['temperature'].toDouble(),
          weatherType: cachedData['weatherType'].toString(),
          rainChance: cachedData['rainChance'],
          humidity: cachedData['humidity'].toDouble(),
          windSpeed: cachedData['windSpeed'].toDouble(),
          timestamp: DateTime.parse(cachedData['timestamp'].toString()),
          farmingTip: cachedData['farmingTip'].toString(),
          location: cachedData['location'].toString(),
        );
        _lastUpdateTime = DateTime.parse(cachedData['timestamp'].toString());
      } catch (e) {
        print('Error loading cached weather data: $e');
      }
    }
  }
}

// Mock GPS service for development
class LocationService {
  static const double _kathmanduLat = 27.7172;
  static const double _kathmanduLon = 85.3240;
  
  Future<(double, double)> getCurrentLocation() async {
    // In a real app, you'd use geolocator package
    // For now, return Kathmandu coordinates
    return (_kathmanduLat, _kathmanduLon);
  }
}
