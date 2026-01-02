import 'package:sqflite/sqflite.dart';
import '../models/community_models.dart';
import 'database.dart';

class CommunityService {
  final DatabaseService _db = DatabaseService();

  // ==================== GROUP MANAGEMENT ====================

  /// Get all groups a user belongs to
  Future<List<CommunityGroup>> getUserGroups(String userId) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT g.*, u.name as leader_name, u.profile_picture as leader_profile_picture
      FROM community_groups g
      LEFT JOIN users u ON g.leader_id = u.id
      WHERE g.id IN (
        SELECT group_id FROM community_members WHERE user_id = ?
      )
      AND g.is_active = 1
      ORDER BY 
        CASE g.type
          WHEN 'ward' THEN 1
          WHEN 'municipality' THEN 2
          WHEN 'district' THEN 3
          WHEN 'province' THEN 4
        END
    ''', [userId]);

    return results.map((json) => CommunityGroup.fromJson(json)).toList();
  }

  /// Get group by ID
  Future<CommunityGroup?> getGroupById(String groupId) async {
    final db = await _db.database;
    final results = await db.rawQuery('''
      SELECT g.*, u.name as leader_name, u.profile_picture as leader_profile_picture
      FROM community_groups g
      LEFT JOIN users u ON g.leader_id = u.id
      WHERE g.id = ?
    ''', [groupId]);

    if (results.isEmpty) return null;
    return CommunityGroup.fromJson(results.first);
  }

  /// Check if user is group leader
  Future<bool> isGroupLeader(String userId, String groupId) async {
    final db = await _db.database;
    final result = await db.query(
      'community_groups',
      where: 'id = ? AND leader_id = ?',
      whereArgs: [groupId, userId],
    );
    return result.isNotEmpty;
  }

  // ==================== NOTICES ====================

  /// Get notices for a group
  Future<List<CommunityNotice>> getGroupNotices(String groupId,
      {int limit = 50}) async {
    final db = await _db.database;
    final results = await db.query(
      'community_notices',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'is_pinned DESC, created_at DESC',
      limit: limit,
    );

    return results.map((json) => CommunityNotice.fromJson(json)).toList();
  }

  /// Create a new notice (leader only)
  Future<String> createNotice(CommunityNotice notice) async {
    final db = await _db.database;
    final id = 'notice_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('community_notices', {
      ...notice.toJson(),
      'id': id,
    });

    return id;
  }

  /// Update notice (leader only)
  Future<void> updateNotice(CommunityNotice notice) async {
    final db = await _db.database;
    await db.update(
      'community_notices',
      notice.toJson(),
      where: 'id = ?',
      whereArgs: [notice.id],
    );
  }

  /// Delete notice (leader only)
  Future<void> deleteNotice(String noticeId) async {
    final db = await _db.database;
    await db.delete(
      'community_notices',
      where: 'id = ?',
      whereArgs: [noticeId],
    );
  }

  /// Pin/Unpin notice
  Future<void> togglePinNotice(String noticeId, bool isPinned) async {
    final db = await _db.database;
    await db.update(
      'community_notices',
      {'is_pinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [noticeId],
    );
  }

  /// Increment view count
  Future<void> incrementNoticeViews(String noticeId) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE community_notices SET view_count = view_count + 1 WHERE id = ?',
      [noticeId],
    );
  }

  // ==================== MARKET PRICES ====================

  /// Get market prices for a group
  Future<List<CommunityMarketPrice>> getGroupMarketPrices(
    String groupId, {
    String? category,
    int limit = 50,
  }) async {
    final db = await _db.database;

    String whereClause = 'group_id = ?';
    List<dynamic> whereArgs = [groupId];

    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }

    final results = await db.query(
      'community_market_prices',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'price_date DESC, created_at DESC',
      limit: limit,
    );

    return results.map((json) => CommunityMarketPrice.fromJson(json)).toList();
  }

  /// Post market price (leader only)
  Future<String> postMarketPrice(CommunityMarketPrice price) async {
    final db = await _db.database;
    final id = 'price_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('community_market_prices', {
      ...price.toJson(),
      'id': id,
    });

    return id;
  }

  /// Update market price (leader only)
  Future<void> updateMarketPrice(CommunityMarketPrice price) async {
    final db = await _db.database;
    await db.update(
      'community_market_prices',
      price.toJson(),
      where: 'id = ?',
      whereArgs: [price.id],
    );
  }

  /// Delete market price (leader only)
  Future<void> deleteMarketPrice(String priceId) async {
    final db = await _db.database;
    await db.delete(
      'community_market_prices',
      where: 'id = ?',
      whereArgs: [priceId],
    );
  }

  // ==================== FEEDBACK ====================

  /// Get feedback for a group (leader view)
  Future<List<CommunityFeedback>> getGroupFeedback(
    String groupId, {
    FeedbackStatus? status,
    int limit = 100,
  }) async {
    final db = await _db.database;

    String whereClause = 'group_id = ?';
    List<dynamic> whereArgs = [groupId];

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status.toString().split('.').last);
    }

    final results = await db.query(
      'community_feedback',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'is_urgent DESC, created_at DESC',
      limit: limit,
    );

    return results.map((json) => CommunityFeedback.fromJson(json)).toList();
  }

  /// Get user's feedback
  Future<List<CommunityFeedback>> getUserFeedback(String userId) async {
    final db = await _db.database;
    final results = await db.query(
      'community_feedback',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results.map((json) => CommunityFeedback.fromJson(json)).toList();
  }

  /// Submit feedback
  Future<String> submitFeedback(CommunityFeedback feedback) async {
    final db = await _db.database;
    final id = 'feedback_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('community_feedback', {
      ...feedback.toJson(),
      'id': id,
    });

    return id;
  }

  /// Respond to feedback (leader only)
  Future<void> respondToFeedback(
    String feedbackId,
    String response,
    String responderId,
    String responderName,
    FeedbackStatus newStatus,
  ) async {
    final db = await _db.database;
    await db.update(
      'community_feedback',
      {
        'response': response,
        'responded_by_id': responderId,
        'responded_by_name': responderName,
        'responded_at': DateTime.now().toIso8601String(),
        'status': newStatus.toString().split('.').last,
      },
      where: 'id = ?',
      whereArgs: [feedbackId],
    );
  }

  /// Update feedback status (leader only)
  Future<void> updateFeedbackStatus(
      String feedbackId, FeedbackStatus status) async {
    final db = await _db.database;
    await db.update(
      'community_feedback',
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [feedbackId],
    );
  }

  // ==================== MESSAGES ====================

  /// Get messages for a group
  Future<List<CommunityMessage>> getGroupMessages(
    String groupId, {
    bool onlyApproved = true,
    int limit = 100,
  }) async {
    final db = await _db.database;

    String whereClause = 'group_id = ?';
    List<dynamic> whereArgs = [groupId];

    if (onlyApproved) {
      whereClause += ' AND is_approved = 1';
    }

    final results = await db.query(
      'community_messages',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((json) => CommunityMessage.fromJson(json)).toList();
  }

  /// Send message (requires approval unless sender is leader)
  Future<String> sendMessage(CommunityMessage message, bool isLeader) async {
    final db = await _db.database;
    final id = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    await db.insert('community_messages', {
      ...message.toJson(),
      'id': id,
      'is_approved': isLeader ? 1 : 0, // Auto-approve leader messages
    });

    return id;
  }

  /// Approve message (leader only)
  Future<void> approveMessage(String messageId, String approverId) async {
    final db = await _db.database;
    await db.update(
      'community_messages',
      {
        'is_approved': 1,
        'approved_by_id': approverId,
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Delete message (leader only)
  Future<void> deleteMessage(String messageId) async {
    final db = await _db.database;
    await db.delete(
      'community_messages',
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  /// Get pending messages for approval (leader view)
  Future<List<CommunityMessage>> getPendingMessages(String groupId) async {
    final db = await _db.database;
    final results = await db.query(
      'community_messages',
      where: 'group_id = ? AND is_approved = 0',
      whereArgs: [groupId],
      orderBy: 'created_at ASC',
    );

    return results.map((json) => CommunityMessage.fromJson(json)).toList();
  }

  // ==================== STATISTICS ====================

  /// Get group statistics
  Future<Map<String, dynamic>> getGroupStats(String groupId) async {
    final db = await _db.database;

    final noticeCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM community_notices WHERE group_id = ?',
            [groupId])) ??
        0;

    final memberCount = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM community_members WHERE group_id = ?',
            [groupId])) ??
        0;

    final pendingFeedback = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM community_feedback WHERE group_id = ? AND status = ?',
            [groupId, 'pending'])) ??
        0;

    final todayPrices = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM community_market_prices WHERE group_id = ? AND DATE(price_date) = DATE(?)',
            [groupId, DateTime.now().toIso8601String()])) ??
        0;

    return {
      'notice_count': noticeCount,
      'member_count': memberCount,
      'pending_feedback': pendingFeedback,
      'today_prices': todayPrices,
    };
  }
}
