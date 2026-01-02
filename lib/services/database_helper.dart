import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Optimized Database Helper with connection pooling and performance enhancements
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _databaseName = 'hamikisan_optimized.db';
  static const int _databaseVersion = 1;
  
  Database? _database;
  final _initLock = Completer<void>();
  bool _isInitializing = false;

  /// Get database instance with lazy initialization
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    // Prevent multiple simultaneous initializations
    if (_isInitializing) {
      await _initLock.future;
      return _database!;
    }

    _isInitializing = true;
    try {
      _database = await _initDatabase();
      _initLock.complete();
      return _database!;
    } catch (e) {
      _initLock.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = kIsWeb ? 'hamikisan_web' : await getDatabasesPath();
    final path = kIsWeb ? _databaseName : join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database for optimal performance
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
    
    // Optimize for performance
    await db.execute('PRAGMA journal_mode = WAL'); // Write-Ahead Logging
    await db.execute('PRAGMA synchronous = NORMAL'); // Faster writes
    await db.execute('PRAGMA cache_size = -64000'); // 64MB cache
    await db.execute('PRAGMA temp_store = MEMORY'); // Use memory for temp storage
    await db.execute('PRAGMA mmap_size = 30000000000'); // Memory-mapped I/O
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Users table with optimized indexes
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT UNIQUE,
        name TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        profile_picture TEXT,
        role TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        address TEXT,
        province TEXT,
        district TEXT,
        local_level TEXT,
        ward_no TEXT,
        language TEXT DEFAULT 'en',
        farming_category TEXT,
        land_area TEXT,
        kisan_id TEXT,
        specialization TEXT,
        permissions TEXT,
        created_at INTEGER NOT NULL,
        last_login_at INTEGER,
        is_verified INTEGER DEFAULT 0,
        has_selected_language INTEGER DEFAULT 0
      )
    ''');

    // Optimized indexes for users
    batch.execute('CREATE INDEX idx_users_username ON users(username)');
    batch.execute('CREATE INDEX idx_users_email ON users(email)');
    batch.execute('CREATE INDEX idx_users_phone ON users(phone_number)');
    batch.execute('CREATE INDEX idx_users_role ON users(role)');
    batch.execute('CREATE INDEX idx_users_status ON users(status)');

    // Sessions table
    batch.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        token TEXT NOT NULL UNIQUE,
        device_info TEXT,
        ip_address TEXT,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        last_activity INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_sessions_user ON sessions(user_id)');
    batch.execute('CREATE INDEX idx_sessions_token ON sessions(token)');
    batch.execute('CREATE INDEX idx_sessions_expires ON sessions(expires_at)');

    // Posts table
    batch.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_role TEXT NOT NULL,
        user_profile_picture TEXT,
        content TEXT NOT NULL,
        image_url TEXT,
        likes INTEGER DEFAULT 0,
        comments INTEGER DEFAULT 0,
        shares INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        is_pinned INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_posts_user ON posts(user_id)');
    batch.execute('CREATE INDEX idx_posts_created ON posts(created_at DESC)');
    batch.execute('CREATE INDEX idx_posts_pinned ON posts(is_pinned, created_at DESC)');

    // Products table
    batch.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        unit TEXT NOT NULL DEFAULT 'kg',
        quantity REAL,
        location TEXT NOT NULL,
        province TEXT,
        district TEXT,
        image TEXT,
        images TEXT,
        status TEXT NOT NULL DEFAULT 'available',
        posted_date INTEGER NOT NULL,
        updated_date INTEGER,
        farmer_id TEXT NOT NULL,
        farmer_name TEXT NOT NULL,
        farmer_phone TEXT,
        views INTEGER DEFAULT 0,
        FOREIGN KEY (farmer_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_products_farmer ON products(farmer_id)');
    batch.execute('CREATE INDEX idx_products_category ON products(category)');
    batch.execute('CREATE INDEX idx_products_status ON products(status)');
    batch.execute('CREATE INDEX idx_products_location ON products(district)');
    batch.execute('CREATE INDEX idx_products_posted ON products(posted_date DESC)');

    // Market prices table
    batch.execute('''
      CREATE TABLE market_prices (
        id TEXT PRIMARY KEY,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        min_price REAL NOT NULL,
        max_price REAL NOT NULL,
        avg_price REAL NOT NULL,
        unit TEXT NOT NULL DEFAULT 'kg',
        market_location TEXT NOT NULL,
        district TEXT NOT NULL,
        price_date TEXT NOT NULL,
        source TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_market_prices_product ON market_prices(product_name)');
    batch.execute('CREATE INDEX idx_market_prices_district ON market_prices(district)');
    batch.execute('CREATE INDEX idx_market_prices_date ON market_prices(price_date DESC)');

    // Notifications table
    batch.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('CREATE INDEX idx_notifications_user ON notifications(user_id)');
    batch.execute('CREATE INDEX idx_notifications_read ON notifications(is_read, created_at DESC)');

    // Community groups table
    batch.execute('''
      CREATE TABLE community_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        district TEXT,
        leader_id TEXT NOT NULL,
        member_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (leader_id) REFERENCES users (id)
      )
    ''');
    batch.execute('CREATE INDEX idx_community_groups_leader ON community_groups(leader_id)');
    batch.execute('CREATE INDEX idx_community_groups_location ON community_groups(district)');

    // Community members table
    batch.execute('''
      CREATE TABLE community_members (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT DEFAULT 'member',
        joined_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (group_id) REFERENCES community_groups (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        UNIQUE(group_id, user_id)
      )
    ''');
    batch.execute('CREATE INDEX idx_community_members_group ON community_members(group_id)');
    batch.execute('CREATE INDEX idx_community_members_user ON community_members(user_id)');

    // Security logs table
    batch.execute('''
      CREATE TABLE security_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        action TEXT NOT NULL,
        ip_address TEXT,
        device_info TEXT,
        status TEXT NOT NULL,
        details TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_security_logs_user ON security_logs(user_id)');
    batch.execute('CREATE INDEX idx_security_logs_created ON security_logs(created_at DESC)');

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < newVersion) {
      // Add migration logic as needed
    }
  }

  /// Execute a batch of operations for better performance
  Future<void> executeBatch(Function(Batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    await batch.commit(noResult: true);
  }

  /// Insert with conflict handling
  Future<int> insert(
    String table,
    Map<String, dynamic> data, {
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: conflictAlgorithm);
  }

  /// Bulk insert for better performance
  Future<void> insertBulk(String table, List<Map<String, dynamic>> dataList) async {
    final db = await database;
    final batch = db.batch();
    for (final data in dataList) {
      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Query with pagination support
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Raw query for complex operations
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Update records
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

  /// Delete records
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Execute raw SQL
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  /// Get count of records
  Future<int> getCount(String table, {String? where, List<Object?>? whereArgs}) async {
    final db = await database;
    final result = await db.query(
      table,
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if record exists
  Future<bool> exists(String table, {String? where, List<Object?>? whereArgs}) async {
    final count = await getCount(table, where: where, whereArgs: whereArgs);
    return count > 0;
  }

  /// Vacuum database to reclaim space and optimize
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  /// Analyze database for query optimization
  Future<void> analyze() async {
    final db = await database;
    await db.execute('ANALYZE');
  }

  /// Clean up expired sessions
  Future<void> cleanupExpiredSessions() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await delete('sessions', where: 'expires_at < ?', whereArgs: [now]);
  }

  /// Clean up old security logs (keep last 90 days)
  Future<void> cleanupOldLogs({int daysToKeep = 90}) async {
    final cutoff = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;
    await delete('security_logs', where: 'created_at < ?', whereArgs: [cutoff]);
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset database (for testing/development)
  Future<void> reset() async {
    await close();
    final dbPath = kIsWeb ? 'hamikisan_web' : await getDatabasesPath();
    final path = kIsWeb ? _databaseName : join(dbPath, _databaseName);
    await deleteDatabase(path);
  }
}
