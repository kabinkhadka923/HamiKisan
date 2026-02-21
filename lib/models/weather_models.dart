import 'package:flutter/material.dart';

class WeatherData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String weatherType;
  final int rainChance;
  final String farmingTip;
  final String location;
  final DateTime timestamp;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherType,
    required this.rainChance,
    required this.farmingTip,
    required this.location,
    required this.timestamp,
  });
}

class WeatherNotification {
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isUrgent;

  const WeatherNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isUrgent = false,
  });
}

enum AlertType { heat, frost, rain, wind, drought, general }

enum Severity { low, medium, high }

class WeatherAlert {
  final AlertType type;
  final String title;
  final String message;
  final Severity severity;
  final DateTime timestamp;
  final bool actionable;
  final String? actionTip;
  final String? icon;

  WeatherAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.actionable = false,
    this.actionTip,
    this.icon,
  });
}

enum PriceTrend { up, down, stable }

class MarketPrice {
  final String productName;
  final double avgPrice;
  final double minPrice;
  final double maxPrice;
  final double priceChangePercent;
  final String location;
  final DateTime timestamp;
  final double demandIndex;
  final double scarcityIndex;

  const MarketPrice({
    required this.productName,
    required this.avgPrice,
    required this.minPrice,
    required this.maxPrice,
    required this.priceChangePercent,
    required this.location,
    required this.timestamp,
    required this.demandIndex,
    required this.scarcityIndex,
  });

  // Getters for MarketPricesScreen
  String get cropName => productName;
  double get pricePerKg => avgPrice;
  String get district => location;
  String get marketName => 'Local Market';
  PriceTrend get trend {
    if (priceChangePercent > 0) return PriceTrend.up;
    if (priceChangePercent < 0) return PriceTrend.down;
    return PriceTrend.stable;
  }

  Color get trendColor {
    switch (trend) {
      case PriceTrend.up:
        return Colors.red;
      case PriceTrend.down:
        return Colors.green;
      case PriceTrend.stable:
        return Colors.grey;
    }
  }

  String get trendIcon {
    switch (trend) {
      case PriceTrend.up:
        return '↑';
      case PriceTrend.down:
        return '↓';
      case PriceTrend.stable:
        return '→';
    }
  }

  String get trendText {
    switch (trend) {
      case PriceTrend.up:
        return '+${priceChangePercent.toStringAsFixed(1)}%';
      case PriceTrend.down:
        return '${priceChangePercent.toStringAsFixed(1)}%';
      case PriceTrend.stable:
        return 'Stable';
    }
  }

  String get formattedPrice => 'Rs. ${avgPrice.toStringAsFixed(0)}';
  String get formattedDate =>
      '${timestamp.day}/${timestamp.month}/${timestamp.year}';

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      productName: json['productName'] as String,
      avgPrice: (json['avgPrice'] as num).toDouble(),
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      priceChangePercent: (json['priceChangePercent'] as num).toDouble(),
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      demandIndex: (json['demandIndex'] as num).toDouble(),
      scarcityIndex: (json['scarcityIndex'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'avgPrice': avgPrice,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'priceChangePercent': priceChangePercent,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'demandIndex': demandIndex,
      'scarcityIndex': scarcityIndex,
    };
  }
}

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

  String get formattedPriceChange =>
      '${priceChange > 0 ? '+' : ''}${priceChange.toStringAsFixed(1)}%';
  Color get trendColor => trend == PriceTrend.up ? Colors.red : Colors.green;
}

class HotMarketItem {
  final String productName;
  final double avgPrice;
  final double priceChangePercent;
  final double profitabilityScore;
  final String location;

  const HotMarketItem({
    required this.productName,
    required this.avgPrice,
    required this.priceChangePercent,
    required this.profitabilityScore,
    required this.location,
  });

  factory HotMarketItem.fromMarketPrice(MarketPrice price) {
    final profitScore = (price.priceChangePercent * 0.4) +
        (price.demandIndex * 30) +
        (price.scarcityIndex * 30);
    return HotMarketItem(
      productName: price.productName,
      avgPrice: price.avgPrice,
      priceChangePercent: price.priceChangePercent,
      profitabilityScore: profitScore,
      location: price.location,
    );
  }
}
