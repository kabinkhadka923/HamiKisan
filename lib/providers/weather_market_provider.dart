 import 'package:flutter/material.dart';
import '../models/weather_models.dart';

class WeatherMarketProvider with ChangeNotifier {
  WeatherData? _weatherData;
  List<MarketPrice>? _marketPrices;
  bool _isLoadingWeather = false;
  bool _isLoadingMarketPrice = false;
  String? _error;

  WeatherData? get weatherData => _weatherData;
  List<MarketPrice>? get marketPrices => _marketPrices;
  bool get isLoadingWeather => _isLoadingWeather;
  bool get isLoadingMarketPrice => _isLoadingMarketPrice;
  String? get error => _error;

  Future<void> initialize() async {
    await loadWeatherAndMarketData();
  }

  Future<void> loadWeatherAndMarketData() async {
    await Future.wait([
      loadWeatherData(),
      loadMarketPrices(),
    ]);
  }

  Future<void> loadWeatherData() async {
    _isLoadingWeather = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      _weatherData = WeatherData(
        temperature: 25.0 + (DateTime.now().hour - 12) * 0.5,
        humidity: 65.0,
        windSpeed: 8.5,
        weatherType: 'Partly Cloudy',
        rainChance: 20,
        farmingTip: 'Good weather for farming',
        location: 'Kathmandu',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      _error = 'Failed to load weather data: $e';
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
    }
  }

  Future<void> loadMarketPrices() async {
    _isLoadingMarketPrice = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      _marketPrices = [
        MarketPrice(
          productName: 'Rice',
          avgPrice: 85.0,
          minPrice: 80.0,
          maxPrice: 90.0,
          priceChangePercent: 2.5,
          location: 'Kathmandu',
          timestamp: DateTime.now(),
          demandIndex: 0.7,
          scarcityIndex: 0.5,
        ),
        MarketPrice(
          productName: 'Wheat',
          avgPrice: 45.0,
          minPrice: 42.0,
          maxPrice: 48.0,
          priceChangePercent: -1.2,
          location: 'Kathmandu',
          timestamp: DateTime.now(),
          demandIndex: 0.6,
          scarcityIndex: 0.4,
        ),
        MarketPrice(
          productName: 'Tomato',
          avgPrice: 120.0,
          minPrice: 100.0,
          maxPrice: 140.0,
          priceChangePercent: 5.8,
          location: 'Kathmandu',
          timestamp: DateTime.now(),
          demandIndex: 0.9,
          scarcityIndex: 0.8,
        ),
        MarketPrice(
          productName: 'Potato',
          avgPrice: 35.0,
          minPrice: 30.0,
          maxPrice: 40.0,
          priceChangePercent: 0.5,
          location: 'Kathmandu',
          timestamp: DateTime.now(),
          demandIndex: 0.5,
          scarcityIndex: 0.3,
        ),
      ];
    } catch (e) {
      _error = 'Failed to load market prices: $e';
    } finally {
      _isLoadingMarketPrice = false;
      notifyListeners();
    }
  }

  String getFarmingTip() {
    if (_weatherData == null) return 'Check weather conditions before farming activities.';
    
    final temp = _weatherData!.temperature;
    final humidity = _weatherData!.humidity;
    
    if (temp > 30) {
      return 'High temperature today. Water your crops early morning or evening.';
    } else if (temp < 15) {
      return 'Cool weather. Good time for planting winter crops.';
    } else if (humidity > 80) {
      return 'High humidity. Watch for fungal diseases in crops.';
    } else {
      return 'Perfect weather for most farming activities. Make the most of it!';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}