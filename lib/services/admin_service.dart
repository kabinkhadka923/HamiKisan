import '../models/admin_models.dart';
import 'database.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  final DatabaseService _db = DatabaseService();

  factory AdminService() {
    return _instance;
  }

  AdminService._internal();

  // Compatibility methods
  Future<List<FarmerProfile>> getAllFarmers() async {
    final result = await getFarmers();
    return result.data;
  }

  Future<List<KisanDoctorProfile>> getAllDoctors() async {
    final result = await getDoctors();
    return result.data;
  }

  Future<void> updateProductPrice(String productId, double newPrice) async {
    await _db.update('products', {'price': newPrice},
        where: 'id = ?', whereArgs: [productId]);
  }

  // Farmers Management
  Future<PaginatedResult<FarmerProfile>> getFarmers({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      String whereClause = 'role = ?';
      List<dynamic> whereArgs = ['farmer'];

      if (filters != null) {
        if (filters['status'] != null) {
          whereClause += ' AND status = ?';
          whereArgs.add(filters['status']);
        }
        if (filters['district'] != null) {
          whereClause += ' AND address LIKE ?';
          whereArgs.add('%${filters['district']}%');
        }
      }

      final farmersCount = await _db.query('users',
          columns: ['COUNT(*) as count'],
          where: whereClause,
          whereArgs: whereArgs);
      final totalItems = farmersCount.first['count'] as int;
      final totalPages = (totalItems / pageSize).ceil();

      final users = await _db.query(
        'users',
        where: whereClause,
        whereArgs: whereArgs,
        limit: pageSize,
        offset: offset,
        orderBy: 'created_at DESC',
      );

      List<FarmerProfile> profiles = [];
      for (var user in users) {
        final products = await _db
            .query('products', where: 'farmer_id = ?', whereArgs: [user['id']]);
        profiles.add(FarmerProfile(
          id: user['id'],
          name: user['name'],
          phone: user['phone_number'] ?? '',
          email: user['email'] ?? '',
          district: _extractDistrict(user['address']),
          province: _extractProvince(user['address']),
          crops: _parseList(user['farming_category']),
          farmingCategories: _parseList(user['farming_category']),
          lastLogin:
              DateTime.fromMillisecondsSinceEpoch(user['last_login_at'] ?? 0),
          registeredAt:
              DateTime.fromMillisecondsSinceEpoch(user['created_at'] ?? 0),
          status: FarmerStatus.fromString(user['status'] ?? 'pending'),
          isVerified: (user['is_verified'] ?? 0) == 1,
          productsPosted: products.map((p) => p['id'] as String).toList(),
          complaintsSubmitted: [],
          totalPosts: 0,
          totalProducts: products.length,
          rating: (user['rating'] as num?)?.toDouble(),
          profileImage: user['profile_image'],
          address: user['address'],
        ));
      }

      return PaginatedResult(
        data: profiles,
        currentPage: page,
        totalPages: totalPages,
        hasMore: page < totalPages,
      );
    } catch (e) {
      throw Exception('Failed to get farmers: $e');
    }
  }

  Future<void> approveFarmer(String farmerId) async {
    await _db.update(
      'users',
      {
        'status': FarmerStatus.approved.databaseValue,
        'approved_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [farmerId],
    );
  }

  Future<void> rejectFarmer(String farmerId, {String? reason}) async {
    await _db.update(
      'users',
      {
        'status': FarmerStatus.rejected.databaseValue,
        'rejection_reason': reason,
      },
      where: 'id = ?',
      whereArgs: [farmerId],
    );
  }

  Future<void> banFarmer(String farmerId,
      {String? reason, Duration? duration}) async {
    final bannedUntil = duration != null
        ? DateTime.now().add(duration).millisecondsSinceEpoch
        : null;
    await _db.update(
      'users',
      {
        'status': FarmerStatus.banned.databaseValue,
        'ban_reason': reason,
        'banned_until': bannedUntil,
      },
      where: 'id = ?',
      whereArgs: [farmerId],
    );
  }

  Future<void> batchApproveFarmers(List<String> farmerIds) async {
    for (final id in farmerIds) {
      await approveFarmer(id);
    }
  }

  // Kisan Doctors Management
  Future<PaginatedResult<KisanDoctorProfile>> getDoctors({
    int page = 1,
    int pageSize = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      String whereClause = 'role = ?';
      List<dynamic> whereArgs = ['kisanDoctor'];

      final doctorsCount = await _db.query('users',
          columns: ['COUNT(*) as count'],
          where: whereClause,
          whereArgs: whereArgs);
      final totalItems = doctorsCount.first['count'] as int;
      final totalPages = (totalItems / pageSize).ceil();

      final users = await _db.query(
        'users',
        where: whereClause,
        whereArgs: whereArgs,
        limit: pageSize,
        offset: offset,
      );

      List<KisanDoctorProfile> profiles = users
          .map((user) => KisanDoctorProfile(
                id: user['id'],
                name: user['name'],
                email: user['email'] ?? '',
                phone: user['phone_number'] ?? '',
                qualification: 'Certified',
                expertise: user['specialization'] ?? 'General',
                specializations: _parseList(user['specialization']),
                assignedDistricts: [user['address'] ?? 'All'],
                languages: ['Nepali', 'English'],
                isOnline: false,
                rating: (user['rating'] as num?)?.toDouble() ?? 4.5,
                answersGiven: 0,
                farmerSatisfactionScore: 90,
                pendingReplies: 0,
                lastActive: DateTime.fromMillisecondsSinceEpoch(
                    user['last_login_at'] ?? 0),
                registeredAt: DateTime.fromMillisecondsSinceEpoch(
                    user['created_at'] ?? 0),
                isVerified: (user['is_verified'] ?? 0) == 1,
              ))
          .toList();

      return PaginatedResult(
        data: profiles,
        currentPage: page,
        totalPages: totalPages,
        hasMore: page < totalPages,
      );
    } catch (e) {
      throw Exception('Failed to get doctors: $e');
    }
  }

  Future<void> approveDoctorRegistration(String doctorId) async {
    await _db.update(
      'users',
      {'is_verified': 1, 'status': 'approved'},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future<void> assignDistrictToDoctor(
      String doctorId, List<String> districts) async {
    await _db.update(
      'users',
      {'assigned_districts': districts.join(',')},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  Future<void> suspendDoctor(String doctorId,
      {String? reason, Duration? duration}) async {
    final suspendedUntil = duration != null
        ? DateTime.now().add(duration).millisecondsSinceEpoch
        : null;
    await _db.update(
      'users',
      {
        'status': 'suspended',
        'suspension_reason': reason,
        'suspended_until': suspendedUntil,
      },
      where: 'id = ?',
      whereArgs: [doctorId],
    );
  }

  // Marketplace Management
  Future<PaginatedResult<MarketplaceProduct>> getPendingProducts({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      const whereClause = 'status = ?';
      const whereArgs = ['pending'];

      final productsCount = await _db.query('products',
          columns: ['COUNT(*) as count'],
          where: whereClause,
          whereArgs: whereArgs);
      final totalItems = productsCount.first['count'] as int;
      final totalPages = (totalItems / pageSize).ceil();

      final products = await _db.query(
        'products',
        where: whereClause,
        whereArgs: whereArgs,
        limit: pageSize,
        offset: offset,
        orderBy: 'posted_date DESC',
      );

      final productList = products
          .map((p) => MarketplaceProduct(
                id: p['id'],
                title: p['title'] ?? 'Unnamed',
                description: p['description'] ?? '',
                category: p['category'] ?? 'General',
                price: (p['price'] as num).toDouble(),
                unit: p['unit'] ?? 'unit',
                image: p['image'] ?? '',
                status: p['status'] ?? 'pending',
                postedDate:
                    DateTime.fromMillisecondsSinceEpoch(p['posted_date'] ?? 0),
                farmerId: p['farmer_id'] ?? '',
                farmerName: p['farmer_name'] ?? 'Unknown',
                isVerified: (p['is_verified'] ?? 0) == 1,
              ))
          .toList();

      return PaginatedResult(
        data: productList,
        currentPage: page,
        totalPages: totalPages,
        hasMore: page < totalPages,
      );
    } catch (e) {
      throw Exception('Failed to get pending products: $e');
    }
  }

  Future<void> approveProduct(String productId) async {
    await _db.update('products', {'status': 'approved'},
        where: 'id = ?', whereArgs: [productId]);
  }

  Future<void> rejectProduct(String productId, {String? reason}) async {
    await _db.update(
      'products',
      {'status': 'rejected', 'rejection_reason': reason},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Market Prices Management
  Future<List<MarketPrice>> getTodaysPrices() async {
    try {
      final prices = await _db.query('market_prices');
      return prices.map((p) => MarketPrice.fromMap(p)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateMarketPrice(
      String item, double price, String district) async {
    final existing = await _db.query('market_prices',
        where: 'item = ? AND district = ?', whereArgs: [item, district]);

    if (existing.isNotEmpty) {
      await _db.update(
          'market_prices',
          {
            'previous_week_price': existing.first['today_price'],
            'today_price': price,
            'updated_at': DateTime.now().millisecondsSinceEpoch
          },
          where: 'id = ?',
          whereArgs: [existing.first['id']]);
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
      'receiver_id': receiverId ?? (toAll ? 'all' : district),
      'is_read': 0,
      'type': 'info'
    });
  }

  Future<List<AdminNotification>> getNotifications() async {
    try {
      final notifs = await _db.query('notifications', orderBy: 'date DESC');
      return notifs.map((n) => AdminNotification.fromMap(n)).toList();
    } catch (e) {
      return [];
    }
  }

  // Community Posts Management
  Future<List<CommunityPost>> getPendingPosts() async {
    try {
      final posts =
          await _db.query('posts', where: 'status = ?', whereArgs: ['pending']);
      return posts.map((p) => CommunityPost.fromMap(p)).toList();
    } catch (e) {
      final posts = await _db.query('posts');
      return posts.map((p) => CommunityPost.fromMap(p)).toList();
    }
  }

  Future<void> approvePost(String postId) async {
    await _db.update('posts', {'status': 'approved'},
        where: 'id = ?', whereArgs: [postId]);
  }

  Future<void> deletePost(String postId, {String? reason}) async {
    await _db.delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  // Security & Logs
  Future<List<SecurityLog>> getSecurityLogs({int limit = 100}) async {
    try {
      final logs = await _db.query('security_logs',
          orderBy: 'timestamp DESC', limit: limit);
      return logs.map((l) => SecurityLog.fromMap(l)).toList();
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
      final farmers =
          await _db.query('users', where: 'role = ?', whereArgs: ['farmer']);
      final doctors = await _db
          .query('users', where: 'role = ?', whereArgs: ['kisanDoctor']);
      final products = await _db.query('products');

      final now = DateTime.now();
      final startOfDay =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final activeFarmers =
          farmers.where((f) => (f['last_login_at'] ?? 0) >= startOfDay).length;

      return AdminDashboardMetrics(
        totalFarmers: farmers.length,
        activeFarmersToday: activeFarmers,
        registeredDoctors: doctors.length,
        submittedProblems: 0,
        marketplaceListings: products.length,
        soldItemsToday: products
            .where((p) =>
                p['status'] == 'sold' && (p['updated_at'] ?? 0) >= startOfDay)
            .length,
        pendingApprovals:
            products.where((p) => p['status'] == 'pending').length,
        revenueToday: 0.0,
        weatherApiStatus: 'Connected',
        systemHealthStatus: 'Healthy',
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return AdminDashboardMetrics(
        totalFarmers: 0,
        activeFarmersToday: 0,
        registeredDoctors: 0,
        submittedProblems: 0,
        marketplaceListings: 0,
        soldItemsToday: 0,
        pendingApprovals: 0,
        revenueToday: 0.0,
        weatherApiStatus: 'Error',
        systemHealthStatus: 'Error',
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      return false;
    }
  }

  // System Control
  Future<void> performSystemBackup() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> clearCache() async {}

  Future<void> toggleMaintenanceMode(bool enable) async {}

  // Helpers
  String _extractDistrict(String? address) {
    if (address == null || address.isEmpty) return 'Unknown';
    final parts = address.split(',').map((part) => part.trim()).toList();
    if (parts.length > 1) return parts.last;
    return address;
  }

  String _extractProvince(String? address) {
    return 'Unknown';
  }

  List<String> _parseList(String? input) {
    if (input == null || input.isEmpty) return [];
    return input
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
