import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

class WeatherService {
  static const Duration _cacheDuration = Duration(minutes: 30);
  static const String _cacheKey = 'cached_weather_data';
  static const String _cacheTimestampKey = 'cached_weather_timestamp';

  late SharedPreferences _prefs;
  WeatherData? _cachedWeatherData;
  DateTime? _lastUpdateTime;

  // Singleton instance
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  // Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCachedData();
  }

  // Check if cache is valid
  bool get _isCacheValid {
    if (_lastUpdateTime == null) return false;
    return DateTime.now().difference(_lastUpdateTime!) < _cacheDuration;
  }

  // Get current weather with caching
  Future<WeatherData> getCurrentWeather(
      double latitude, double longitude) async {
    // Return cached data if valid
    if (_isCacheValid && _cachedWeatherData != null) {
      return _cachedWeatherData!;
    }

    try {
      // TODO: Replace with actual API call
      // final weatherData = await _fetchFromOpenWeatherMap(latitude, longitude);
      // For now, use mock data
      final weatherData =
          _generateMockWeatherData(latitude, longitude, isCurrent: true);

      // Cache the result
      await _cacheWeatherData(weatherData);
      _cachedWeatherData = weatherData;

      return weatherData;
    } catch (e) {
      // Fallback to cached data even if expired, then mock data
      return _cachedWeatherData ??
          _generateMockWeatherData(latitude, longitude, isCurrent: true);
    }
  }

  // Get weekly forecast
  Future<List<WeatherData>> getWeeklyForecast(
      double latitude, double longitude) async {
    try {
      // TODO: Replace with actual API call
      // final forecast = await _fetchForecastFromAPI(latitude, longitude);
      // For now, use mock data
      final List<WeatherData> forecast = [];
      for (int i = 0; i < 7; i++) {
        forecast.add(
            _generateMockWeatherData(latitude, longitude, dayOffset: i + 1));
      }
      return forecast;
    } catch (e) {
      // Return mock data on error
      return List.generate(
          7,
          (index) => _generateMockWeatherData(latitude, longitude,
              dayOffset: index + 1));
    }
  }

  // Generate smart weather alerts with severity levels
  List<WeatherAlert> generateWeatherAlerts(
      WeatherData current, List<WeatherData> forecast) {
    final List<WeatherAlert> alerts = [];

    // Temperature-based alerts
    if (current.temperature > 35) {
      alerts.add(WeatherAlert(
        type: AlertType.heat,
        title: 'Extreme Heat Warning',
        message:
            'Temperature reached ${current.temperature.toStringAsFixed(1)}°C. Avoid field work during peak hours.',
        severity: Severity.high,
        timestamp: DateTime.now(),
        actionable: true,
        actionTip: 'Irrigate in early morning and provide shade if possible.',
      ));
    } else if (current.temperature < 5) {
      alerts.add(WeatherAlert(
        type: AlertType.frost,
        title: 'Frost Warning',
        message:
            'Low temperature detected. Protect sensitive crops from frost damage.',
        severity: Severity.high,
        timestamp: DateTime.now(),
        actionable: true,
        actionTip: 'Use frost cloths or irrigation to protect crops overnight.',
      ));
    }

    // Rain-based alerts
    if (current.rainChance > 70) {
      alerts.add(WeatherAlert(
        type: AlertType.rain,
        title: 'Heavy Rain Expected',
        message:
            'High chance of rain (${current.rainChance}%). Consider postponing pesticide spraying.',
        severity: current.rainChance > 85 ? Severity.high : Severity.medium,
        timestamp: DateTime.now(),
        actionable: true,
        actionTip: 'Ensure proper drainage and postpone chemical applications.',
      ));
    } else if (current.rainChance < 10 && current.humidity < 40) {
      alerts.add(WeatherAlert(
        type: AlertType.drought,
        title: 'Low Humidity Alert',
        message: 'Dry conditions detected. Consider additional irrigation.',
        severity: Severity.low,
        timestamp: DateTime.now(),
        actionable: true,
        actionTip: 'Increase irrigation frequency during dry spells.',
      ));
    }

    // Wind-based alerts
    if (current.windSpeed > 20) {
      alerts.add(WeatherAlert(
        type: AlertType.wind,
        title: 'Strong Winds Expected',
        message:
            'Wind speed ${current.windSpeed.toStringAsFixed(1)} km/h. Secure light structures.',
        severity: Severity.medium,
        timestamp: DateTime.now(),
        actionable: true,
        actionTip: 'Delay spraying and secure greenhouse covers.',
      ));
    }

    // Future forecast alerts (next 3 days)
    for (int i = 0; i < min(3, forecast.length); i++) {
      final day = forecast[i];

      if (day.temperature < 0) {
        alerts.add(WeatherAlert(
          type: AlertType.frost,
          title: 'Freezing Temperatures Ahead',
          message:
              'Freezing temperatures expected in ${i + 1} day${i == 0 ? '' : 's'}.',
          severity: Severity.high,
          timestamp: DateTime.now(),
          actionable: true,
          actionTip: 'Prepare frost protection measures like row covers.',
        ));
      }

      if (day.rainChance > 80) {
        alerts.add(WeatherAlert(
          type: AlertType.rain,
          title: 'Heavy Rainfall Expected Soon',
          message:
              '${day.rainChance}% chance of heavy rain in ${i + 1} day${i == 0 ? '' : 's'}.',
          severity: Severity.medium,
          timestamp: DateTime.now(),
          actionable: true,
          actionTip: 'Harvest ripe crops and ensure drainage is clear.',
        ));
      }
    }

    return alerts;
  }

  // Generate farming tips based on weather conditions
  String _generateFarmingTip(WeatherData data) {
    final tips = {
      'sunny':
          'Water your crops in the early morning or late evening to minimize evaporation.',
      'rainy':
          'Delay fertilizer application and ensure proper drainage to prevent waterlogging.',
      'cloudy': 'Good day for transplanting and pruning operations.',
      'windy': 'Avoid spraying pesticides and secure greenhouse covers.',
      'humid': 'Monitor for fungal diseases and improve air circulation.',
      'dry':
          'Increase irrigation frequency and consider mulching to retain soil moisture.',
    };

    final weatherType = data.weatherType.toLowerCase();

    if (weatherType.contains('rain')) {
      return tips['rainy']!;
    } else if (weatherType.contains('cloud')) {
      return tips['cloudy']!;
    } else if (data.windSpeed > 15) {
      return tips['windy']!;
    } else if (data.humidity > 75) {
      return tips['humid']!;
    } else if (data.humidity < 40) {
      return tips['dry']!;
    }

    return tips['sunny']!;
  }

  // Generate mock weather data with realistic patterns
  WeatherData _generateMockWeatherData(double lat, double lon,
      {int dayOffset = 0, bool isCurrent = false}) {
    final random = Random((lat + lon + dayOffset).hashCode);
    final now = DateTime.now().add(Duration(days: dayOffset));

    // Generate realistic temperatures based on day offset
    final baseTemp = 25.0 + (sin(dayOffset * 0.5) * 5.0);
    final tempVariation = random.nextDouble() * 4 - 2;
    final temperature = baseTemp + tempVariation;

    // Generate weather type based on probability
    final weatherTypes = [
      'Sunny',
      'Partly Cloudy',
      'Cloudy',
      'Light Rain',
      'Rainy',
      'Thunderstorm'
    ];
    final weights = [0.3, 0.25, 0.2, 0.15, 0.08, 0.02];
    final weatherType = _weightedRandomChoice(weatherTypes, weights, random);

    // Generate related metrics
    final rainChance =
        weatherType.contains('Rain') || weatherType.contains('Thunder')
            ? 70 + random.nextInt(30)
            : random.nextInt(30);

    final humidity = (weatherType.contains('Rain')
            ? 75 + random.nextInt(20)
            : 40 + random.nextInt(35))
        .toDouble();

    final windSpeed = weatherType.contains('Thunder')
        ? 20.0 + random.nextDouble() * 15.0
        : 5.0 + random.nextDouble() * 15.0;

    return WeatherData(
      temperature: temperature,
      weatherType: weatherType,
      rainChance: rainChance,
      humidity: humidity,
      windSpeed: windSpeed,
      timestamp: now,
      farmingTip: _generateFarmingTip(WeatherData(
        temperature: temperature,
        weatherType: weatherType,
        rainChance: rainChance,
        humidity: humidity,
        windSpeed: windSpeed,
        timestamp: now,
        farmingTip: '',
        location: '',
      )),
      location: _getLocationName(lat, lon),
    );
  }

  // Cache weather data
  Future<void> _cacheWeatherData(WeatherData data) async {
    final cacheData = {
      'temperature': data.temperature,
      'weatherType': data.weatherType,
      'rainChance': data.rainChance,
      'humidity': data.humidity,
      'windSpeed': data.windSpeed,
      'timestamp': data.timestamp.toIso8601String(),
      'farmingTip': data.farmingTip,
      'location': data.location,
    };

    await Future.wait([
      _prefs.setString(_cacheKey, json.encode(cacheData)),
      _prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String()),
    ]);

    _lastUpdateTime = DateTime.now();
  }

  // Load cached data
  Future<void> _loadCachedData() async {
    try {
      final cachedString = _prefs.getString(_cacheKey);
      final timestampString = _prefs.getString(_cacheTimestampKey);

      if (cachedString != null && timestampString != null) {
        final cachedData = json.decode(cachedString);
        _lastUpdateTime = DateTime.parse(timestampString);

        _cachedWeatherData = WeatherData(
          temperature: (cachedData['temperature'] as num).toDouble(),
          weatherType: cachedData['weatherType'].toString(),
          rainChance: cachedData['rainChance'] as int,
          humidity: (cachedData['humidity'] as num).toDouble(),
          windSpeed: (cachedData['windSpeed'] as num).toDouble(),
          timestamp: DateTime.parse(cachedData['timestamp'].toString()),
          farmingTip: cachedData['farmingTip'].toString(),
          location: cachedData['location'].toString(),
        );
      }
    } catch (e) {
      // Clear invalid cache
      await _clearCache();
    }
  }

  // Clear cache
  Future<void> _clearCache() async {
    await Future.wait([
      _prefs.remove(_cacheKey),
      _prefs.remove(_cacheTimestampKey),
    ]);
    _cachedWeatherData = null;
    _lastUpdateTime = null;
  }

  // Helper method for weighted random choices
  String _weightedRandomChoice(
      List<String> items, List<double> weights, Random random) {
    final totalWeight = weights.reduce((a, b) => a + b);
    final randomValue = random.nextDouble() * totalWeight;

    double cumulativeWeight = 0;
    for (int i = 0; i < items.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return items[i];
      }
    }
    return items.last;
  }

  // Get location name based on Nepal regions
  String _getLocationName(double lat, double lon) {
    // Nepal's approximate boundaries
    final nepalLocations = {
      'Kathmandu Valley': Point(27.7172, 85.3240),
      'Pokhara': Point(28.2096, 83.9856),
      'Chitwan': Point(27.5290, 84.3542),
      'Lumbini': Point(27.6792, 83.5070),
      'Janakpur': Point(26.7271, 85.9418),
      'Biratnagar': Point(26.4525, 87.2718),
      'Dharan': Point(26.8120, 87.2840),
      'Butwal': Point(27.7000, 83.4500),
      'Nepalgunj': Point(28.0500, 81.6167),
      'Bhairahawa': Point(27.5000, 83.4500),
    };

    // Find closest location
    String closestLocation = 'Kathmandu Valley';
    double minDistance = double.infinity;

    nepalLocations.forEach((name, point) {
      final distance = _calculateDistance(lat, lon, point.x, point.y);
      if (distance < minDistance) {
        minDistance = distance;
        closestLocation = name;
      }
    });

    return closestLocation;
  }

  // Calculate distance between two coordinates (simplified)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return sqrt(pow(lat1 - lat2, 2) + pow(lon1 - lon2, 2));
  }
}

