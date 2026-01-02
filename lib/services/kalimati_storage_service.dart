import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

class KalimatiStorageService {
  static const String _storageKey = 'manual_kalimati_items';
  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveItems(List<MarketPrice> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await _prefs?.setString(_storageKey, json.encode(jsonList));
  }

  Future<List<MarketPrice>> loadItems() async {
    final jsonString = _prefs?.getString(_storageKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MarketPrice.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addItem(MarketPrice item) async {
    final items = await loadItems();
    items.add(item);
    await saveItems(items);
  }

  Future<void> updateItem(int index, MarketPrice item) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items[index] = item;
      await saveItems(items);
    }
  }

  Future<void> deleteItem(int index) async {
    final items = await loadItems();
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      await saveItems(items);
    }
  }

  Future<void> clearAll() async {
    await _prefs?.remove(_storageKey);
  }
}
