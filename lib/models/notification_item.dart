import 'package:flutter/material.dart';

enum NotificationType {
  weather,
  market,
  expert,
  crop,
  government,
  community,
  system,
}

enum NotificationFilter {
  all,
  weather,
  market,
  expert,
  crop,
  government,
  community,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      icon: icon,
      color: color,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}
