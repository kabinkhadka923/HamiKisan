import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';
import 'kalimati_storage_service.dart';
import 'farmer_listing_service.dart';

class MarketService {
  SharedPreferences? _prefs;
  List<MarketPrice>? _cachedMarketPrices;
  String? _kalimatiApiUrl;
  String? _kalimatiApiKey;
  final _storageService = KalimatiStorageService();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _kalimatiApiUrl = _prefs?.getString('kalimati_api_url');
    _kalimatiApiKey = _prefs?.getString('kalimati_api_key');
    await _storageService.initialize();
    await _loadCachedData();
  }

  Future<List<MarketPrice>> getDailyMarketPrices() async {
    try {
      final farmerService = FarmerListingService();
      await farmerService.initialize();
      final farmerListings = await farmerService.loadListings();
      final farmerPrices = farmerListings.map((e) => e.toMarketPrice()).toList();

      // Priority 1: Check for manually added items
      final manualItems = await _storageService.loadItems();
      if (manualItems.isNotEmpty) {
        _cachedMarketPrices = [...manualItems, ...farmerPrices];
        return _cachedMarketPrices!;
      }

      // Priority 2: Try to fetch from Kalimati API if configured
      if (_kalimatiApiUrl != null && _kalimatiApiUrl!.isNotEmpty) {
        final apiPrices = await _fetchFromKalimatiAPI();
        if (apiPrices.isNotEmpty) {
          _cachedMarketPrices = apiPrices;
          await _saveCachedData(apiPrices);
          return apiPrices;
        }
      }
      
      // Return cached data if available
      if (_cachedMarketPrices != null) {
        return _cachedMarketPrices!;
      }
      
      return [];
    } catch (e) {
      // Return cached data if available
      if (_cachedMarketPrices != null) {
        return _cachedMarketPrices!;
      }
      return [];
    }
  }

  Future<List<MarketPrice>> _fetchFromKalimatiAPI() async {
    try {
      final headers = _kalimatiApiKey != null && _kalimatiApiKey!.isNotEmpty
          ? {'Authorization': 'Bearer $_kalimatiApiKey'}
          : <String, String>{};
      
      final response = await http.get(
        Uri.parse(_kalimatiApiUrl!),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseKalimatiResponse(data);
      }
    } catch (e) {
      print('Kalimati API error: $e');
    }
    return [];
  }

  List<MarketPrice> _parseKalimatiResponse(dynamic data) {
    final List<MarketPrice> prices = [];
    try {
      if (data is List) {
        for (var item in data) {
          prices.add(MarketPrice(
            productName: item['commodity'] ?? item['name'] ?? 'Unknown',
            minPrice: (item['minimum'] ?? item['min_price'] ?? 0).toDouble(),
            maxPrice: (item['maximum'] ?? item['max_price'] ?? 0).toDouble(),
            avgPrice: (item['average'] ?? item['avg_price'] ?? 0).toDouble(),
            priceChangePercent: (item['change'] ?? 0).toDouble(),
            location: 'Kathmandu',
            timestamp: DateTime.now(),
            demandIndex: 0.7,
            scarcityIndex: 0.5,
          ));
        }
      }
    } catch (e) {
      print('Error parsing Kalimati data: $e');
    }
    return prices;
  }

  List<HotMarketItem> getHotMarketItems(List<MarketPrice> prices) {
    // Calculate profitability score and sort
    final sortedPrices = prices
        .map((price) => HotMarketItem.fromMarketPrice(price))
        .toList();

    // Sort by profitability score (highest first)
    sortedPrices.sort((a, b) => b.profitabilityScore.compareTo(a.profitabilityScore));

    // Return top 3 hot items
    return sortedPrices.take(3).toList();
  }

  List<MarketNotification> generatePriceAlerts(List<MarketPrice> prices) {
    final List<MarketNotification> alerts = [];

    for (final price in prices) {
      // Major price increase alerts
      if (price.priceChangePercent > 10) {
        alerts.add(MarketNotification(
          type: 'price',
          title: 'Price Surge Alert',
          message: '${price.productName} price increased by ${price.priceChangePercent.toStringAsFixed(1)}% today. Consider selling if you have stock.',
          timestamp: DateTime.now(),
          isUrgent: price.priceChangePercent > 20,
        ));
      }
      
      // Price drop alerts for tracked items
      if (price.priceChangePercent < -5) {
        alerts.add(MarketNotification(
          type: 'price',
          title: 'Price Drop Alert',
          message: '${price.productName} price decreased by ${price.priceChangePercent.abs().toStringAsFixed(1)}%. Good time to buy for consumption.',
          timestamp: DateTime.now(),
          isUrgent: false,
        ));
      }

      // High demand, low supply alerts
      if (price.demandIndex > 0.8 && price.scarcityIndex > 0.7) {
        alerts.add(MarketNotification(
          type: 'alert',
          title: 'High Demand Alert',
          message: 'High demand and limited supply for ${price.productName}. Prices likely to increase further.',
          timestamp: DateTime.now(),
          isUrgent: true,
        ));
      }
    }

    return alerts;
  }

  Map<String, List<MarketPrice>> getPricesByLocation(List<MarketPrice> prices) {
    final Map<String, List<MarketPrice>> locationPrices = {};
    
    for (final price in prices) {
      if (!locationPrices.containsKey(price.location)) {
        locationPrices[price.location] = [];
      }
      locationPrices[price.location]!.add(price);
    }
    
    return locationPrices;
  }

  List<MarketPrice> getPricesByProduct(List<MarketPrice> prices, String productName) {
    return prices.where((price) => 
      price.productName.toLowerCase().contains(productName.toLowerCase())
    ).toList();
  }

  double getPriceDifference(String productName, String location1, String location2, List<MarketPrice> prices) {
    final prices1 = getPricesByProduct(prices, productName)
        .where((price) => price.location == location1)
        .toList();
    final prices2 = getPricesByProduct(prices, productName)
        .where((price) => price.location == location2)
        .toList();
    
    if (prices1.isEmpty || prices2.isEmpty) return 0.0;
    
    return prices2.first.avgPrice - prices1.first.avgPrice;
  }

  Future<void> _saveCachedData(List<MarketPrice> prices) async {
    if (_prefs == null) return;
    
    final List<Map<String, dynamic>> cachedData = prices.map((price) => price.toJson()).toList();
    await _prefs!.setString('cached_market_prices', json.encode(cachedData));
  }

  Future<void> _loadCachedData() async {
    if (_prefs == null) return;
    
    final cachedString = _prefs!.getString('cached_market_prices');
    if (cachedString != null) {
      try {
        final List<dynamic> cachedList = json.decode(cachedString);
        _cachedMarketPrices = cachedList.map((json) => MarketPrice.fromJson(json)).toList();
      } catch (e) {
        print('Error loading cached market data: $e');
      }
    }
  }
}

class MarketNotification {
  final String type; // 'price', 'alert'
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isUrgent;

  const MarketNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUrgent = false,
  });
}
