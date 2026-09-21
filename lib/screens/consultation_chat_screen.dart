import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../models/chat_message.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/media_service.dart';
import '../services/location_service.dart';
import '../services/call/kisan_video_call_service.dart';
import 'video_call_screen.dart';

enum ChatMode { one_on_one, group }

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
  final MediaService _mediaService = MediaService();
  final LocationService _locationService = LocationService();

  StreamSubscription<ChatMessage>? _messageSub;

  String _myUserId = '';
  String _peerId = '';

  ChatMode _chatMode = ChatMode.one_on_one;
  String? _selectedGroupId;
  List<ChatMessage> _messages = [];
  List<ChatMessage> _groupMessages = [];
  List<Map<String, dynamic>> _availableGroups = [];
  bool _isLoadingGroups = false;

  TextEditingController _messageController = TextEditingController();
  bool _isComposing = false;
  bool _isSending = false;
  String? _mediaPath;
  String? _locationLat;
  String? _locationLng;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
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
    if (currentUser == null) return;

    _myUserId = currentUser.id;
    _peerId = widget.peer.id;

    await _chatService.initialize(currentUser.id);
    await _loadGroups();
    await _loadConversation();

    _messageSub = _chatService.messageStream.listen((message) {
      if (!mounted) return;
      _handleIncomingMessage(message);
      _scrollToBottom();
    });
  }

  void _handleIncomingMessage(ChatMessage message) {
    final isGroupMsg = message.groupId != null;
    final isCurrentGroup = !isGroupMsg ||
        (_selectedGroupId != null && message.groupId == _selectedGroupId);

    if (mounted) {
      setState(() {
        if (_chatMode == ChatMode.one_on_one) {
          if (!isGroupMsg &&
              (message.senderId == _peerId || message.receiverId == _myUserId)) {
            final index = _messages.indexWhere((m) => m.id == message.id);
            if (index >= 0) {
              _messages[index] = message;
            } else {
              _messages.add(message);
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            }
          }
        } else if (_chatMode == ChatMode.group && isCurrentGroup) {
          final index = _groupMessages.indexWhere((m) => m.id == message.id);
          if (index >= 0) {
            _groupMessages[index] = message;
          } else {
            _groupMessages.add(message);
            _groupMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          }
        }
      });
    }
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _chatService.getGroups();
      if (mounted) {
        setState(() {
          _availableGroups = groups;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadConversation() async {
    if (_chatMode == ChatMode.group && _selectedGroupId != null) {
      final messages = await _chatService.getConversationWithGroup(_selectedGroupId!);
      if (!mounted) return;
      setState(() {
        _groupMessages = messages;
      });
    } else {
      final messages = await _chatService.getConversationWithUser(_peerId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  Widget _buildChatModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _chatMode == ChatMode.one_on_one
                  ? null
                  : () {
                      setState(() => _chatMode = ChatMode.one_on_one);
                      _selectedGroupId = null;
                      _groupMessages.clear();
                      _loadConversation();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _chatMode == ChatMode.one_on_one
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                foregroundColor: _chatMode == ChatMode.one_on_one
                    ? Colors.white
                    : Colors.black87,
              ),
              child: const Text('One-on-One'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ElevatedButton(
              onPressed: _availableGroups.isEmpty
                  ? null
                  : () => _showGroupSelectionDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _chatMode == ChatMode.group
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                foregroundColor: _chatMode == ChatMode.group
                    ? Colors.white
                    : Colors.black87,
              ),
              child: _availableGroups.isEmpty
                  ? const Text('No Groups')
                  : const Text('Groups'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGroupSelectionDialog() async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _GroupSelectionDialog(groups: _availableGroups),
    );

    if (selected != null && mounted) {
      setState(() {
        _chatMode = ChatMode.group;
        _selectedGroupId = selected['groupId'] as String;
      });
      await _loadConversation();
    }
  }

  Widget _buildGroupHeader() {
    if (_chatMode != ChatMode.group || _selectedGroupId == null) return const SizedBox.shrink();

    final selectedGroup = _availableGroups.firstWhere(
      (g) => g['id'] == _selectedGroupId,
      orElse: () => {},
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedGroup['name'] ?? 'Group',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
            onPressed: () {
              setState(() {
                _chatMode = ChatMode.one_on_one;
                _selectedGroupId = null;
                _groupMessages.clear();
              });
            },
            tooltip: 'Close group',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_chatMode == ChatMode.group
            ? (_availableGroups.firstWhere((g) => g['id'] == _selectedGroupId, orElse: () => {'name': 'Group'})['name'] ?? 'Group')
            : 'Chat with ${widget.peer.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                    peerName: widget.peer.name,
                    callerName: authProvider.currentUser?.name ?? 'Me',
                    callerSpecialty: 'Consultation',
                    role: CallRole.caller,
                    callerId: authProvider.currentUser?.id ?? '',
                    calleeId: widget.peer.id,
                    calleePhoneNumber: widget.peer.phoneNumber,
                    isOutgoing: true,
                    callType: CallType.video,
                  ),
                ),
              );
            },
            tooltip: 'Video Call',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildChatModeSelector(),
          _buildGroupHeader(),
          Expanded(
            child: _chatMode == ChatMode.group
                ? ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _groupMessages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(_groupMessages[index]),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessageBubble(_messages[index]),
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == _myUserId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe && message.groupId == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      widget.peer.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 16 : 0),
                    topRight: Radius.circular(isMe ? 0 : 16),
                    bottomLeft: const Radius.circular(16),
                    bottomRight: const Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (message.messageType == ChatMessageType.text)
                      Text(
                        message.content ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      )
                    else if (message.messageType == ChatMessageType.image &&
                        message.mediaUrl != null)
                      Image.network(
                        message.mediaUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    else
                      Text(
                        message.content ?? '',
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 4.0),
                    Text(
                      _formatTimestamp(message.timestamp),
                      style: TextStyle(
                        color: isMe ? Colors.white70 : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
),
          ],
        ),
      ),
    ),
  );
}

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, size: 24),
            onPressed: _pickMedia,
            tooltip: 'Attach photo',
          ),
          IconButton(
            icon: const Icon(Icons.mic, size: 24),
            onPressed: () => _handlePickedMedia('voice'),
            tooltip: 'Voice message',
          ),
          IconButton(
            icon: const Icon(Icons.location_on, size: 24),
            onPressed: _shareLocation,
            tooltip: 'Share location',
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (text) {
                setState(() => _isComposing = text.isNotEmpty);
              },
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, size: 24),
            onPressed: _isComposing && !_isSending ? _sendMessage : null,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }

  Future<void> _pickMedia() async {
    final type = await _showMediaTypeDialog();
    if (type == null) return;

    setState(() => _isSending = true);

    try {
      String? result;
      switch (type) {
        case 'image':
          result = await _mediaService.pickImage();
          break;
      }

      if (result != null && mounted) {
        final url = 'https://hamikisan.s3.amazonaws.com/media/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final content = '';
          if (_chatMode == ChatMode.group && _selectedGroupId != null) {
            await _chatService.sendMessageToGroup(
              groupId: _selectedGroupId!,
              message: content,
              messageType: ChatMessageType.image,
              mediaUrl: url,
            );
          } else {
            await _chatService.sendMessageToUser(
              receiverId: _peerId,
              message: content,
              messageType: ChatMessageType.image,
              mediaUrl: url,
            );
          }
        setState(() => _mediaPath = null);
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _shareLocation() async {
    final position = await _locationService.getCurrentPosition();
    setState(() {
      _locationLat = position.latitude.toString();
      _locationLng = position.longitude.toString();
    });

    final content = 'latitude=${_locationLat},longitude=${_locationLng},address=Current Location';
      if (_chatMode == ChatMode.group && _selectedGroupId != null) {
        await _chatService.sendMessageToGroup(
          groupId: _selectedGroupId!,
          message: content,
          messageType: ChatMessageType.location,
          mediaUrl: null,
        );
      } else {
        await _chatService.sendMessageToUser(
          receiverId: _peerId,
          message: content,
          messageType: ChatMessageType.location,
          mediaUrl: null,
        );
      }
    setState(() {
      _locationLat = null;
      _locationLng = null;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      final content = text;
      if (_chatMode == ChatMode.group && _selectedGroupId != null) {
        await _chatService.sendMessageToGroup(
          groupId: _selectedGroupId!,
          message: content,
          messageType: ChatMessageType.text,
          mediaUrl: null,
        );
      } else {
        await _chatService.sendMessageToUser(
          receiverId: _peerId,
          message: content,
          messageType: ChatMessageType.text,
          mediaUrl: null,
        );
      }
      _messageController.clear();
      setState(() => _isComposing = false);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<String?> _showMediaTypeDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Attach'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Photo'),
              onTap: () => Navigator.of(context).pop('image'),
            ),
            ListTile(
              leading: const Icon(Icons.mic),
              title: const Text('Voice Message'),
              onTap: () => Navigator.of(context).pop('voice'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Location'),
              onTap: () => Navigator.of(context).pop('location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePickedMedia(String type) async {
    if (type == 'image') {
      await _pickMedia();
    } else if (type == 'voice') {
      // TODO: implement voice recording
    } else if (type == 'location') {
      await _shareLocation();
    }
  }
}

class _GroupSelectionDialog extends StatelessWidget {
  final List<Map<String, dynamic>> groups;

  const _GroupSelectionDialog({required this.groups});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Group'),
      content: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              title: Text(group['name'] ?? 'Unnamed Group'),
              onTap: () => Navigator.of(context).pop({'groupId': group['id']}),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
