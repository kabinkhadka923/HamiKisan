import 'package:flutter/material.dart';
import 'dart:async';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../models/user.dart';
import 'package:hamikisan/models/chat_message.dart' show ChatMessageType;

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Map of Doctor ID to List of ChatMessage
  final Map<String, List<ChatMessage>> _chats = {};

  // Doctor typing status
  final Map<String, bool> _isTyping = {};

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _chatService.onNewMessage = (message) {
      final sender = message.senderId;
      final receiver = message.receiverId;
      if (_chats.containsKey(sender)) {
        _chats[sender] = [];
      }
      if (receiver != null && !_chats.containsKey(receiver)) {
        _chats[receiver] = [];
      }
      _chats[sender]!.add(message);
      if (receiver != null) {
        _chats[receiver]!.add(message);
      }
      notifyListeners();
    };
  }

  Future<void> initialize(String userId) async {
    _setLoading(true);
    await _chatService.initialize(userId);
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<ChatMessage> getMessages(String doctorId) {
    return _chats[doctorId] ?? [];
  }

  Future<void> loadMessages(String doctorId) async {
    if (!_chats.containsKey(doctorId) || _chats[doctorId]!.isEmpty) {
      _setLoading(true);
      final messages = await _chatService.getConversation(doctorId);
      _chats[doctorId] = messages;
      _setLoading(false);
      notifyListeners();
    }
  }

  bool isDoctorTyping(String doctorId) {
    return _isTyping[doctorId] ?? false;
  }

  Future<void> sendMessage(String doctorId, String text,
      {String type = 'text', String? mediaUrl}) async {
    final messageType = ChatMessageType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => ChatMessageType.text,
    );
    final success = await _chatService.sendMessage(
      doctorId: doctorId,
      message: text,
      messageType: messageType,
      mediaUrl: mediaUrl,
    );

    if (success) {
      // Message is added via onNewMessage callback in ChatService
      notifyListeners();
    }
  }

  Future<List<User>> getAvailableDoctors() async {
    return await _chatService.getAvailableDoctors();
  }
}
