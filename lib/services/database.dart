import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String _databaseName = 'hamikisan_secure.db';
  static const int _databaseVersion = 3;
  Database? _database;
  bool _isInitialized = false;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = kIsWeb ? 'hamikisan_web' : await getDatabasesPath();
    final path = kIsWeb ? _databaseName : join(dbPath, _databaseName);

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _isInitialized = true;
    await _initializeDefaultData(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        profile_picture TEXT,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        address TEXT,
        language TEXT,
        farming_category TEXT,
        specialization TEXT,
        permissions TEXT,
        created_at INTEGER NOT NULL,
        last_login_at INTEGER,
        is_verified INTEGER DEFAULT 0,
        has_selected_language INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_role TEXT NOT NULL,
        content TEXT NOT NULL,
        image_url TEXT,
        likes INTEGER DEFAULT 0,
        comments INTEGER DEFAULT 0,
        shares INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_users_username ON users(username)
    ''');

    await db.execute('''
      CREATE INDEX idx_users_email ON users(email)
    ''');

    await db.execute('''
      CREATE INDEX idx_posts_user ON posts(user_id)
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        image TEXT NOT NULL,
        status TEXT NOT NULL,
        posted_date INTEGER NOT NULL,
        farmer_id TEXT NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE market_prices (
        id TEXT PRIMARY KEY,
        item TEXT NOT NULL,
        today_price REAL NOT NULL,
        previous_week_price REAL NOT NULL,
        trend TEXT NOT NULL,
        district TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        date INTEGER NOT NULL,
        receiver_id TEXT,
        is_read INTEGER DEFAULT 0,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE security_logs (
        id TEXT PRIMARY KEY,
        admin_id TEXT NOT NULL,
        action TEXT NOT NULL,
        ip_address TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        details TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE products (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          price REAL NOT NULL,
          location TEXT NOT NULL,
          image TEXT NOT NULL,
          status TEXT NOT NULL,
          posted_date INTEGER NOT NULL,
          farmer_id TEXT NOT NULL,
          FOREIGN KEY (farmer_id) REFERENCES users (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE market_prices (
          id TEXT PRIMARY KEY,
          item TEXT NOT NULL,
          today_price REAL NOT NULL,
          previous_week_price REAL NOT NULL,
          trend TEXT NOT NULL,
          district TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE notifications (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          date INTEGER NOT NULL,
          receiver_id TEXT,
          is_read INTEGER DEFAULT 0,
          type TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE security_logs (
          id TEXT PRIMARY KEY,
          admin_id TEXT NOT NULL,
          action TEXT NOT NULL,
          ip_address TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          details TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Community Groups
      await db.execute('''
        CREATE TABLE community_groups (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          location TEXT NOT NULL,
          leader_id TEXT NOT NULL,
          member_count INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (leader_id) REFERENCES users (id)
        )
      ''');

      // Community Members
      await db.execute('''
        CREATE TABLE community_members (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          joined_at TEXT NOT NULL,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (group_id) REFERENCES community_groups (id),
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(group_id, user_id)
        )
      ''');

      // Community Notices
      await db.execute('''
        CREATE TABLE community_notices (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          type TEXT NOT NULL,
          author_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          author_profile_picture TEXT,
          created_at TEXT NOT NULL,
          expires_at TEXT,
          is_pinned INTEGER DEFAULT 0,
          attachments TEXT,
          view_count INTEGER DEFAULT 0,
          FOREIGN KEY (group_id) REFERENCES community_groups (id),
          FOREIGN KEY (author_id) REFERENCES users (id)
        )
      ''');

      // Community Market Prices
      await db.execute('''
        CREATE TABLE community_market_prices (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          product_name TEXT NOT NULL,
          category TEXT NOT NULL,
          min_price REAL NOT NULL,
          max_price REAL NOT NULL,
          avg_price REAL NOT NULL,
          unit TEXT NOT NULL,
          market_location TEXT NOT NULL,
          price_date TEXT NOT NULL,
          posted_by_id TEXT NOT NULL,
          posted_by_name TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (group_id) REFERENCES community_groups (id),
          FOREIGN KEY (posted_by_id) REFERENCES users (id)
        )
      ''');

      // Community Feedback
      await db.execute('''
        CREATE TABLE community_feedback (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          user_name TEXT NOT NULL,
          user_profile_picture TEXT,
          type TEXT NOT NULL,
          subject TEXT NOT NULL,
          message TEXT NOT NULL,
          status TEXT DEFAULT 'pending',
          response TEXT,
          responded_by_id TEXT,
          responded_by_name TEXT,
          responded_at TEXT,
          created_at TEXT NOT NULL,
          is_urgent INTEGER DEFAULT 0,
          FOREIGN KEY (group_id) REFERENCES community_groups (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // Community Messages
      await db.execute('''
        CREATE TABLE community_messages (
          id TEXT PRIMARY KEY,
          group_id TEXT NOT NULL,
          sender_id TEXT NOT NULL,
          sender_name TEXT NOT NULL,
          sender_profile_picture TEXT,
          message TEXT NOT NULL,
          reply_to_notice_id TEXT,
          created_at TEXT NOT NULL,
          is_approved INTEGER DEFAULT 0,
          approved_by_id TEXT,
          FOREIGN KEY (group_id) REFERENCES community_groups (id),
          FOREIGN KEY (sender_id) REFERENCES users (id)
        )
      ''');

      // Create indexes for better performance
      await db.execute(
          'CREATE INDEX idx_community_groups_leader ON community_groups(leader_id)');
      await db.execute(
          'CREATE INDEX idx_community_members_group ON community_members(group_id)');
      await db.execute(
          'CREATE INDEX idx_community_members_user ON community_members(user_id)');
      await db.execute(
          'CREATE INDEX idx_community_notices_group ON community_notices(group_id)');
      await db.execute(
          'CREATE INDEX idx_community_market_prices_group ON community_market_prices(group_id)');
      await db.execute(
          'CREATE INDEX idx_community_feedback_group ON community_feedback(group_id)');
      await db.execute(
          'CREATE INDEX idx_community_messages_group ON community_messages(group_id)');
    }
  }

  Future<void> _initializeDefaultData(Database db) async {
    final count =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
    if (count != null && count > 0) return;

    final salt = _generateSalt();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('users', {
      'id': 'user_farmer_demo',
      'username': 'farmer',
      'email': 'farmer@hamikisan.com',
      'phone_number': '9800000000',
      'name': 'Rajesh Kumar',
      'password_hash': _hashPassword('demo123', salt),
      'password_salt': salt,
      'role': 'farmer',
      'status': 'approved',
      'address': 'Kathmandu, Nepal',
      'farming_category': 'Vegetable Farming',
      'created_at': now,
      'last_login_at': now,
      'is_verified': 1,
      'has_selected_language': 1,
      'language': 'en',
    });

    await db.insert('users', {
      'id': 'user_doctor_demo',
      'username': 'doctor',
      'email': 'doctor@hamikisan.com',
      'phone_number': '9800000001',
      'name': 'Dr. Sarita Sharma',
      'password_hash': _hashPassword('demo123', salt),
      'password_salt': salt,
      'role': 'kisanDoctor',
      'status': 'approved',
      'address': 'Pokhara, Nepal',
      'specialization': 'Crop Disease Specialist',
      'created_at': now,
      'last_login_at': now,
      'is_verified': 1,
      'has_selected_language': 1,
      'language': 'en',
    });

    await db.insert('users', {
      'id': 'user_admin_demo',
      'username': 'admin',
      'email': 'kabinkhadka@gmail.com',
      'phone_number': '9800000002',
      'name': 'Kabin Khadka',
      'password_hash': _hashPassword('admin123', salt),
      'password_salt': salt,
      'role': 'kisanAdmin',
      'status': 'approved',
      'address': 'Kathmandu, Nepal',
      'permissions':
          json.encode(['manage_users', 'manage_content', 'approve_users']),
      'created_at': now,
      'last_login_at': now,
      'is_verified': 1,
      'has_selected_language': 1,
      'language': 'en',
    });

    await db.insert('users', {
      'id': 'user_superadmin_demo',
      'username': 'superadmin',
      'email': 'superadmin@hamikisan.com',
      'phone_number': '9800000003',
      'name': 'Super Admin',
      'password_hash': _hashPassword('super123', salt),
      'password_salt': salt,
      'role': 'superAdmin',
      'status': 'approved',
      'address': 'Kathmandu, Nepal',
      'permissions':
          json.encode(['full_access', 'system_control', 'manage_admins']),
      'created_at': now,
      'last_login_at': now,
      'is_verified': 1,
      'has_selected_language': 1,
      'language': 'en',
    });
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  String _generateSalt() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _isInitialized = false;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final results = await query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final results = await query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> verifyPassword(String username, String password) async {
    final user = await getUserByUsername(username);
    if (user == null) return false;

    final hash = _hashPassword(password, user['password_salt']);
    return hash == user['password_hash'];
  }

  Future<int> createUser(Map<String, dynamic> userData) async {
    final salt = _generateSalt();
    final password = userData['password'] ?? 'default123';

    userData['password_hash'] = _hashPassword(password, salt);
    userData['password_salt'] = salt;
    userData.remove('password');
    userData['created_at'] = DateTime.now().millisecondsSinceEpoch;

    return await insert('users', userData);
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    return await query('posts', orderBy: 'created_at DESC');
  }

  Future<int> createPost(Map<String, dynamic> postData) async {
    try {
      postData['created_at'] = DateTime.now().millisecondsSinceEpoch;
      print('Inserting post into database: $postData');
      final result = await insert('posts', postData);
      print('Post inserted successfully: $result');
      return result;
    } catch (e) {
      print('Error in createPost database: $e');
      rethrow;
    }
  }

  Future<int> deletePost(String postId) async {
    return await delete('posts', where: 'id = ?', whereArgs: [postId]);
  }

  Future<int> updatePostLikes(String postId, int likes) async {
    return await update(
      'posts',
      {'likes': likes},
      where: 'id = ?',
      whereArgs: [postId],
    );
  }
}
