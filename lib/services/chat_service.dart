import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';
import '../services/backend_config.dart';

enum ChatPrivacyLevel { public, private, encrypted }
enum ChatPrivacyStatus { active, paused, archived }

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  static const String _usersKey = 'local_users_db_v4';
  static const String _messagesKey = 'hami_kisan_chat_messages_v1';

  String? _currentUserId;
  bool _isConnected = false;

  String? get currentUserId => _currentUserId;

  final StreamController<ChatMessage> _messageStreamController =
      StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  final StreamController<Map<String, dynamic>> _reactionStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get reactionStream =>
      _reactionStreamController.stream;

  Function(List<ChatMessage>)? onMessagesReceived;
  Function(ChatMessage)? onNewMessage;
  Function(String)? onConnectionStatusChanged;
  Function(List<User>)? onDoctorsListReceived;
  Function(Map<String, dynamic>)? onReactionReceived;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    _isConnected = true;
    onConnectionStatusChanged?.call('connected');

    final messages = await _getMessagesForCurrentUser();
    onMessagesReceived?.call(messages);
    final doctors = await getAvailableDoctors();
    onDoctorsListReceived?.call(doctors);
  }

  Future<List<User>> getAvailableDoctors() async {
    return _getUsersByRole(UserRole.kisanDoctor);
  }

  Future<List<User>> getAvailableFarmers() async {
    return _getUsersByRole(UserRole.farmer);
  }

  Future<List<User>> _getUsersByRole(UserRole role) async {
    final remote = await _fetchUsersFromBackend(role);
    if (remote != null && remote.isNotEmpty) {
      remote.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return remote;
    }

    final users = await _loadUsers();
    final current = _currentUserId;
    final result = <User>[];

    users.forEach((id, raw) {
      if (id != null && current != null && id == current) return;

      final roleValue = (raw['role'] ?? '').toString();
      final mappedRole = UserRole.values.firstWhere(
        (value) => value.name.toLowerCase() == roleValue.toLowerCase(),
        orElse: () => UserRole.farmer,
      );

      if (mappedRole != role) return;

      final statusValue = (raw['status'] ?? 'approved').toString();
      final isApproved = statusValue.toLowerCase().contains('approved');
      if (!isApproved) return;

      result.add(_mapUser(id, raw));
    });

    return result;
  }

