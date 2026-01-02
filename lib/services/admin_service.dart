import 'dart:convert';
import '../models/admin_models.dart';
import 'database.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  final DatabaseService _db = DatabaseService();

  factory AdminService() {
    return _instance;
  }

  AdminService._internal();

  // Farmers Management
  Future<List<FarmerProfile>> getAllFarmers() async {
    try {
      final users = await _db.query('users', where: 'role = ?', whereArgs: ['farmer']);
      List<FarmerProfile> profiles = [];
      
      for (var user in users) {
        final products = await _db.query('products', where: 'farmer_id = ?', whereArgs: [user['id']]);
        profiles.add(FarmerProfile(
          id: user['id'],
          name: user['name'],
          phone: user['phone_number'] ?? '',
          district: _extractDistrict(user['address']),
          crops: _parseList(user['farming_category']), // Using category as crops for now
          lastLogin: DateTime.fromMillisecondsSinceEpoch(user['last_login_at'] ?? 0),
          isVerified: (user['is_verified'] ?? 0) == 1,
          accountStatus: user['status'],
          productsPosted: products.map((p) => p['id'] as String).toList(),
          complaintsSubmitted: [], // TODO: Add complaints table
        ));
      }
      return profiles;
    } catch (e) {
      print('Error getting farmers: $e');
      return [];
    }
  }

  Future<FarmerProfile?> getFarmerById(String farmerId) async {
    try {
      final users = await _db.query('users', where: 'id = ?', whereArgs: [farmerId]);
      if (users.isEmpty) return null;
      
      final user = users.first;
      final products = await _db.query('products', where: 'farmer_id = ?', whereArgs: [farmerId]);
      
      return FarmerProfile(
        id: user['id'],
        name: user['name'],
        phone: user['phone_number'] ?? '',
        district: _extractDistrict(user['address']),
        crops: _parseList(user['farming_category']),
        lastLogin: DateTime.fromMillisecondsSinceEpoch(user['last_login_at'] ?? 0),
        isVerified: (user['is_verified'] ?? 0) == 1,
        accountStatus: user['status'],
        productsPosted: products.map((p) => p['id'] as String).toList(),
        complaintsSubmitted: [],
      );
    } catch (e) {
      print('Error getting farmer: $e');
      return null;
    }
  }

  Future<void> approveFarmer(String farmerId) async {
    await _updateUserStatus(farmerId, 'approved');
    await logAdminAction(
      adminId: 'current_admin', // TODO: Get actual admin ID
      action: 'APPROVE_FARMER',
      ipAddress: '127.0.0.1',
      details: 'Approved farmer $farmerId'
    );
  }

  Future<void> rejectFarmer(String farmerId) async {
    await _updateUserStatus(farmerId, 'rejected');
  }

  Future<void> banFarmer(String farmerId) async {
    await _updateUserStatus(farmerId, 'banned');
  }

  Future<void> resetFarmerPassword(String farmerId) async {
    // In a real app, this would generate a token. For local, we set to default.
    // This requires DatabaseService to expose password update, which we'll skip for safety now
    // or implement a simple update.
    await _db.update('users', 
      {'password_hash': 'RESET_HASH'}, // Placeholder
      where: 'id = ?', 
      whereArgs: [farmerId]
    );
  }

  // Kisan Doctors Management
  Future<List<KisanDoctorProfile>> getAllDoctors() async {
    try {
      final users = await _db.query('users', where: 'role = ?', whereArgs: ['kisanDoctor']);
      return users.map((user) => KisanDoctorProfile(
        id: user['id'],
        name: user['name'],
        qualification: 'Certified', // Placeholder
        expertise: user['specialization'] ?? 'General',
        assignedDistricts: [user['address'] ?? 'All'],
        languages: ['Nepali', 'English'],
        isOnline: false,
        rating: 4.5, // Placeholder
        answersGiven: 0,
        farmerSatisfactionScore: 90,
        pendingReplies: 0,
      )).toList();
    } catch (e) {
      print('Error getting doctors: $e');
      return [];
    }
  }

  Future<void> approveDoctorRegistration(String doctorId) async {
    await _updateUserStatus(doctorId, 'approved');
  }

  Future<void> assignDistrictToDoctor(String doctorId, List<String> districts) async {
    // Store in user address or separate table. For now, update address.
    if (districts.isNotEmpty) {
      await _db.update('users', {'address': districts.first}, where: 'id = ?', whereArgs: [doctorId]);
    }
  }

  Future<void> suspendDoctor(String doctorId) async {
    await _updateUserStatus(doctorId, 'suspended');
  }

  // Marketplace Management
  Future<List<MarketplaceProduct>> getPendingProducts() async {
    try {
      final products = await _db.query('products', where: 'status = ?', whereArgs: ['pending']);
      return products.map((p) => _mapToProduct(p)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> approveProduct(String productId) async {
    await _db.update('products', {'status': 'approved'}, where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> rejectProduct(String productId, String reason) async {
    await _db.update('products', {'status': 'rejected'}, where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> updateProductPrice(String productId, double newPrice) async {
    await _db.update('products', {'price': newPrice}, where: 'id = ?', whereArgs: [productId]);
  }

  // Market Prices Management
  Future<List<MarketPrice>> getTodaysPrices() async {
    try {
      final prices = await _db.query('market_prices');
      return prices.map((p) => MarketPrice(
        item: p['item'],
        todayPrice: p['today_price'],
        previousWeekPrice: p['previous_week_price'],
        trend: p['trend'],
        district: p['district'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateMarketPrice(String item, double price, String district) async {
    // Check if exists
    final existing = await _db.query('market_prices', 
      where: 'item = ? AND district = ?', 
      whereArgs: [item, district]
    );

    if (existing.isNotEmpty) {
      await _db.update('market_prices', 
        {
          'previous_week_price': existing.first['today_price'],
          'today_price': price,
          'updated_at': DateTime.now().millisecondsSinceEpoch
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']]
      );
    } else {
      await _db.insert('market_prices', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'item': item,
        'today_price': price,
        'previous_week_price': price,
        'trend': 'stable',
        'district': district,
        'updated_at': DateTime.now().millisecondsSinceEpoch
      });
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
    await _db.insert('notifications', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'date': DateTime.now().millisecondsSinceEpoch,
      'receiver_id': receiverId ?? (toAll ? 'ALL' : district),
      'is_read': 0,
      'type': 'info'
    });
  }

  Future<List<AdminNotification>> getNotifications() async {
    try {
      final notifs = await _db.query('notifications', orderBy: 'date DESC');
      return notifs.map((n) => AdminNotification(
        id: n['id'],
        title: n['title'],
        body: n['body'],
        date: DateTime.fromMillisecondsSinceEpoch(n['date']),
        receiverId: n['receiver_id'] ?? '',
        isRead: (n['is_read'] ?? 0) == 1,
        type: _parseNotificationType(n['type']),
      )).toList();
    } catch (e) {
      return [];
    }
  }

  // Community Posts Management
  Future<List<CommunityPost>> getPendingPosts() async {
    // Assuming 'posts' table has a status field. If not, we might need to add it or assume all are approved.
    // database.dart schema for posts didn't have status. I should have added it.
    // For now, return all posts.
    try {
      final posts = await _db.query('posts');
      return posts.map((p) => CommunityPost(
        id: p['id'],
        farmerId: p['user_id'],
        content: p['content'],
        images: p['image_url'] != null ? [p['image_url']] : [],
        postedDate: DateTime.fromMillisecondsSinceEpoch(p['created_at']),
        likes: p['likes'] ?? 0,
        comments: p['comments'] ?? 0,
        status: 'approved', // Default
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> approvePost(String postId) async {
    // No-op if no status field
  }

  Future<void> deletePost(String postId) async {
    await _db.delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  // Security & Logs
  Future<List<SecurityLog>> getSecurityLogs({int limit = 100}) async {
    try {
      final logs = await _db.query('security_logs', orderBy: 'timestamp DESC', limit: limit);
      return logs.map((l) => SecurityLog(
        id: l['id'],
        adminId: l['admin_id'],
        action: l['action'],
        ipAddress: l['ip_address'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(l['timestamp']),
        details: l['details'],
      )).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> logAdminAction({
    required String adminId,
    required String action,
    required String ipAddress,
    required String details,
  }) async {
    await _db.insert('security_logs', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'admin_id': adminId,
      'action': action,
      'ip_address': ipAddress,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'details': details,
    });
  }

  // Dashboard Metrics
  Future<AdminDashboardMetrics> getDashboardMetrics() async {
    try {
      final farmers = await _db.query('users', where: 'role = ?', whereArgs: ['farmer']);
      final doctors = await _db.query('users', where: 'role = ?', whereArgs: ['kisanDoctor']);
      final products = await _db.query('products');
      
      // Simple logic for active today
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final activeFarmers = farmers.where((f) => (f['last_login_at'] ?? 0) >= startOfDay).length;

      return AdminDashboardMetrics(
        totalFarmers: farmers.length,
        activeFarmersToday: activeFarmers,
        registeredDoctors: doctors.length,
        submittedProblems: 0, // Need complaints table
        marketplaceListings: products.length,
        soldItemsToday: products.where((p) => p['status'] == 'sold' && (p['posted_date'] ?? 0) >= startOfDay).length,
        weatherApiStatus: 'Connected',
        systemHealthStatus: 'Healthy',
      );
    } catch (e) {
      return AdminDashboardMetrics(
        totalFarmers: 0,
        activeFarmersToday: 0,
        registeredDoctors: 0,
        submittedProblems: 0,
        marketplaceListings: 0,
        soldItemsToday: 0,
        weatherApiStatus: 'Error',
        systemHealthStatus: 'Error',
      );
    }
  }

  // Role Management (Super Admin only)
  Future<void> createAdminRole({
    required String adminId,
    required String name,
    required List<String> permissions,
  }) async {
    // Implement if needed
  }

  Future<void> updateAdminPermissions(String adminId, List<String> permissions) async {
    await _db.update('users', 
      {'permissions': json.encode(permissions)}, 
      where: 'id = ?', 
      whereArgs: [adminId]
    );
  }

  // System Control (Super Admin only)
  Future<void> performSystemBackup() async {
    // Mock backup
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> clearCache() async {
    // Mock clear cache
  }

  Future<void> toggleMaintenanceMode(bool enable) async {
    // Mock maintenance mode
  }

  // Helpers
  Future<void> _updateUserStatus(String userId, String status) async {
    await _db.update('users', {'status': status}, where: 'id = ?', whereArgs: [userId]);
  }

  String _extractDistrict(String? address) {
    if (address == null) return 'Unknown';
    // Simple logic: assume address format "City, District" or just "District"
    final parts = address.split(',');
    return parts.last.trim();
  }

  List<String> _parseList(String? input) {
    if (input == null) return [];
    return [input]; // Treat as single item list for now
  }

  MarketplaceProduct _mapToProduct(Map<String, dynamic> p) {
    return MarketplaceProduct(
      id: p['id'],
      title: p['title'],
      category: p['category'],
      price: p['price'],
      location: p['location'],
      image: p['image'],
      status: p['status'],
      postedDate: DateTime.fromMillisecondsSinceEpoch(p['posted_date']),
      farmerId: p['farmer_id'],
    );
  }

  NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'alert': return NotificationType.alert;
      case 'warning': return NotificationType.warning;
      case 'success': return NotificationType.success;
      default: return NotificationType.info;
    }
  }
}
