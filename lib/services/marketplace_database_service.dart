import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/marketplace_models.dart';
import 'auth_service.dart';
import 'backend_config.dart';

class MarketplaceDatabaseService {
  final Map<String, String> _headers = const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication required');
    }
    return {
      ..._headers,
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Product>> getAllProducts() async {
    final response = await http.get(
      BackendConfig.uri('/api/products', query: {'status': 'approved'}),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products');
    }

    final productsList = json.decode(response.body) as List<dynamic>;
    return productsList
        .map((jsonItem) => _mapProductFromBackend(Map<String, dynamic>.from(jsonItem)))
        .toList();
  }

  Future<Product> insertProduct(Product product) async {
    final response = await http.post(
      BackendConfig.uri('/api/products'),
      headers: await _authHeaders(),
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'category': product.category,
        'subCategory': product.subCategory,
        'price': product.price,
        'unit': product.unit,
        'quantity': product.quantity,
        'location': product.location,
        'district': product.district,
        'qualityGrade': product.qualityGrade,
        'isOrganic': product.isOrganic,
        'imageUrls': product.imageUrls,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create product');
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    return _mapProductFromBackend(payload);
  }

  Future<void> updateProduct(Product product) async {
    await http.patch(
      BackendConfig.uri('/api/products/${product.id}/status'),
      headers: await _authHeaders(),
      body: json.encode({'status': product.status}),
    );
  }

  Future<List<Order>> getUserOrders(String userId) async {
    final _ = userId;
    final response = await http.get(
      BackendConfig.uri('/api/orders/mine'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders');
    }

    final payload = json.decode(response.body) as Map<String, dynamic>;
    final ordersList = (payload['orders'] as List<dynamic>? ?? []);
    return ordersList
        .map((jsonItem) => Order.fromJson(Map<String, dynamic>.from(jsonItem)))
        .toList();
  }

  Future<Order> insertOrder(Order order) async {
    return createOrder(
      deliveryAddress: order.deliveryAddress,
      notes: order.notes,
      items: order.items,
    );
  }

  Future<Order> createOrder({
    required String deliveryAddress,
    String? notes,
    required List<OrderItem> items,
  }) async {
    final response = await http.post(
      BackendConfig.uri('/api/orders'),
      headers: await _authHeaders(),
      body: json.encode({
        'deliveryAddress': deliveryAddress,
        'notes': notes,
        'items': items
            .map((item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                })
            .toList(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to place order');
    }

    return Order.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Product _mapProductFromBackend(Map<String, dynamic> raw) {
    int parseDate(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        final parsedInt = int.tryParse(value);
        if (parsedInt != null) return parsedInt;
        final parsedDate = DateTime.tryParse(value);
        if (parsedDate != null) return parsedDate.millisecondsSinceEpoch;
      }
      if (value is DateTime) return value.millisecondsSinceEpoch;
      return DateTime.now().millisecondsSinceEpoch;
    }

    final mapped = <String, dynamic>{
      'id': raw['id'].toString(),
      'title': raw['title'],
      'description': raw['description'],
      'price': raw['price'],
      'unit': raw['unit'] ?? 'unit',
      'category': raw['category'] ?? 'General',
      'subCategory': raw['subCategory'] ?? raw['category'] ?? 'General',
      'sellerId': raw['sellerId']?.toString() ?? '',
      'sellerName': raw['sellerName'] ?? 'Unknown Seller',
      'imageUrls':
          (raw['imageUrls'] as List<dynamic>? ?? []).map((item) => item.toString()).toList(),
      'quantity': (raw['quantity'] as num?)?.toDouble() ?? 0.0,
      'unitSymbol': raw['unit'] ?? 'unit',
      'location': raw['location'] ?? 'Unknown',
      'district': raw['district'] ?? 'Unknown',
      'qualityGrade': raw['qualityGrade'] ?? 'B',
      'isOrganic': raw['isOrganic'] == true,
      'status': raw['status'] ?? 'pending',
      'isVerified': raw['status'] == 'approved',
      'createdAt': parseDate(raw['createdAt']),
      'updatedAt': raw['updatedAt'] == null ? null : parseDate(raw['updatedAt']),
    };

    return Product.fromJson(mapped);
  }
}
