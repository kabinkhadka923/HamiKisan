import 'package:flutter/material.dart';
import 'dart:async';
import '../services/chat_service.dart';
import '../models/user.dart';

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
      final otherId =
          message.isFromFarmer ? message.receiverId : message.senderId;
      if (_chats.containsKey(otherId)) {
        _chats[otherId]!.add(message);
        notifyListeners();
      }
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
      {String type = 'text', String? imagePath}) async {
    final success = await _chatService.sendMessage(
      doctorId: doctorId,
      message: text,
      messageType: type,
      imagePath: imagePath,
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
