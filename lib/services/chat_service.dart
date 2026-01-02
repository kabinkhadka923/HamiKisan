import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user.dart';
import 'database.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  
  // Event listeners
  Function(List<ChatMessage>)? onMessagesReceived;
  Function(ChatMessage)? onNewMessage;
  Function(String)? onConnectionStatusChanged;
  Function(List<User>)? onDoctorsListReceived;

  // Initialize Socket.IO connection
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    
    try {
      // For demo purposes, we'll simulate real-time chat
      // In production, replace with actual Socket.IO server
      print('Initializing chat service for user: $userId');
      _isConnected = true;
      onConnectionStatusChanged?.call('connected');
      
      // Load existing conversations from database
      await _loadConversations();
      
      // Emit user online event
      _emitEvent('user_online', {'userId': userId});
      
    } catch (e) {
      print('Chat initialization failed: $e');
      _isConnected = false;
      onConnectionStatusChanged?.call('disconnected');
    }
  }

  // Get available doctors
  Future<List<User>> getAvailableDoctors() async {
    final db = await DatabaseService().database;
    
    final doctors = await db.query(
      'users',
      where: 'role = ? AND status = ?',
      whereArgs: ['kisan_doctor', 'approved'],
    );

    return doctors.map((doctor) => User(
      id: doctor['id'] as String,
      email: doctor['email'] as String,
      phoneNumber: doctor['phone_number'] as String?,
      name: doctor['name'] as String,
      profilePicture: doctor['profile_picture'] as String?,
      role: UserRole.kisanDoctor,
      status: UserStatus.approved,
      specialization: doctor['specialization'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(doctor['created_at'] as int),
      lastLoginAt: doctor['last_login_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(doctor['last_login_at'] as int)
          : null,
      isVerified: (doctor['is_verified'] as int) == 1,
    )).toList();
  }

  // Send message to doctor
  Future<bool> sendMessage({
    required String doctorId,
    required String message,
    required String messageType,
    String? imagePath,
  }) async {
    if (!_isConnected) {
      throw Exception('Chat service not connected');
    }

    try {
      final chatMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: _currentUserId!,
        receiverId: doctorId,
        message: message,
        messageType: ChatMessageType.values.firstWhere(
          (type) => type.name == messageType,
        ),
        imagePath: imagePath,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // Save to database
      await _saveMessageToDatabase(chatMessage);

      // Emit message event
      _emitEvent('send_message', {
        'message': chatMessage.toJson(),
      });

      // Simulate doctor response
      _simulateDoctorResponse(doctorId, message);
      
      return true;
    } catch (e) {
      print('Failed to send message: $e');
      return false;
    }
  }

  // Get conversation with a specific doctor
  Future<List<ChatMessage>> getConversation(String doctorId) async {
    final db = await DatabaseService().database;
    
    final messages = await db.query(
      'doctor_conversations',
      where: '(farmer_id = ? AND doctor_id = ?) OR (farmer_id = ? AND doctor_id = ?)',
      whereArgs: [_currentUserId, doctorId, doctorId, _currentUserId],
      orderBy: 'created_at ASC',
    );

    return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
  }

  // Mark message as read
  Future<void> markAsRead(String messageId) async {
    final db = await DatabaseService().database;
    
    await db.update(
      'doctor_conversations',
      {'status': 'read'},
      where: 'id = ?',
      whereArgs: [messageId],
    );

    _emitEvent('message_read', {'messageId': messageId});
  }

  // Load conversations from database
  Future<void> _loadConversations() async {
    final db = await DatabaseService().database;
    
    final conversations = await db.query(
      'doctor_conversations',
      where: 'farmer_id = ?',
      orderBy: 'created_at DESC',
      limit: 50,
    );

    final messages = conversations.map((conv) => ChatMessage.fromJson(conv)).toList();
    onMessagesReceived?.call(messages);
  }

  // Save message to database
  Future<void> _saveMessageToDatabase(ChatMessage message) async {
    final db = await DatabaseService().database;
    
    await db.insert('doctor_conversations', {
      'id': message.id,
      'farmer_id': message.senderId,
      'doctor_id': message.receiverId,
      'message': message.message,
      'is_from_farmer': message.isFromFarmer ? 1 : 0,
      'message_type': message.messageType.name,
      'image_path': message.imagePath,
      'status': message.status.name,
      'created_at': message.timestamp.millisecondsSinceEpoch,
    });

    // Notify UI of new message
    onNewMessage?.call(message);
  }

  // Simulate doctor response (for demo)
  void _simulateDoctorResponse(String doctorId, String farmerMessage) {
    // Simulate response delay
    Future.delayed(const Duration(seconds: 2), () async {
      if (!_isConnected) return;

      final responses = [
        'धन्यवाद! मैले तपाईंको प्रश्न देखें। केही समयपछि जवाफ दिन्छु।',
        'Thank you for your message. I will review your question and provide guidance soon.',
        'बालीको अवस्था बुझ्न कृपया थप विवरण दिनुहोस्।',
        'Please provide more details about the crop condition.',
        'यो समस्या सामान्य छ। उपचारको लागि सुझाव दिन्छु।',
        'This is a common issue. I will suggest treatment options.',
      ];

      final randomResponse = responses[
        DateTime.now().millisecondsSinceEpoch % responses.length];

      final responseMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: doctorId,
        receiverId: _currentUserId!,
        message: randomResponse,
        messageType: ChatMessageType.text,
        timestamp: DateTime.now(),
        status: MessageStatus.delivered,
      );

      await _saveMessageToDatabase(responseMessage);
    });
  }

  // Emit socket event
  void _emitEvent(String event, Map<String, dynamic> data) {
    if (_socket != null && _isConnected) {
      _socket!.emit(event, data);
    }
  }

  // Disconnect
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    _isConnected = false;
    onConnectionStatusChanged?.call('disconnected');
  }

  // Get connection status
  bool get isConnected => _isConnected;

  // Cleanup
  void dispose() {
    disconnect();
    onMessagesReceived = null;
    onNewMessage = null;
    onConnectionStatusChanged = null;
    onDoctorsListReceived = null;
  }
}

// Chat message model
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

  bool get isFromFarmer => messageType == ChatMessageType.text || 
                           messageType == ChatMessageType.image;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    senderId: json['sender_id'] as String,
    receiverId: json['receiver_id'] as String,
    message: json['message'] as String,
    messageType: ChatMessageType.values.firstWhere(
      (type) => type.name == json['message_type'],
    ),
    imagePath: json['image_path'] as String?,
    timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    status: MessageStatus.values.firstWhere(
      (status) => status.name == json['status'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'message': message,
    'message_type': messageType.name,
    'image_path': imagePath,
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

// Chat conversation model for UI
class ChatConversation {
  final User doctor;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;

  ChatConversation({
    required this.doctor,
    this.lastMessage,
    required this.unreadCount,
    required this.lastActivity,
  });
}
