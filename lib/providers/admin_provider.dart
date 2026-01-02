import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  // State variables
  List<FarmerProfile> _farmers = [];
  List<KisanDoctorProfile> _doctors = [];
  List<MarketplaceProduct> _products = [];
  List<MarketPrice> _marketPrices = [];
  List<AdminNotification> _notifications = [];
  List<CommunityPost> _communityPosts = [];
  List<SecurityLog> _securityLogs = [];
  AdminDashboardMetrics? _dashboardMetrics;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<FarmerProfile> get farmers => _farmers;
  List<KisanDoctorProfile> get doctors => _doctors;
  List<MarketplaceProduct> get products => _products;
  List<MarketPrice> get marketPrices => _marketPrices;
  List<AdminNotification> get notifications => _notifications;
  List<CommunityPost> get communityPosts => _communityPosts;
  List<SecurityLog> get securityLogs => _securityLogs;
  AdminDashboardMetrics? get dashboardMetrics => _dashboardMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Farmers Management
  Future<void> loadFarmers() async {
    _setLoading(true);
    try {
      _farmers = await _adminService.getAllFarmers();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveFarmer(String farmerId) async {
    try {
      await _adminService.approveFarmer(farmerId);
      _farmers = _farmers.map((f) => f.id == farmerId ? f : f).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectFarmer(String farmerId) async {
    try {
      await _adminService.rejectFarmer(farmerId);
      _farmers.removeWhere((f) => f.id == farmerId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> banFarmer(String farmerId) async {
    try {
      await _adminService.banFarmer(farmerId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Doctors Management
  Future<void> loadDoctors() async {
    _setLoading(true);
    try {
      _doctors = await _adminService.getAllDoctors();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveDoctorRegistration(String doctorId) async {
    try {
      await _adminService.approveDoctorRegistration(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> assignDistrictToDoctor(String doctorId, List<String> districts) async {
    try {
      await _adminService.assignDistrictToDoctor(doctorId, districts);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> suspendDoctor(String doctorId) async {
    try {
      await _adminService.suspendDoctor(doctorId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Marketplace Management
  Future<void> loadPendingProducts() async {
    _setLoading(true);
    try {
      _products = await _adminService.getPendingProducts();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approveProduct(String productId) async {
    try {
      await _adminService.approveProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectProduct(String productId, String reason) async {
    try {
      await _adminService.rejectProduct(productId, reason);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProductPrice(String productId, double newPrice) async {
    try {
      await _adminService.updateProductPrice(productId, newPrice);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Market Prices
  Future<void> loadMarketPrices() async {
    _setLoading(true);
    try {
      _marketPrices = await _adminService.getTodaysPrices();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMarketPrice(String item, double price, String district) async {
    try {
      await _adminService.updateMarketPrice(item, price, district);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Notifications
  Future<void> sendNotification({
    required String title,
    required String body,
    String? receiverId,
    String? district,
    bool toAll = false,
  }) async {
    try {
      await _adminService.sendNotification(
        title: title,
        body: body,
        receiverId: receiverId,
        district: district,
        toAll: toAll,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadNotifications() async {
    try {
      _notifications = await _adminService.getNotifications();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Community Posts
  Future<void> loadPendingPosts() async {
    _setLoading(true);
    try {
      _communityPosts = await _adminService.getPendingPosts();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> approvePost(String postId) async {
    try {
      await _adminService.approvePost(postId);
      _communityPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _adminService.deletePost(postId);
      _communityPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Security Logs
  Future<void> loadSecurityLogs() async {
    try {
      _securityLogs = await _adminService.getSecurityLogs();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String ipAddress,
    required String details,
  }) async {
    try {
      await _adminService.logAdminAction(
        adminId: adminId,
        action: action,
        ipAddress: ipAddress,
        details: details,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Dashboard
  Future<void> loadDashboardMetrics() async {
    _setLoading(true);
    try {
      _dashboardMetrics = await _adminService.getDashboardMetrics();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // System Operations (Super Admin)
  Future<void> performSystemBackup() async {
    try {
      await _adminService.performSystemBackup();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    try {
      await _adminService.clearCache();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleMaintenanceMode(bool enable) async {
    try {
      await _adminService.toggleMaintenanceMode(enable);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _farmers = [];
    _doctors = [];
    _products = [];
    _marketPrices = [];
    _notifications = [];
    _communityPosts = [];
    _securityLogs = [];
    _dashboardMetrics = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
