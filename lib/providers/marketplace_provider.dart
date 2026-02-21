import 'package:flutter/material.dart';
import 'dart:async';
import '../models/marketplace_models.dart';

class MarketplaceProvider with ChangeNotifier {
  List<Product> _products = [];
  final List<Order> _orders = [];
  final List<Product> _cart = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Product> get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  int get cartItemCount => _cart.length;

  Future<void> initialize() async {
    await loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    // Use scheduleMicrotask to avoid setState() during build error
    scheduleMicrotask(() => notifyListeners());

    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(seconds: 1));

      _products = [
        Product(
          id: '1',
          title: 'Organic Rice',
          description: 'Premium quality organic rice from local farmers',
          price: 85.0,
          unit: 'kg',
          unitSymbol: 'kg',
          category: 'Crops',
          subCategory: 'Rice',
          sellerId: 'seller1',
          sellerName: 'Ram Bahadur',
          imageUrls: ['https://example.com/rice.jpg'],
          quantity: 100,
          location: 'Kathmandu',
          district: 'Kathmandu',
          createdAt: DateTime.now(),
        ),
        Product(
          id: '2',
          title: 'Fresh Tomatoes',
          description: 'Farm fresh tomatoes, harvested today',
          price: 120.0,
          unit: 'kg',
          unitSymbol: 'kg',
          category: 'Crops',
          subCategory: 'Vegetables',
          sellerId: 'seller2',
          sellerName: 'Sita Devi',
          imageUrls: ['https://example.com/tomatoes.jpg'],
          quantity: 50,
          location: 'Pokhara',
          district: 'Kaski',
          createdAt: DateTime.now(),
        ),
        Product(
          id: '3',
          title: 'Wheat Seeds',
          description: 'High quality wheat seeds for planting',
          price: 150.0,
          unit: 'kg',
          unitSymbol: 'kg',
          category: 'Seeds',
          subCategory: 'Seeds',
          sellerId: 'seller3',
          sellerName: 'Hari Prasad',
          imageUrls: ['https://example.com/wheat_seeds.jpg'],
          quantity: 25,
          location: 'Chitwan',
          district: 'Chitwan',
          createdAt: DateTime.now(),
        ),
        Product(
          id: '4',
          title: 'Organic Fertilizer',
          description: 'Natural organic fertilizer for healthy crops',
          price: 200.0,
          unit: 'bag',
          unitSymbol: 'bag',
          category: 'Fertilizer',
          subCategory: 'Fertilizer',
          sellerId: 'seller4',
          sellerName: 'Krishna Bahadur',
          imageUrls: ['https://example.com/fertilizer.jpg'],
          quantity: 30,
          location: 'Lalitpur',
          district: 'Lalitpur',
          createdAt: DateTime.now(),
        ),
      ];
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      scheduleMicrotask(() => notifyListeners());
    }
  }

  List<Product> getFilteredProducts() {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  bool isInCart(Product product) {
    return _cart.any((item) => item.id == product.id);
  }

  double get cartTotal {
    return _cart.fold(0.0, (total, product) => total + product.price);
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<bool> placeOrder({
    required String buyerId,
    required String deliveryAddress,
    String? notes,
  }) async {
    if (_cart.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final order = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        buyerId: buyerId,
        sellerId: _cart.first.sellerId,
        items: _cart
            .map((product) => OrderItem(
                  productId: product.id,
                  productName: product.title,
                  quantity: 1,
                  unitPrice: product.price,
                  totalPrice: product.price,
                ))
            .toList(),
        totalAmount: cartTotal,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      _orders.add(order);
      clearCart();
      return true;
    } catch (e) {
      _error = 'Failed to place order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> addProduct({
    required String sellerId,
    required String title,
    required String description,
    required String category,
    required String subCategory,
    required List<String> imageUrls,
    required double price,
    required String unit,
    required double quantity,
    required String location,
    required String district,
    required String qualityGrade,
    required bool isOrganic,
    required List<String> tags,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: sellerId,
        sellerName:
            'Current User', // You might want to get this from AuthProvider
        title: title,
        description: description,
        category: category,
        subCategory: subCategory,
        imageUrls: imageUrls,
        price: price,
        unit: unit,
        unitSymbol: unit,
        quantity: quantity,
        location: location,
        district: district,
        qualityGrade: qualityGrade,
        isOrganic: isOrganic,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      _products.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
