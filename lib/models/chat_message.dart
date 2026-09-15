import 'dart:convert';

import '../models/user.dart';

enum ChatMessageType { text, image, video, voice, location, reaction, group_announcement, forward }
enum MessageStatus { sent, delivered, read, error }

class ChatMessage {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final String? content;
  final String? mediaUrl;
  final ChatMessageType messageType;
  final int timestamp;
  MessageStatus status;
  final Map<String, int>? reactions; // emoji -> count
  final String? groupSenderName;
  final String? forwardedFromMessageId;
  final String? forwardedByName;
  final DateTime? forwardedTimestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    this.content,
    this.mediaUrl,
    required this.messageType,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.reactions,
    this.groupSenderName,
    this.forwardedFromMessageId,
    this.forwardedByName,
    this.forwardedTimestamp,
  });

  /// Copy with null safety
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? groupId,
    String? content,
    String? mediaUrl,
    ChatMessageType? messageType,
    int? timestamp,
    MessageStatus? status,
    Map<String, int>? reactions,
    String? groupSenderName,
    String? forwardedFromMessageId,
    String? forwardedByName,
    DateTime? forwardedTimestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      groupSenderName: groupSenderName ?? this.groupSenderName,
      forwardedFromMessageId: forwardedFromMessageId ?? this.forwardedFromMessageId,
      forwardedByName: forwardedByName ?? this.forwardedByName,
      forwardedTimestamp: forwardedTimestamp ?? this.forwardedTimestamp,
    );
  }

  /// Convert to map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'groupId': groupId,
      'content': content,
      'mediaUrl': mediaUrl,
      'messageType': messageType.name,
      'timestamp': timestamp,
      'status': status.name,
      if (reactions != null) 'reactions': reactions,
      if (groupSenderName != null) 'groupSenderName': groupSenderName,
      if (forwardedFromMessageId != null) 'forwardedFromMessageId': forwardedFromMessageId,
      if (forwardedByName != null) 'forwardedByName': forwardedByName,
      if (forwardedTimestamp != null) 'forwardedTimestamp': forwardedTimestamp.toIso8601String(),
    };
  }

  /// Create from map (JSON deserialization)
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    final reactions = <String, int>{};
    if (map['reactions'] != null) {
      final reactMap = map['reactions'] as Map<String, dynamic>;
      reactMap.forEach((emoji, count) {
        reactions[emoji] = (count as num).toInt();
      });
    }

    ChatMessageType type;
    try {
      type = ChatMessageType.values.firstWhere(
        (t) => t.name == map['messageType'],
        orElse: () => ChatMessageType.text,
      );
    } catch (_) {
      type = ChatMessageType.text;
    }

    DateTime? ft;
    if (map['forwardedTimestamp'] != null) {
      ft = DateTime.parse(map['forwardedTimestamp']);
    }

    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      groupId: map['groupId'],
      content: map['content'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      messageType: type,
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      status:
          MessageStatus.values.firstWhere(
            (s) => s.name == map['status'],
            orElse: () => MessageStatus.sent,
          ),
      reactions: reactions.isEmpty ? null : reactions,
      groupSenderName: map['groupSenderName'],
      forwardedFromMessageId: map['forwardedFromMessageId'],
      forwardedByName: map['forwardedByName'],
      forwardedTimestamp: ft,
    );
  }

  /// Get displayable content based on message type
  String get displayContent {
    switch (messageType) {
      case ChatMessageType.text:
        return content ?? '';
      case ChatMessageType.image:
        return mediaUrl != null ? 'Image' : '';
      case ChatMessageType.location:
        return 'Location';
      case ChatMessageType.reaction:
        return '';
      case ChatMessageType.group_announcement:
        return 'Group announcement';
      case ChatMessageType.forward:
        return 'Forwarded message';
      default:
        return content ?? '';
    }
  }

  /// Get message type icon
  Icon get icon {
    switch (messageType) {
      case ChatMessageType.text:
        return const Icon(Icons.message);
      case ChatMessageType.image:
        return const Icon(Icons.image);
      case ChatMessageType.location:
        return const Icon(Icons.location_on);
      case ChatMessageType.reaction:
        return const Icon(Icons.emoji_emotions);
      case ChatMessageType.group_announcement:
        return const Icon(Icons.group);
      case ChatMessageType.forward:
        return const Icon(Icons.forward);
      default:
        return const Icon(Icons.message);
    }
  }

  /// Get formatted time
  String get formattedTime {
    return _formatTimestamp(timestamp);
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${date.day}d ago';
    } else if (difference.inHours > 0) {
      return '${date.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${date.inMinutes}min ago';
    } else {
      return 'Just now';
    }
  }
}