/// Load users from local storage
  Future<Map<String, dynamic>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_usersKey);

    if (jsonString == null) return {};

    final Map<String, dynamic> userMap = json.decode(jsonString);
    return userMap;
  }

  /// Map raw user data to User object
  User _mapUser(String id, Map<String, dynamic> raw) {
    return User(
      id: id,
      name: raw['name'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == raw['role'],
        orElse: () => UserRole.farmer,
      ),
      status: UserStatus.values.firstWhere(
        (s) => s.name == raw['status'],
        orElse: () => UserStatus.approved,
      ),
      email: raw['email'] ?? '',
      phoneNumber: raw['phone'] ?? '',
      profilePicture: raw['avatar'] ?? '',
      createdAt: DateTime.tryParse(raw['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
  Future<List<User>?> _fetchUsersFromBackend(UserRole role) async {
    if (_currentUserId == null) return null;
    try {
      final path = role == UserRole.kisanDoctor
          ? '/api/users/doctors'
          : '/api/users/farmers';
      final token = await AuthService.getAuthToken();
      final response = await http
          .get(BackendConfig.uri(path), headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawList = (data['doctors'] ?? data['farmers']) as List<dynamic>?;
      if (rawList == null) return null;

      final users = <User>[];
      for (final raw in rawList) {
        if (raw is! Map<String, dynamic>) continue;
        final user = _mapUser((raw['id'] ?? '').toString(), raw);
        if (user.id == _currentUserId || user.id.isEmpty) continue;
        users.add(user);
      }
      return users;
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendMessage({
    required String doctorId,
    required String message,
    required ChatMessageType messageType,
    String? mediaUrl,
  }) async {
    return sendMessageToUser(
      receiverId: doctorId,
      message: message,
      messageType: messageType,
      mediaUrl: mediaUrl,
    );
  }

  Future<bool> sendMessageToUser({
    required String receiverId,
    required String message,
    required ChatMessageType messageType,
    String? mediaUrl,
  }) async {
    if (!_isConnected || _currentUserId == null) {
      throw Exception('Chat service not connected');
    }

    final cleanedMessage = message.trim();
    if (cleanedMessage.isEmpty && mediaUrl == null) return false;

    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: receiverId,
      content: cleanedMessage,
      mediaUrl: mediaUrl,
      messageType: messageType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: MessageStatus.sent,
    );

    // Store locally first
    await _storeMessageLocally(chatMessage);

    // Broadcast to UI
    _messageStreamController.add(chatMessage);

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/chat/message'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'receiverId': receiverId,
          'content': cleanedMessage,
          'messageType': messageType.name,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        chatMessage.status = MessageStatus.delivered;
        _messageStreamController.add(chatMessage);
        return true;
      } else {
        chatMessage.status = MessageStatus.error;
        _messageStreamController.add(chatMessage);
        return false;
      }
    } catch (e) {
      chatMessage.status = MessageStatus.error;
      _messageStreamController.add(chatMessage);
      return false;
    }
  }

  /// Send a reaction to a message
  Future<bool> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    if (!_isConnected || _currentUserId == null) {
      return false;
    }

    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/chat/reaction'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'messageId': messageId,
          'emoji': emoji,
          'userId': _currentUserId!,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // Broadcast the reaction
        final reactionData = {
          'messageId': messageId,
          'emoji': emoji,
          'userId': _currentUserId!,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        _reactionStreamController.add(reactionData);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mark message as read
  Future<void> markAsRead(String messageId) async {
    try {
      final token = await AuthService.getAuthToken();
      await http.post(
        BackendConfig.uri('/api/chat/read'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'messageId': messageId},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String userId) async {
    try {
      final token = await AuthService.getAuthToken();
      await http.post(
        BackendConfig.uri('/api/chat/read-conversation'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'userId': userId},
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// Get conversation with a specific user
  Future<List<ChatMessage>> getConversationWithUser(String userId) async {
    // Try backend first
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/chat/conversation'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'userId': userId},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> messages = data['messages'] ?? [];
        return messages.map((m) => _mapMessageFromBackend(m)).toList();
      }
    } catch (_) {}

    // Fallback to local storage
    final localMessages = await _loadMessages();
    return localMessages
        .where((m) => m.senderId != null && (m.senderId == _currentUserId || m.receiverId == _currentUserId))
        .toList();
  }

  /// Get conversation with a specific doctor/ farmer
  Future<List<ChatMessage>> getConversation(String userId) async {
    // Try backend first
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/chat/conversation'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'userId': userId},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> messages = data['messages'] ?? [];
        return messages.map((m) => _mapMessageFromBackend(m)).toList();
      }
    } catch (_) {}

    // Fallback to local storage
    final localMessages = await _loadMessages();
    return localMessages
        .where((m) => m.senderId != null && (m.senderId == _currentUserId || m.receiverId == _currentUserId))
        .toList();
  }

  /// Get conversation with a specific group
  Future<List<ChatMessage>> getConversationWithGroup(String groupId) async {
    // Try backend first
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/group/conversation'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {'groupId': groupId},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> messages = data['messages'] ?? [];
        return messages.map((m) => _mapMessageFromBackend(m)).toList();
      }
    } catch (_) {}

    // Fallback to local storage
    final localMessages = await _loadMessages();
    return localMessages
        .where((m) => m.groupId == groupId)
        .toList();
  }

  ChatMessage _mapMessageFromBackend(Map<String, dynamic> data) {
    final type = ChatMessageType.values.firstWhere(
      (t) => t.name == data['messageType'],
      orElse: () => ChatMessageType.text,
    );

    final reactions = <String, int>{};
    if (data['reactions'] != null) {
      final reactData = data['reactions'] as Map<String, dynamic>;
      reactData.forEach((emoji, count) {
        reactions[emoji] = (count as num).toInt();
      });
    }

    return ChatMessage(
      id: data['id'] ?? '',
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      messageType: type,
      timestamp: data['timestamp'] != null
          ? data['timestamp'] is int
              ? data['timestamp']
              : DateTime.parse(data['timestamp']).millisecondsSinceEpoch
          : DateTime.now().millisecondsSinceEpoch,
      status: MessageStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      reactions: reactions,
    );
  }

  /// Load messages from local storage
  Future<List<ChatMessage>> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_messagesKey);

    if (jsonString == null) return [];

    final List<dynamic> messages = json.decode(jsonString);
    return messages.map((m) => ChatMessage.fromMap(m)).toList();
  }

  /// Store message locally
  Future<void> _storeMessageLocally(ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ChatMessage> existingMessages = await _loadMessages();

    // Add new message
    existingMessages.add(message);

    // Keep only last 1000 messages
    final limited =
        existingMessages.length > 1000
            ? existingMessages.sublist(existingMessages.length - 1000)
            : existingMessages;

    final List<Map<String, dynamic>> jsonMessages =
        limited.map((m) => m.toMap()).toList();

    final String jsonString = json.encode(jsonMessages);
    await prefs.setString(_messagesKey, jsonString);
  }

  /// Get messages for current user (local + backend)
  Future<List<ChatMessage>> _getMessagesForCurrentUser() async {
    final localMessages = await _loadMessages();
    // Filter to only show conversations with doctors/farmers
    return localMessages
        .where((m) =>
            m.senderId != null &&
            (m.senderId == _currentUserId || m.receiverId == _currentUserId))
        .toList();
  }

  /// Encode message with basic encryption (placeholder)
  String _encryptMessage(String message) {
    // In production, use proper encryption
    return message;
  }

  /// Decode message (placeholder)
  String _decryptMessage(String encrypted) {
    // In production, use proper decryption
    return encrypted;
  }

  /// Format timestamp for display
  String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${date.day}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min ago';
    } else {
      return 'Just now';
    }
  }
