import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'database_helper.dart';
import '../models/user.dart';

/// Repository for user-related database operations
class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Create a new user
  Future<String> createUser({
    required String username,
    required String email,
    required String phoneNumber,
    required String name,
    required String password,
    required UserRole role,
    String? address,
    String? province,
    String? district,
    String? localLevel,
    String? wardNo,
    String? farmingCategory,
    String? landArea,
    String? kisanId,
    String? specialization,
  }) async {
    // Generate salt and hash password
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);

    final userId =
        'user_${DateTime.now().millisecondsSinceEpoch}_${username.hashCode.abs()}';
    final now = DateTime.now().millisecondsSinceEpoch;

    final userData = {
      'id': userId,
      'username': username.toLowerCase(),
      'email': email.toLowerCase(),
      'phone_number': phoneNumber,
      'name': name,
      'password_hash': passwordHash,
      'password_salt': salt,
      'role': role.toString().split('.').last,
      'status': 'pending', // Requires admin approval
      'address': address,
      'province': province,
      'district': district,
      'local_level': localLevel,
      'ward_no': wardNo,
      'farming_category': farmingCategory,
      'land_area': landArea,
      'kisan_id': kisanId,
      'specialization': specialization,
      'created_at': now,
      'is_verified': 0,
      'has_selected_language': 0,
      'language': 'en',
    };

    await _db.insert('users', userData);
    return userId;
  }

  /// Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final results = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username.toLowerCase()],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final results = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by phone number
  Future<Map<String, dynamic>?> getUserByPhone(String phoneNumber) async {
    final results = await _db.query(
      'users',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    final results = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Verify user password
  Future<bool> verifyPassword(String username, String password) async {
    final user = await getUserByUsername(username);
    if (user == null) return false;

    final hash = _hashPassword(password, user['password_salt'] as String);
    return hash == user['password_hash'];
  }

  /// Update user profile
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    // Remove sensitive fields that shouldn't be updated directly
    updates.remove('id');
    updates.remove('password_hash');
    updates.remove('password_salt');
    updates.remove('created_at');

    await _db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Update user password
  Future<void> updatePassword(String userId, String newPassword) async {
    final salt = _generateSalt();
    final passwordHash = _hashPassword(newPassword, salt);

    await _db.update(
      'users',
      {
        'password_hash': passwordHash,
        'password_salt': salt,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Update last login time
  Future<void> updateLastLogin(String userId) async {
    await _db.update(
      'users',
      {'last_login_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Get all users with pagination
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    String? where;
    List<Object?>? whereArgs;

    if (role != null && status != null) {
      where = 'role = ? AND status = ?';
      whereArgs = [role, status];
    } else if (role != null) {
      where = 'role = ?';
      whereArgs = [role];
    } else if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    }

    return await _db.query(
      'users',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Search users by name or username
  Future<List<Map<String, dynamic>>> searchUsers(String query,
      {int limit = 20}) async {
    return await _db.rawQuery(
      '''
      SELECT * FROM users 
      WHERE name LIKE ? OR username LIKE ?
      ORDER BY name ASC
      LIMIT ?
      ''',
      ['%$query%', '%$query%', limit],
    );
  }

  /// Check if username exists
  Future<bool> usernameExists(String username) async {
    return await _db.exists(
      'users',
      where: 'username = ?',
      whereArgs: [username.toLowerCase()],
    );
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    return await _db.exists(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
  }

  /// Check if phone number exists
  Future<bool> phoneExists(String phoneNumber) async {
    return await _db.exists(
      'users',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  /// Get user count by role
  Future<int> getUserCountByRole(String role) async {
    return await _db.getCount('users', where: 'role = ?', whereArgs: [role]);
  }

  /// Get user count by status
  Future<int> getUserCountByStatus(String status) async {
    return await _db
        .getCount('users', where: 'status = ?', whereArgs: [status]);
  }

  // Private helper methods
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        DateTime.now().microsecond.toString();
  }
}

/// Repository for post-related database operations
class PostRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Create a new post
  Future<String> createPost({
    required String userId,
    required String userName,
    required String userRole,
    required String content,
    String? userProfilePicture,
    String? imageUrl,
  }) async {
    final postId =
        'post_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode.abs()}';
    final now = DateTime.now().millisecondsSinceEpoch;

    final postData = {
      'id': postId,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'user_profile_picture': userProfilePicture,
      'content': content,
      'image_url': imageUrl,
      'likes': 0,
      'comments': 0,
      'shares': 0,
      'created_at': now,
      'is_pinned': 0,
    };

    await _db.insert('posts', postData);
    return postId;
  }

  /// Get all posts with pagination
  Future<List<Map<String, dynamic>>> getPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    return await _db.query(
      'posts',
      orderBy: 'is_pinned DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get posts by user
  Future<List<Map<String, dynamic>>> getPostsByUser(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await _db.query(
      'posts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get post by ID
  Future<Map<String, dynamic>?> getPostById(String postId) async {
    final results = await _db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Update post likes
  Future<void> updateLikes(String postId, int likes) async {
    await _db.update(
      'posts',
      {'likes': likes},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  /// Update post comments count
  Future<void> updateCommentsCount(String postId, int count) async {
    await _db.update(
      'posts',
      {'comments': count},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  /// Pin/unpin post
  Future<void> setPinned(String postId, bool pinned) async {
    await _db.update(
      'posts',
      {'is_pinned': pinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  /// Delete post
  Future<void> deletePost(String postId) async {
    await _db.delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  /// Get total post count
  Future<int> getPostCount({String? userId}) async {
    if (userId != null) {
      return await _db
          .getCount('posts', where: 'user_id = ?', whereArgs: [userId]);
    }
    return await _db.getCount('posts');
  }
}

/// Repository for product/marketplace operations
class ProductRepository {
  final DatabaseHelper _db = DatabaseHelper();

  /// Create a new product listing
  Future<String> createProduct({
    required String title,
    required String category,
    required double price,
    required String unit,
    required String location,
    required String farmerId,
    required String farmerName,
    String? description,
    String? province,
    String? district,
    String? image,
    String? images,
    String? farmerPhone,
    double? quantity,
  }) async {
    final productId =
        'product_${DateTime.now().millisecondsSinceEpoch}_${farmerId.hashCode.abs()}';
    final now = DateTime.now().millisecondsSinceEpoch;

    final productData = {
      'id': productId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'location': location,
      'province': province,
      'district': district,
      'image': image,
      'images': images,
      'status': 'available',
      'posted_date': now,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'farmer_phone': farmerPhone,
      'views': 0,
    };

    await _db.insert('products', productData);
    return productId;
  }

  /// Get all products with filters and pagination
  Future<List<Map<String, dynamic>>> getProducts({
    String? category,
    String? district,
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    String? where;
    List<Object?>? whereArgs = [];

    if (category != null && district != null && status != null) {
      where = 'category = ? AND district = ? AND status = ?';
      whereArgs = [category, district, status];
    } else if (category != null && district != null) {
      where = 'category = ? AND district = ?';
      whereArgs = [category, district];
    } else if (category != null && status != null) {
      where = 'category = ? AND status = ?';
      whereArgs = [category, status];
    } else if (district != null && status != null) {
      where = 'district = ? AND status = ?';
      whereArgs = [district, status];
    } else if (category != null) {
      where = 'category = ?';
      whereArgs = [category];
    } else if (district != null) {
      where = 'district = ?';
      whereArgs = [district];
    } else if (status != null) {
      where = 'status = ?';
      whereArgs = [status];
    }

    return await _db.query(
      'products',
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'posted_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Get products by farmer
  Future<List<Map<String, dynamic>>> getProductsByFarmer(
    String farmerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return await _db.query(
      'products',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'posted_date DESC',
      limit: limit,
      offset: offset,
    );
  }

  /// Search products
  Future<List<Map<String, dynamic>>> searchProducts(String query,
      {int limit = 20}) async {
    return await _db.rawQuery(
      '''
      SELECT * FROM products 
      WHERE title LIKE ? OR description LIKE ? OR category LIKE ?
      AND status = 'available'
      ORDER BY posted_date DESC
      LIMIT ?
      ''',
      ['%$query%', '%$query%', '%$query%', limit],
    );
  }

  /// Update product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    updates['updated_date'] = DateTime.now().millisecondsSinceEpoch;
    await _db.update(
      'products',
      updates,
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  /// Increment product views
  Future<void> incrementViews(String productId) async {
    await _db.rawQuery(
      'UPDATE products SET views = views + 1 WHERE id = ?',
      [productId],
    );
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    await _db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }
}
