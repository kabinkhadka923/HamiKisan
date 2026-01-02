import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/weather_models.dart';

class FarmerListing {
  final String farmerName;
  final String location;
  final String productName;
  final double price;
  final String unit;
  final String phone;
  final DateTime timestamp;

  FarmerListing({
    required this.farmerName,
    required this.location,
    required this.productName,
    required this.price,
    required this.unit,
    required this.phone,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'farmerName': farmerName,
    'location': location,
    'productName': productName,
    'price': price,
    'unit': unit,
    'phone': phone,
    'timestamp': timestamp.toIso8601String(),
  };

  factory FarmerListing.fromJson(Map<String, dynamic> json) => FarmerListing(
    farmerName: json['farmerName'],
    location: json['location'],
    productName: json['productName'],
    price: json['price'],
    unit: json['unit'],
    phone: json['phone'],
    timestamp: DateTime.parse(json['timestamp']),
  );

  MarketPrice toMarketPrice() => MarketPrice(
    productName: '$productName (by $farmerName)',
    minPrice: price,
    maxPrice: price,
    avgPrice: price,
    priceChangePercent: 0,
    location: location,
    timestamp: timestamp,
    demandIndex: 0.5,
    scarcityIndex: 0.5,
  );
}

class FarmerListingService {
  static const _key = 'farmer_listings';
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<FarmerListing>> loadListings() async {
    await initialize();
    final data = _prefs!.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => FarmerListing.fromJson(e)).toList();
  }

  Future<void> saveListings(List<FarmerListing> listings) async {
    await initialize();
    final jsonList = listings.map((e) => e.toJson()).toList();
    await _prefs!.setString(_key, json.encode(jsonList));
  }

  Future<void> addListing(FarmerListing listing) async {
    final listings = await loadListings();
    listings.add(listing);
    await saveListings(listings);
  }

  Future<void> deleteListing(int index) async {
    final listings = await loadListings();
    listings.removeAt(index);
    await saveListings(listings);
  }
}