/// Create a new group chat
/// Returns the group ID
Future<String> createGroup({
  required String groupName,
  required List<String> participantIds,
  String? adminId,
}) async {
  if (!_isConnected || _currentUserId == null) {
    throw Exception('Chat service not connected');
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/create'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {
        'groupName': groupName,
        'participantIds': participantIds.join(','),
        'adminId': adminId ?? _currentUserId!,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['groupId'] ?? '';
    }
    throw Exception('Failed to create group');
  } catch (e) {
    rethrow;
  }
}

/// Get groups for current user
Future<List<Map<String, dynamic>>> getGroups() async {
  if (!_isConnected || _currentUserId == null) {
    return [];
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/list'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['groups'] as List<Map<String, dynamic>>? ?? [];
    }
    return [];
  } catch (_) {
    return [];
  }
}

/// Send message to a group
Future<bool> sendMessageToGroup({
  required String groupId,
  required String message,
  required ChatMessageType messageType,
  String? mediaUrl,
}) async {
  if (!_isConnected || _currentUserId == null) {
    throw Exception('Chat service not connected');
  }

  final cleanedMessage = message.trim();
  if (cleanedMessage.isEmpty && mediaUrl == null) return false;

  final chatMessage = ChatMessage(
    id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
    senderId: _currentUserId!,
    receiverId: '',
    groupId: groupId,
    content: cleanedMessage,
    mediaUrl: mediaUrl,
    messageType: messageType,
    timestamp: DateTime.now().millisecondsSinceEpoch,
    status: MessageStatus.sent,
  );

  // Store locally
  await _storeMessageLocally(chatMessage);

  // Broadcast to UI
  _messageStreamController.add(chatMessage);

  // Call backend
  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/message'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {
        'groupId': groupId,
        'senderId': _currentUserId!,
        'content': cleanedMessage,
        'messageType': messageType.name,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      chatMessage.status = MessageStatus.delivered;
      _messageStreamController.add(chatMessage);
      return true;
    } else {
      chatMessage.status = MessageStatus.error;
      _messageStreamController.add(chatMessage);
      return false;
    }
  } catch (e) {
    chatMessage.status = MessageStatus.error;
    _messageStreamController.add(chatMessage);
    return false;
  }
}

/// Add participant to group
Future<bool> addGroupMember({
  required String groupId,
  required String userId,
}) async {
  if (!_isConnected || _currentUserId == null) {
    return false;
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/member/add'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {
        'groupId': groupId,
        'userId': userId,
      },
    ).timeout(const Duration(seconds: 8));

    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

