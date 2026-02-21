import 'package:flutter/material.dart';

// Enums for market data
enum PriceTrend { up, down, stable }
enum MarketChartType { line, bar }
enum AlertType { above, below }
enum NotificationMethod { push, email, both }

// Main market price model
class MarketPrice {
  final String id;
  final String cropName;
  final String marketName;
  final String district;
  final double pricePerKg;
  final double priceChangePercent;
  final PriceTrend trend;
  final DateTime updatedAt;
  final double demandIndex;
  final double scarcityIndex;
  final String qualityGrade;
  final int transportationCost;

  const MarketPrice({
    required this.id,
    required this.cropName,
    required this.marketName,
    required this.district,
    required this.pricePerKg,
    required this.priceChangePercent,
    required this.trend,
    required this.updatedAt,
    required this.demandIndex,
    required this.scarcityIndex,
    required this.qualityGrade,
    required this.transportationCost,
  });

  // Computed properties for UI
  Color get trendColor => trend == PriceTrend.up ? Colors.green : Colors.red;
  String get trendIcon => trend == PriceTrend.up ? '↗' : '↘';
  String get trendText => trend == PriceTrend.up ? 'Rising' : 'Falling';
  String get formattedPrice => 'Rs. ${pricePerKg.toStringAsFixed(2)}';
  String get formattedDate => '${updatedAt.day}/${updatedAt.month}';
}

// Price alert model
class PriceAlert {
  final String cropName;
  final String district;
  final double currentPrice;
  final double priceChange;
  final PriceTrend trend;
  final String message;
  final DateTime createdAt;

  PriceAlert({
    required this.cropName,
    required this.district,
    required this.currentPrice,
    required this.priceChange,
    required this.trend,
    required this.message,
    required this.createdAt,
  });

  Color get trendColor => trend == PriceTrend.up ? Colors.green : Colors.red;
  String get formattedPriceChange =>
      '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%';
}

// Chart data model for visualization
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

// Market service for data operations
class MarketService {
  Future<void> initialize() async {
    // Initialize market data service
  }

  Future<List<MarketPrice>> getDailyMarketPrices() async {
    // Fetch from API or database
    return [];
  }

  Future<void> setPriceAlert({
    required String cropName,
    required double targetPrice,
    required AlertType alertType,
    required NotificationMethod notificationMethod,
  }) async {
    // Save alert to database
  }

  Future<List<PriceAlert>> getPriceAlerts() async {
    // Fetch active alerts
    return [];
  }
}