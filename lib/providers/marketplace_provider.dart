import 'package:flutter/material.dart';
import 'dart:async';
import '../models/marketplace_models.dart';
import '../services/marketplace_database_service.dart';

class MarketplaceProvider with ChangeNotifier {
  final MarketplaceDatabaseService _dbService = MarketplaceDatabaseService();
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
    scheduleMicrotask(() => notifyListeners());

    try {
      _products = await _dbService.getAllProducts();
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
    final _ = buyerId;
    if (_cart.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final groupedItems = <String, OrderItem>{};
      for (final product in _cart) {
        final current = groupedItems[product.id];
        if (current == null) {
          groupedItems[product.id] = OrderItem(
            productId: product.id,
            productName: product.title,
            quantity: 1,
            unitPrice: product.price,
            totalPrice: product.price,
          );
        } else {
          final nextQuantity = current.quantity + 1;
          groupedItems[product.id] = OrderItem(
            productId: current.productId,
            productName: current.productName,
            quantity: nextQuantity,
            unitPrice: current.unitPrice,
            totalPrice: current.unitPrice * nextQuantity,
          );
        }
      }

      final createdOrder = await _dbService.createOrder(
        deliveryAddress: deliveryAddress,
        notes: notes,
        items: groupedItems.values.toList(),
      );

      _orders.insert(0, createdOrder);
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
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: sellerId,
        sellerName: 'Current User',
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

      final createdProduct = await _dbService.insertProduct(newProduct);
      _products.insert(0, createdProduct);
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
