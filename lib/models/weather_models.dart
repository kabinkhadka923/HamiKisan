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