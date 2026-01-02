import 'package:flutter/material.dart';
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
    notifyListeners();

    try {
      // Simulate API call with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      _products = [
        Product(
          id: '1',
          name: 'Organic Rice',
          description: 'Premium quality organic rice from local farmers',
          price: 85.0,
          unit: 'kg',
          category: 'Crops',
          sellerId: 'seller1',
          sellerName: 'Ram Bahadur',
          quantity: 100,
          createdAt: DateTime.now(),
          location: 'Kathmandu',
        ),
        Product(
          id: '2',
          name: 'Fresh Tomatoes',
          description: 'Farm fresh tomatoes, harvested today',
          price: 120.0,
          unit: 'kg',
          category: 'Crops',
          sellerId: 'seller2',
          sellerName: 'Sita Devi',
          quantity: 50,
          createdAt: DateTime.now(),
          location: 'Pokhara',
        ),
        Product(
          id: '3',
          name: 'Wheat Seeds',
          description: 'High quality wheat seeds for planting',
          price: 150.0,
          unit: 'kg',
          category: 'Seeds',
          sellerId: 'seller3',
          sellerName: 'Hari Prasad',
          quantity: 25,
          createdAt: DateTime.now(),
          location: 'Chitwan',
        ),
        Product(
          id: '4',
          name: 'Organic Fertilizer',
          description: 'Natural organic fertilizer for healthy crops',
          price: 200.0,
          unit: 'bag',
          category: 'Fertilizer',
          sellerId: 'seller4',
          sellerName: 'Krishna Bahadur',
          quantity: 30,
          createdAt: DateTime.now(),
          location: 'Lalitpur',
        ),
      ];
    } catch (e) {
      _error = 'Failed to load products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getFilteredProducts() {
    if (_selectedCategory == 'All') {
      return _products;
    }
    return _products.where((product) => product.category == _selectedCategory).toList();
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
        items: _cart.map((product) => OrderItem(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
          totalPrice: product.price,
        )).toList(),
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
}