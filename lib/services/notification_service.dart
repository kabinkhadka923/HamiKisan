import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_item.dart';
import 'database.dart';

class NotificationService {
  NotificationService({DatabaseService? databaseService})
      : _database = databaseService ?? DatabaseService();

  final DatabaseService _database;

  Future<List<NotificationItem>> getNotifications({
    required String userId,
    String? district,
  }) async {
    final normalizedDistrict = district?.split(',').first.trim().toLowerCase();
    final rows = await _database.query('notifications', orderBy: 'date DESC');
    final visibleRows = rows.where((row) {
      final recipient = row['receiver_id']?.toString();
      if (recipient == null || recipient.isEmpty || recipient == 'all') {
        return true;
      }
      if (recipient == userId) return true;
      return normalizedDistrict != null &&
          normalizedDistrict.isNotEmpty &&
          recipient.toLowerCase() == normalizedDistrict;
    });

    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_readKey(userId))?.toSet() ?? {};
    final hiddenIds = prefs.getStringList(_hiddenKey(userId))?.toSet() ?? {};

    return visibleRows
        .where((row) => !hiddenIds.contains(row['id'].toString()))
        .map((row) => _fromRow(row, readIds))
        .toList();
  }

  Future<void> setRead(
      String userId, String notificationId, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_readKey(userId))?.toSet() ?? {};
    if (isRead) {
      readIds.add(notificationId);
    } else {
      readIds.remove(notificationId);
    }
    await prefs.setStringList(_readKey(userId), readIds.toList());
  }

  Future<void> markAllRead(
    String userId,
    Iterable<String> notificationIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_readKey(userId))?.toSet() ?? {};
    readIds.addAll(notificationIds);
    await prefs.setStringList(_readKey(userId), readIds.toList());
  }

  Future<void> delete(String userId, String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenIds = prefs.getStringList(_hiddenKey(userId))?.toSet() ?? {};
    hiddenIds.add(notificationId);
    await prefs.setStringList(_hiddenKey(userId), hiddenIds.toList());
  }

  Future<void> clear(
    String userId,
    Iterable<String> notificationIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenIds = prefs.getStringList(_hiddenKey(userId))?.toSet() ?? {};
    hiddenIds.addAll(notificationIds);
    await prefs.setStringList(_hiddenKey(userId), hiddenIds.toList());
  }

  NotificationItem _fromRow(
    Map<String, dynamic> row,
    Set<String> readIds,
  ) {
    final type = NotificationType.values.firstWhere(
      (value) => value.name == row['type'],
      orElse: () => NotificationType.system,
    );
    final (icon, color) = _presentation(type);
    final timestamp = row['date'];

    return NotificationItem(
      id: row['id'].toString(),
      title: row['title']?.toString() ?? 'Notification',
      message: row['body']?.toString() ?? '',
      icon: icon,
      color: color,
      timestamp: timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.tryParse(timestamp?.toString() ?? '') ?? DateTime.now(),
      type: type,
      isRead: readIds.contains(row['id'].toString()),
    );
  }

  (IconData, Color) _presentation(NotificationType type) {
    return switch (type) {
      NotificationType.weather => (Icons.cloud, Colors.orange),
      NotificationType.market => (Icons.attach_money, Colors.purple),
      NotificationType.expert => (Icons.medical_services, Colors.blue),
      NotificationType.crop => (Icons.eco, Colors.green),
      NotificationType.government => (Icons.account_balance, Colors.red),
      NotificationType.community => (Icons.group, Colors.teal),
      NotificationType.system => (Icons.notifications, Colors.indigo),
    };
  }

  String _readKey(String userId) => 'notifications_read_$userId';
  String _hiddenKey(String userId) => 'notifications_hidden_$userId';
}
