import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marketplace_models.dart';

class MarketplaceDatabaseService {
  static const String _productsKey = 'marketplace_products';
  static const String _ordersKey = 'marketplace_orders';

  Future<List<Product>> getAllProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString(_productsKey);

      if (productsJson == null) {
        // Initialize with sample products
        await _initializeSampleProducts();
        return getAllProducts();
      }

      final productsList = json.decode(productsJson) as List;
      return productsList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> insertProduct(Product product) async {
    try {
      final products = await getAllProducts();
      products.add(product);

      final prefs = await SharedPreferences.getInstance();
      final productsJson =
          json.encode(products.map((p) => p.toJson()).toList());
      await prefs.setString(_productsKey, productsJson);
    } catch (e) {
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      final products = await getAllProducts();
      final index = products.indexWhere((p) => p.id == product.id);

      if (index != -1) {
        products[index] = product;

        final prefs = await SharedPreferences.getInstance();
        final productsJson =
            json.encode(products.map((p) => p.toJson()).toList());
        await prefs.setString(_productsKey, productsJson);
      }
    } catch (e) {
    }
  }

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);

      if (ordersJson == null) return [];

      final ordersList = json.decode(ordersJson) as List;
      final allOrders = ordersList.map((json) => Order.fromJson(json)).toList();

      return allOrders
          .where((order) => order.buyerId == userId || order.sellerId == userId)
          .toList();
    } catch (e) {

      return [];
    }
  }

  Future<void> insertOrder(Order order) async {
    try {
      final orders = await _getAllOrders();
      orders.add(order);

      final prefs = await SharedPreferences.getInstance();
      final ordersJson = json.encode(orders.map((o) => o.toJson()).toList());
      await prefs.setString(_ordersKey, ordersJson);
    } catch (e) {

    }
  }

  Future<List<Order>> _getAllOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);

      if (ordersJson == null) return [];

      final ordersList = json.decode(ordersJson) as List;
      return ordersList.map((json) => Order.fromJson(json)).toList();
    } catch (e) {

      return [];
    }
  }

  Future<void> _initializeSampleProducts() async {
    final sampleProducts = [
      Product(
        id: 'product_1',
        sellerId: 'user_farmer_demo',
        sellerName: 'Demo Farmer',
        title: 'Premium Rice',
        category: 'Crops',
        subCategory: 'Rice',
        description: 'High quality organic rice from Kavre district',
        price: 85.0,
        unit: 'kg',
        unitSymbol: 'kg',
        quantity: 500.0,
        location: 'Kathmandu',
        district: 'Kavre',
        imageUrls: ['https://example.com/rice.jpg'],
        status: 'active',
        isVerified: true,
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'product_2',
        sellerId: 'user_farmer_demo',
        sellerName: 'Demo Farmer',
        title: 'Organic Tomatoes',
        category: 'Crops',
        subCategory: 'Vegetables',
        description: 'Fresh organic tomatoes, pesticide-free',
        price: 120.0,
        unit: 'kg',
        unitSymbol: 'kg',
        quantity: 200.0,
        location: 'Pokhara',
        district: 'Kaski',
        imageUrls: ['https://example.com/tomatoes.jpg'],
        status: 'active',
        isVerified: true,
        isOrganic: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'product_3',
        sellerId: 'user_farmer_demo',
        sellerName: 'Demo Farmer',
        title: 'NPK Fertilizer',
        category: 'Fertilizer',
        subCategory: 'Fertilizer',
        description: 'Balanced NPK fertilizer for all crops',
        price: 45.0,
        unit: 'kg',
        unitSymbol: 'kg',
        quantity: 1000.0,
        location: 'Biratnagar',
        district: 'Morang',
        imageUrls: ['https://example.com/fertilizer.jpg'],
        status: 'active',
        isVerified: false,
        isOrganic: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final productsJson =
        json.encode(sampleProducts.map((p) => p.toJson()).toList());
    await prefs.setString(_productsKey, productsJson);
  }
}