// Simple Point class
class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

// Enhanced LocationService
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Nepal's major agricultural regions
  static const Map<String, (double, double)> _nepalRegions = {
    'Kathmandu': (27.7172, 85.3240),
    'Pokhara': (28.2096, 83.9856),
    'Chitwan': (27.5290, 84.3542),
    'Lumbini': (27.6792, 83.5070),
    'Janakpur': (26.7271, 85.9418),
    'Biratnagar': (26.4525, 87.2718),
    'Dharan': (26.8120, 87.2840),
  };

  Future<(double, double)> getCurrentLocation() async {
    try {
      // TODO: Implement actual GPS/network location
      // For now, return a random Nepal region for testing
      final random = Random();
      final region =
          _nepalRegions.values.elementAt(random.nextInt(_nepalRegions.length));
      return region;
    } catch (e) {
      // Default to Kathmandu
      return _nepalRegions['Kathmandu']!;
    }
  }

  Future<String> getLocationName(double lat, double lon) async {
    // TODO: Implement reverse geocoding
    // For now, find closest known region
    String closestRegion = 'Kathmandu';
    double minDistance = double.infinity;

    _nepalRegions.forEach((name, coords) {
      final distance = _calculateDistance(lat, lon, coords.$1, coords.$2);
      if (distance < minDistance) {
        minDistance = distance;
        closestRegion = name;
      }
    });

    return closestRegion;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return sqrt(pow(lat1 - lat2, 2) + pow(lon1 - lon2, 2));
  }
}