/// Remove participant from group
Future<bool> removeGroupMember({
  required String groupId,
  required String userId,
}) async {
  if (!_isConnected || _currentUserId == null) {
    return false;
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/member/remove'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {
        'groupId': groupId,
        'userId': userId,
      },
    ).timeout(const Duration(seconds: 8));

    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

/// Get group members
Future<List<User>> getGroupMembers(String groupId) async {
  if (!_isConnected || _currentUserId == null) {
    return [];
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/group/members'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {'groupId': groupId},
    ).timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> members = data['members'] ?? [];
      return members.map((m) => User(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        role: UserRole.values.firstWhere(
          (r) => r.name == m['role'],
          orElse: () => UserRole.farmer,
        ),
        email: m['email'] ?? '',
        phoneNumber: m['phone'] ?? '',
        profilePicture: m['avatar'] ?? '',
        status: UserStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => UserStatus.approved,
        ),
        createdAt: DateTime.tryParse(m['createdAt'] ?? '') ?? DateTime.now(),
      )).toList();
    }
    return [];
  } catch (_) {
    return [];
  }
}

/// Forward a message to a recipient or group
/// Returns the forwarded message ID
Future<String> forwardMessage({
  required String originalMessageId,
  required String targetReceiverId, // recipient ID or group ID
  required ChatMessageType targetType, // messageType for the forwarded message
}) async {
  if (!_isConnected || _currentUserId == null) {
    throw Exception('Chat service not connected');
  }

  try {
    // Get original message details
    final localMessages = await _loadMessages();
    final originalMessage = localMessages.firstWhere(
      (m) => m.id == originalMessageId,
      orElse: () => ChatMessage(
        id: '', 
        senderId: '', 
        messageType: ChatMessageType.text,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    final cleanedContent = originalMessage.content ?? '';
    final mediaUrl = originalMessage.mediaUrl;

    // Create forwarded message
    final forwardedMessage = ChatMessage(
      id: 'msg_forward_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: targetReceiverId,
      groupId: originalMessage.groupId,
      content: cleanedContent,
      mediaUrl: mediaUrl,
      messageType: targetType,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      status: MessageStatus.sent,
      forwardedFromMessageId: originalMessageId,
      forwardedByName: originalMessage.senderId,
      forwardedTimestamp: DateTime.now(),
    );

    // Store locally
    await _storeMessageLocally(forwardedMessage);

    // Broadcast to UI
    _messageStreamController.add(forwardedMessage);

    // Call backend
    try {
      final token = await AuthService.getAuthToken();
      final response = await http.post(
        BackendConfig.uri('/api/chat/forward'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: {
          'originalMessageId': originalMessageId,
          'targetReceiverId': targetReceiverId,
          'content': cleanedContent,
          'messageType': targetType.name,
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        forwardedMessage.status = MessageStatus.delivered;
        _messageStreamController.add(forwardedMessage);
        return forwardedMessage.id;
      } else {
        forwardedMessage.status = MessageStatus.error;
        _messageStreamController.add(forwardedMessage);
        return '';
      }
    } catch (e) {
      forwardedMessage.status = MessageStatus.error;
      _messageStreamController.add(forwardedMessage);
      return '';
    }
  } catch (e) {
    return '';
  }
}

/// Search messages in chat history
/// Returns list of messages matching the search query
Future<List<ChatMessage>> searchMessages({
  required String query,
  required String userId,
}) async {
  if (!_isConnected || _currentUserId == null) {
    return [];
  }

  try {
    final token = await AuthService.getAuthToken();
    final response = await http.post(
      BackendConfig.uri('/api/chat/search'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: {
        'query': query,
        'userId': userId,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> results = data['results'] ?? [];
      return results.map((m) => _mapMessageFromBackend(m)).toList();
    }
    return [];
  } catch (_) {
    // Fallback: search locally
    final localMessages = await _loadMessages();
    final lowerQuery = query.toLowerCase();
    return localMessages
        .where((m) =>
            (m.content ?? '').toLowerCase().contains(lowerQuery) ||
            (m.mediaUrl != null) ||
            (m.groupId != null))
        .toList();
  }
}