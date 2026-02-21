import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../services/call/kisan_video_call_service.dart';
import '../services/chat_service.dart';
import 'video_call_screen.dart';

class ConsultationChatScreen extends StatefulWidget {
  final User peer;

  const ConsultationChatScreen({
    super.key,
    required this.peer,
  });

  @override
  State<ConsultationChatScreen> createState() => _ConsultationChatScreenState();
}

class _ConsultationChatScreenState extends State<ConsultationChatScreen> {
  final ChatService _chatService = ChatService();
  final AudioService _audioService = AudioService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  StreamSubscription<ChatMessage>? _messageSub;
  List<ChatMessage> _messages = [];
  String? _myUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    _myUserId = currentUser.id;
    await _chatService.initialize(currentUser.id);
    await _audioService.initialize();
    await _loadConversation();

    _messageSub = _chatService.messageStream.listen((message) async {
      if (!_isCurrentConversationMessage(message)) return;

      if (!mounted) return;
      setState(() => _upsertMessage(message));
      _scrollToBottom();

      if (message.receiverId == _myUserId) {
        await _chatService.markAsRead(message.id);
        await _audioService.playMessageReceived();
      }
    });
  }

  Future<void> _loadConversation() async {
    final messages = await _chatService.getConversationWithUser(widget.peer.id);
    if (!mounted) return;

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    await _markConversationAsRead(messages);
    _scrollToBottom();
  }

  bool _isCurrentConversationMessage(ChatMessage message) {
    if (_myUserId == null) return false;

    final outgoing =
        message.senderId == _myUserId && message.receiverId == widget.peer.id;
    final incoming =
        message.senderId == widget.peer.id && message.receiverId == _myUserId;

    return outgoing || incoming;
  }

  void _upsertMessage(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      _messages[index] = message;
    } else {
      _messages.add(message);
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final sent = await _chatService.sendMessageToUser(
      receiverId: widget.peer.id,
      message: text,
      messageType: ChatMessageType.text.name,
    );

    if (!sent) return;

    _messageController.clear();
    await _audioService.playMessageSent();
    await _loadConversation();
  }

  Future<void> _markConversationAsRead(List<ChatMessage> messages) async {
    if (_myUserId == null) return;

    final unreadIncoming = messages.where(
      (message) =>
          message.receiverId == _myUserId &&
          message.status != MessageStatus.read,
    );

    for (final message in unreadIncoming) {
      await _chatService.markAsRead(message.id);
    }
  }

  void _startCall(CallType callType) {
    if (_myUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, chat is still loading.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(
          doctorName: widget.peer.name,
          doctorSpecialty: widget.peer.specialization ??
              (widget.peer.role == UserRole.kisanDoctor
                  ? 'Kisan Doctor'
                  : 'Farmer'),
          callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
          recipientId: widget.peer.id,
          isOutgoing: true,
          callType: callType,
          callContext: {
            'callerId': _myUserId,
            'callerType':
                context.read<AuthProvider>().currentUser?.role.name ?? 'farmer',
          },
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = _myUserId;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peer.name),
            Text(
              widget.peer.role == UserRole.kisanDoctor
                  ? (widget.peer.specialization ?? 'Kisan Doctor')
                  : 'Farmer',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _startCall(CallType.audio),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _startCall(CallType.video),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEDE5DB),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderId == myId;
                        return _buildMessageBubble(message, isMe);
                      },
                    ),
                  ),
                  _buildMessageInput(),
                ],
              ),
            ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 3),
            bottomRight: Radius.circular(isMe ? 3 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        border:
            Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.grey.shade700,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xFF2E7D32),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 19),
              onPressed: _sendMessage,
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.mic_none),
            color: Colors.grey.shade700,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
