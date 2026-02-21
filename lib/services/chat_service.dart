import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  static const String _usersKey = 'local_users_db_v4';
  static const String _messagesKey = 'hami_kisan_chat_messages_v1';

  String? _currentUserId;
  bool _isConnected = false;

  final StreamController<ChatMessage> _messageStreamController =
      StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  Function(List<ChatMessage>)? onMessagesReceived;
  Function(ChatMessage)? onNewMessage;
  Function(String)? onConnectionStatusChanged;
  Function(List<User>)? onDoctorsListReceived;

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
    final users = await _loadUsers();
    final current = _currentUserId;
    final result = <User>[];

    users.forEach((id, raw) {
      if (id == current) return;

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

    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  Future<bool> sendMessage({
    required String doctorId,
    required String message,
    required String messageType,
    String? imagePath,
  }) async {
    return sendMessageToUser(
      receiverId: doctorId,
      message: message,
      messageType: messageType,
      imagePath: imagePath,
    );
  }

  Future<bool> sendMessageToUser({
    required String receiverId,
    required String message,
    String messageType = 'text',
    String? imagePath,
  }) async {
    if (!_isConnected || _currentUserId == null) {
      throw Exception('Chat service not connected');
    }

    final cleanedMessage = message.trim();
    if (cleanedMessage.isEmpty) return false;

    final msgType = ChatMessageType.values.firstWhere(
      (type) => type.name == messageType,
      orElse: () => ChatMessageType.text,
    );

    final chatMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUserId!,
      receiverId: receiverId,
      message: cleanedMessage,
      messageType: msgType,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final messages = await _loadAllMessages();
    messages.add(chatMessage);
    await _saveAllMessages(messages);

    _messageStreamController.add(chatMessage);
    onNewMessage?.call(chatMessage);
    return true;
  }

  Future<List<ChatMessage>> getConversation(String doctorId) async {
    return getConversationWithUser(doctorId);
  }

  Future<List<ChatMessage>> getConversationWithUser(String otherUserId) async {
    if (_currentUserId == null) return [];

    final currentUserId = _currentUserId!;
    final messages = await _loadAllMessages();

    final conversation = messages.where((message) {
      final isForward = message.senderId == currentUserId &&
          message.receiverId == otherUserId;
      final isBackward = message.senderId == otherUserId &&
          message.receiverId == currentUserId;
      return isForward || isBackward;
    }).toList();

    conversation.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return conversation;
  }

  Future<void> markAsRead(String messageId) async {
    if (_currentUserId == null) return;

    final messages = await _loadAllMessages();
    var changed = false;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (message.id == messageId &&
          message.receiverId == _currentUserId &&
          message.status != MessageStatus.read) {
        messages[i] = message.copyWith(status: MessageStatus.read);
        changed = true;
      }
    }

    if (changed) {
      await _saveAllMessages(messages);
    }
  }

  Future<List<ChatMessage>> _getMessagesForCurrentUser() async {
    if (_currentUserId == null) return [];
    final all = await _loadAllMessages();
    final mine = all.where((message) {
      return message.senderId == _currentUserId ||
          message.receiverId == _currentUserId;
    }).toList();
    mine.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return mine;
  }

  Future<Map<String, Map<String, dynamic>>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString(_usersKey);
    if (usersRaw == null || usersRaw.isEmpty) return {};

    final decoded = json.decode(usersRaw);
    if (decoded is! Map<String, dynamic>) return {};

    final users = <String, Map<String, dynamic>>{};
    decoded.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        users[key] = value;
      } else if (value is Map) {
        users[key] = Map<String, dynamic>.from(value);
      }
    });
    return users;
  }

  User _mapUser(String id, Map<String, dynamic> raw) {
    final role = UserRole.values.firstWhere(
      (value) =>
          value.name.toLowerCase() ==
          (raw['role'] ?? UserRole.farmer.name).toString().toLowerCase(),
      orElse: () => UserRole.farmer,
    );

    final statusRaw = (raw['status'] ?? 'pending').toString();
    final status = UserStatus.values.firstWhere(
      (value) => value.name.toLowerCase() == statusRaw.toLowerCase(),
      orElse: () => statusRaw.toLowerCase().contains('approved')
          ? UserStatus.approved
          : UserStatus.pending,
    );

    final createdAtMillis =
        _asInt(raw['createdAt']) ?? _asInt(raw['created_at']) ?? 0;
    final lastLoginMillis =
        _asInt(raw['lastLoginAt']) ?? _asInt(raw['last_login_at']);

    final permissionsRaw = raw['permissions'];
    List<String>? permissions;
    if (permissionsRaw is List) {
      permissions = permissionsRaw.map((e) => e.toString()).toList();
    } else if (permissionsRaw is String && permissionsRaw.isNotEmpty) {
      try {
        final decoded = json.decode(permissionsRaw);
        if (decoded is List) {
          permissions = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return User(
      id: id,
      email: (raw['email'] ?? '').toString(),
      phoneNumber: (raw['phoneNumber'] ?? raw['phone_number'])?.toString(),
      name: (raw['name'] ?? '').toString(),
      profilePicture:
          (raw['profilePicture'] ?? raw['profile_picture'])?.toString(),
      role: role,
      status: status,
      address: raw['address']?.toString(),
      language: raw['language']?.toString(),
      farmingCategory: raw['farmingCategory']?.toString(),
      specialization: raw['specialization']?.toString(),
      permissions: permissions,
      createdAt: createdAtMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : DateTime.now(),
      lastLoginAt: lastLoginMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(lastLoginMillis)
          : null,
      isVerified:
          _asBool(raw['isVerified']) ?? _asBool(raw['is_verified']) ?? false,
      hasSelectedLanguage: _asBool(raw['hasSelectedLanguage']) ??
          _asBool(raw['has_selected_language']) ??
          false,
    );
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  Future<List<ChatMessage>> _loadAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_messagesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = json.decode(raw);
    if (decoded is! List) return [];

    final messages = <ChatMessage>[];
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        messages.add(ChatMessage.fromJson(item));
      } else if (item is Map) {
        messages.add(ChatMessage.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    return messages;
  }

  Future<void> _saveAllMessages(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = messages.map((m) => m.toJson()).toList();
    await prefs.setString(_messagesKey, json.encode(encoded));
  }

  void disconnect() {
    _isConnected = false;
    onConnectionStatusChanged?.call('disconnected');
  }

  bool get isConnected => _isConnected;

  void dispose() {
    disconnect();
    onMessagesReceived = null;
    onNewMessage = null;
    onConnectionStatusChanged = null;
    onDoctorsListReceived = null;
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final ChatMessageType messageType;
  final String? imagePath;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageType,
    this.imagePath,
    required this.timestamp,
    required this.status,
  });

  bool get isFromFarmer => senderId.toLowerCase().contains('farmer');

  ChatMessage copyWith({
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      messageType: messageType,
      imagePath: imagePath,
      timestamp: timestamp,
      status: status ?? this.status,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawMessageType =
        (json['messageType'] ?? json['message_type'] ?? 'text').toString();
    final rawStatus = (json['status'] ?? 'sent').toString();
    final rawTimestamp = json['timestamp'] ?? json['created_at'];

    int timestampMillis = 0;
    if (rawTimestamp is int) {
      timestampMillis = rawTimestamp;
    } else if (rawTimestamp != null) {
      timestampMillis = int.tryParse(rawTimestamp.toString()) ?? 0;
    }

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      senderId: (json['senderId'] ?? json['sender_id'] ?? '').toString(),
      receiverId: (json['receiverId'] ?? json['receiver_id'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      messageType: ChatMessageType.values.firstWhere(
        (type) => type.name == rawMessageType,
        orElse: () => ChatMessageType.text,
      ),
      imagePath: (json['imagePath'] ?? json['image_path'])?.toString(),
      timestamp: timestampMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(timestampMillis)
          : DateTime.now(),
      status: MessageStatus.values.firstWhere(
        (value) => value.name == rawStatus,
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'messageType': messageType.name,
        'imagePath': imagePath,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'status': status.name,
      };
}

enum ChatMessageType {
  text,
  image,
  audio,
}

enum MessageStatus {
  sent,
  delivered,
  read,
}

class ChatConversation {
  final User user;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;

  ChatConversation({
    required this.user,
    this.lastMessage,
    required this.unreadCount,
    required this.lastActivity,
  });
}
